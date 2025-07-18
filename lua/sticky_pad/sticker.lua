local M = {}

local core = require("sticky_pad.core")
local list = require("sticky_pad.list")

-- This is the private, internal state for the one active sticker.
local active_sticker = {
  win_id = 0,
  buf_id = 0,
  top_line = 1,
  file_name = "",
}

-- Helper function to get the configuration for the "full note" editing window.
local function get_full_note_conf()
  local width = 35
  local height = math.floor(vim.o.lines * 0.8)
  return {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 5,
    row = 5,
    border = "single",
    focusable = true,
  }
end

-- Helper function to get the configuration for the small "sticker" view.
local function get_sticker_win_conf()
  local col = vim.o.columns - 40
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
-- This is your restored create function, with necessary fixes.
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

  -- Give the buffer a temporary name to allow :w to work.
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

      -- Tell Neovim the save was successful.
      vim.api.nvim_set_option_value("modified", false, { buf = buf })
      vim.api.nvim_win_close(win, true)
    end,
  })
end

-- This function displays a sticker on the screen.
function M.show(file_name)
  if list.get_last_used() then
    list.update_item(list.get_last_used().file_name, { is_last_used = true })
  end
  local list_item = list.get_by_file_name(file_name)
  active_sticker.buf_id = vim.fn.bufnr(core.get_sticker_path(file_name), true)
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = active_sticker.buf_id })

  active_sticker.file_name = file_name
  active_sticker.top_line = list_item.top_line or 1

  -- If no sticker is currently active, create a new window.
  if active_sticker.win_id == 0 then
    active_sticker.win_id = vim.api.nvim_open_win(active_sticker.buf_id, false, get_sticker_win_conf())
    vim.api.nvim_set_option_value('wrap', true, { win = active_sticker.win_id })
    vim.api.nvim_set_option_value('linebreak', true, { win = active_sticker.win_id })
  else
    vim.api.nvim_win_set_buf(active_sticker.win_id, active_sticker.buf_id)
  end
  list.update_item(active_sticker.file_name, { is_last_used = true })

  -- Now, call the central refresh function to update the view.
  refresh_sticker()
end

-- This function closes the active sticker.
function M.remove()
  if vim.api.nvim_win_is_valid(active_sticker.win_id) then
    vim.api.nvim_win_close(active_sticker.win_id, true)
    active_sticker.win_id = 0
  end
end

-- This function "unfolds" the sticker into the editing view.
function M.unfold()
  if vim.api.nvim_win_is_valid(active_sticker.win_id) then
    vim.api.nvim_win_set_config(active_sticker.win_id, get_full_note_conf())
    vim.api.nvim_set_current_win(active_sticker.win_id)
  end
end

-- This function "folds" the editing view back into a sticker.
function M.fold()
  if vim.api.nvim_win_is_valid(active_sticker.win_id) then
    local buf = vim.api.nvim_win_get_buf(active_sticker.win_id)
    if vim.api.nvim_get_option_value("modified", { buf = buf }) then
      vim.notify("Save your changes first with :w", vim.log.levels.WARN)
      return
    end

    active_sticker.top_line = core.get_current_line_number(active_sticker.win_id)
    list.update_item(active_sticker.file_name, { top_line = active_sticker.top_line })

    vim.api.nvim_win_set_config(active_sticker.win_id, get_sticker_win_conf())
    -- Restore the scroll position.
    refresh_sticker()
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
return M
