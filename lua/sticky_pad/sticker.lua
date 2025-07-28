local M = {}

local core = require("sticky_pad.core")
local list = require("sticky_pad.list")
local config = require("sticky_pad.config").get()

local active_sticker = {
  win_id = 0,
  buf_id = 0,
  top_line = 1,
  file_name = "",
}



local function get_full_note_conf()
  local width = config.sticker.width
  local height = math.floor(vim.o.lines * 0.9)
  return {
    relative = "editor",
    width = width,
    height = height,
    col = config.sticker.col,
    row = config.sticker.row,
    border = "rounded",
    focusable = true,
    title = "sticky.pad"
  }
end

local function get_sticker_win_conf()
  return {
    width = config.sticker.width,
    height = config.sticker.height,
    row = config.sticker.row,
    col = config.sticker.col,
    relative = "editor",
    border = "rounded",
    style = "minimal",
    focusable = false,
    title = "sticky.pad"
  }
end

local function refresh_sticker()
  if not vim.api.nvim_win_is_valid(active_sticker.win_id) then
    return
  end
  vim.api.nvim_win_set_buf(active_sticker.win_id, active_sticker.buf_id)
  vim.api.nvim_win_set_cursor(active_sticker.win_id, { active_sticker.top_line, 0 })
  vim.api.nvim_win_call(active_sticker.win_id, function()
    vim.cmd("normal! zt")
  end)
end

local function get_title(lines)
  local first_line = ""
  for _, line in ipairs(lines) do
    if line ~= "" then
      first_line = line
      break
    end
  end
  return first_line
end


local function create_sticker_item(lines)
  local title = get_title(lines)
  if title == "" then
    return nil
  end
  return {
    file_name = tostring(os.time()) .. "-" .. ".md",
    title = title,
    is_last_used = false,
  }
end

function M.create()
  local augroup = vim.api.nvim_create_augroup("NewSticker", { clear = true })
  local buf = vim.api.nvim_create_buf(false, false)
  local win = vim.api.nvim_open_win(buf, true, get_full_note_conf())
  vim.api.nvim_set_option_value('wrap', true, { win = win })

  vim.api.nvim_buf_set_name(buf, "new_sticker.md")
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = augroup,
    buffer = buf,
    once = true,
    desc = "Save sticker note content to file",
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local sticker_item = create_sticker_item(lines)

      if not lines then
        vim.notify("Cannot save an empty note.", "warn")
        vim.api.nvim_win_close(win, true)
        return
      end

      local full_path = core.get_sticker_path(sticker_item.file_name)
      vim.fn.writefile(lines, full_path)

      list.add(sticker_item)

      vim.api.nvim_set_option_value("modified", false, { buf = buf })
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_buf_delete(buf, { force = true })
    end,
  })
end

function M.show(file_name)
  if list.get_last_used() then
    list.update_item(list.get_last_used().file_name, { is_last_used = false })
  end
  local list_item = list.get_by_file_name(file_name)
  active_sticker.buf_id = vim.fn.bufnr(core.get_sticker_path(file_name), true)
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = active_sticker.buf_id })

  active_sticker.file_name = file_name
  active_sticker.top_line = list_item.top_line or 1

  if active_sticker.win_id == 0 then
    active_sticker.win_id = vim.api.nvim_open_win(active_sticker.buf_id, false, get_sticker_win_conf())
    vim.api.nvim_set_option_value('linebreak', true, { win = active_sticker.win_id })
    vim.api.nvim_set_option_value('wrap', true, { win = active_sticker.win_id })
  else
    vim.api.nvim_win_set_buf(active_sticker.win_id, active_sticker.buf_id)
  end
  refresh_sticker()
  list.update_item(active_sticker.file_name, { is_last_used = true })
end

function M.remove()
  if vim.api.nvim_win_is_valid(active_sticker.win_id) then
    vim.api.nvim_win_close(active_sticker.win_id, true)
    active_sticker.win_id = 0
  end
end

function M.unfold()
  if vim.api.nvim_win_is_valid(active_sticker.win_id) then
    vim.api.nvim_win_set_config(active_sticker.win_id, get_full_note_conf())
    vim.api.nvim_set_current_win(active_sticker.win_id)
  end
end

function M.get_new_line()
  local line_count = core.get_line_number(active_sticker.buf_id, config.sticker.width)
  if line_count > config.sticker_height then
    local current_line = core.get_current_line_number(active_sticker.win_id)
    if line_count - current_line > config.sticker_height then
      return current_line
    else
      return line_count - config.sticker_height
    end
  end
  return 1
end

local function normalize_scroll()
  local line_count = core.get_line_number(active_sticker.buf_id, config.sticker.width)
  if line_count > config.sticker.height then
    local visual_current_line = core.get_current_line_number(active_sticker.win_id)
    if line_count - visual_current_line > config.sticker.height then
      local real_line = vim.api.nvim_win_get_cursor(active_sticker.win_id)[1]
      active_sticker.top_line = real_line
    else
      active_sticker.top_line = line_count - config.sticker.height
    end
  else
    active_sticker.top_line = 1
  end
end

function M.fold()
  if vim.api.nvim_win_is_valid(active_sticker.win_id) then
    local buf = vim.api.nvim_win_get_buf(active_sticker.win_id)
    if vim.api.nvim_get_option_value("modified", { buf = buf }) then
      vim.notify("Save your changes first with :w", vim.log.levels.WARN)
      return
    end

    normalize_scroll()
    list.update_item(active_sticker.file_name, { top_line = active_sticker.top_line })
    list.update_item(active_sticker.file_name, { title = vim.api.nvim_buf_get_lines(active_sticker.buf_id, 0, -1, true)[1] })

    vim.api.nvim_win_set_config(active_sticker.win_id, get_sticker_win_conf())
    refresh_sticker()

    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
      local config = vim.api.nvim_win_get_config(win_id)
      if config.relative == "" then
        vim.api.nvim_set_current_win(win_id)
        break
      end
    end
  end
end

---@param num_of_steps integer
function M.move_topline(num_of_steps)
  local line_count = vim.api.nvim_buf_line_count(active_sticker.buf_id)

  local new_topline = active_sticker.top_line + num_of_steps

  active_sticker.top_line = math.max(1, math.min(new_topline, line_count))

  list.update_item(active_sticker.file_name, { top_line = active_sticker.top_line })
  refresh_sticker()
end

-- Only for tests
function M.reset()
  active_sticker = {
    win_id = 0,
    buf_id = 0,
    top_line = 1,
    file_name = "",
  }
end

return M

