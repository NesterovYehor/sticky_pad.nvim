local M = {}


local active_sticker_win_id

local core = require("sticky_pad.core")
local list = require("sticky_pad.list")


local function get_sticker_name()
  return tostring(os.time()) .. ".md"
end

local function get_sticker_path(name)
  return core.get_dashboard_dir() .. "/" .. name
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
  return {
    file_name = get_sticker_name(),
    title = get_title(lines),
    is_last_used = true,

  }
end


local function get_full_note_conf()
  local width = 35
  local height = math.floor(vim.o.lines * 0.8)
  local win_opst = {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 5,
    row = 5,
    border = "single",
    focusable = true,
  }
  return win_opst
end

function M.new()
  local augroup = vim.api.nvim_create_augroup("NewSticker", { clear = true })
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(buf, "new_sticker.md")
  local win = vim.api.nvim_open_win(buf, true, get_full_note_conf())

  vim.api.nvim_create_autocmd('BufWriteCmd', {
    group = augroup,
    buffer = buf,
    once = true,
    desc = "Save sticker note content to file",
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local sticker_item = create_sticker_item(lines)
      if sticker_item.title == "" then
        vim.notify("Cannot save an empty note.", "warn")
        vim.api.nvim_win_close(win, true)
        return
      end

      local sticker_path = get_sticker_path(sticker_item.file_name)
      vim.fn.writefile(lines, sticker_path)

      list.add(sticker_item)

      vim.api.nvim_set_option_value("modified", false, { buf = buf })
      vim.api.nvim_win_close(win, true)
    end,
  })
end

local function get_sticker_win_conf()
  local width = vim.o.columns

  local col = width - 40

  return {
    width = 35,
    height = 15,
    row = 1,
    col = col,
    relative = "editor",
    border = "single",
    style = "minimal",
    focusable = false,
  }
end

function M.remove()
  if active_sticker_win_id then
    vim.api.nvim_win_close(active_sticker_win_id, true)
  end
end

function M.unfold()
  if active_sticker_win_id then
    vim.api.nvim_win_set_config(active_sticker_win_id, get_full_note_conf())
    vim.api.nvim_set_current_win(active_sticker_win_id)
  end
end

function M.fold()
  if active_sticker_win_id then
    local handler_buf = vim.api.nvim_win_get_buf(active_sticker_win_id)
    if not vim.api.nvim_get_option_value("modified", { buf = handler_buf }) then
      vim.api.nvim_win_set_config(active_sticker_win_id, get_sticker_win_conf())
    else
      vim.api.nvim_win_set_config(active_sticker_win_id, get_sticker_win_conf())
      vim.notify("The buffer is saved and has not been changed.", vim.log.levels.WARN)
    end
  end
end

function M.show(file_name)
  local buf = vim.fn.bufnr(core.get_sticker_path(file_name), true)
  if active_sticker_win_id then
    vim.api.nvim_win_set_buf(active_sticker_win_id, buf)
  else
    active_sticker_win_id = vim.api.nvim_open_win(buf, true, get_sticker_win_conf())
  end
end

return M
