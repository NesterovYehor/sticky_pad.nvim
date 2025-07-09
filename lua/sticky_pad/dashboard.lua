local M = {}


---@class layout
---@field win
---@field width
---@field height
local Layout = {}

local core = require("sticky_pad.core")

local acive_windows = {}
local sticker_path_map = {}

function M.create()
  core.get_dashboard_dir()
end

-- Close Dashboard Helpers
local function close_all_widows()
  for _, win_id in pairs(acive_windows) do
    vim.api.nvim_win_close(win_id, true)
  end
end

local function setup_close_keymap(buf)
  vim.keymap.set('n', 'q', function()
    close_all_widows()
  end, {
    buffer = buf,
    silent = true,
    desc = "Close Dashboard"
  })
end

local function setup_close_autocmd(buf)
  local augroup = vim.api.nvim_create_augroup("StickyPad", { clear = true })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = augroup,
    buffer = buf,
    callback = function()
      close_all_widows()
    end
  })
end

local function setup_close_funcs(buf)
  setup_close_keymap(buf)
  setup_close_autocmd(buf)
end


---@param layout Layout
local function get_inner_window_opts(layout)
  local padding = 2
  local inner_width = layout.width - padding
  local inner_height = layout.height - padding
  -- Results opts
  local results_col = padding
  local results_width = math.floor(inner_width * 0.4)

  -- Preview opts
  local preview_col = padding + results_width + padding
  local preview_width = inner_width - preview_col - padding

  return {
    results_col = results_col,
    results_width = results_width,
    preview_col = preview_col,
    preview_width = preview_width,
    padding = padding,
    height = inner_height - padding,

  }
end
local function set_inner_windows(layout, results_buf, preview_buf)
  local opts = get_inner_window_opts(layout)
  local results_win_opts = {
    width = opts.results_width,
    height = opts.height,
    row = 1,
    col = opts.results_col,
    relative = "win",
    win = layout.win,
    border = "single",
  }

  local preview_win_opts = {
    width = opts.preview_width,
    height = opts.height,
    row = 1,
    col = opts.preview_col,
    relative = "win",
    win = layout.win,
    border = "single",
    focusable = false,
  }
  local preview_win = vim.api.nvim_open_win(preview_buf, true, preview_win_opts)
  local results_win = vim.api.nvim_open_win(results_buf, true, results_win_opts)

  return {
    results_win = results_win,
    preview_win = preview_win
  }
end
local function create_layout(opts)
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.65 - 4)
  local win_width = math.ceil(width * 0.3)

  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local window_opts = {
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = "single",
    style = "minimal",
    relative = "editor",
    focusable = false
  }

  local win_id = vim.api.nvim_open_win(opts.buf, true, window_opts)

  return {
    win = win_id,
    width = win_width,
    height = win_height,
  }
end

local function get_results_buf()
  local dashboard_dir = core.get_dashboard_dir()
  local stickers = {}
  local handle_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('bufhidden', "wipe", { buf = handle_buf })

  if not dashboard_dir then return stickers end -- Safety check

  for name, type in vim.fs.dir(dashboard_dir) do
    if type == "file" then
      local _, slug = string.match(name, "^(%d+)-(.-)%.md$")
      if slug then
        table.insert(stickers, slug)
        local full_path = dashboard_dir .. "/" .. name
        sticker_path_map[slug] = full_path
      end
    end
  end

  vim.api.nvim_buf_set_lines(handle_buf, 0, -1, false, stickers)
  return handle_buf
end

-- Preview Helpers

local function update_preview_buffer(buf, path)
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("0read" .. vim.fn.fnameescape(path))
  end)
end

local function get_current_note_path(results_buf, results_win)
  local cursor_pos = vim.api.nvim_win_get_cursor(results_win)
  local current_row = cursor_pos[1]
  local lines = vim.api.nvim_buf_get_lines(results_buf, current_row - 1, current_row, false)
  local current_line = lines[1]
  return sticker_path_map[current_line]
end

local function on_cursor_moved(results_buf, results_win, preview_buf)
  local file_path = get_current_note_path(results_buf, results_win)
  if file_path then
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {})
    update_preview_buffer(preview_buf, file_path)
  end
end



local function setup_preview_autocmd(results_buf, preview_buf, results_win)
  local group = vim.api.nvim_create_augroup("StickyPad", { clear = true })
  vim.api.nvim_create_autocmd('CursorMoved', {
    group = group,
    buffer = results_buf,
    callback = function()
      on_cursor_moved(results_buf, results_win, preview_buf)
    end
  })
end

local function setup_select_keymap(callback, results_buf, results_win)
  vim.keymap.set('n', '<Enter>', function()
    local selected_path = get_current_note_path(results_buf, results_win)

    close_all_widows()

    if selected_path then
      callback(selected_path)
    end
  end)
end

function M.show(callback)
  local results_buf = get_results_buf()
  local layout_buf = vim.api.nvim_create_buf(false, false)
  local preview_buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('bufhidden', "wipe", { buf = preview_buf})

  local layout = create_layout({ buf = layout_buf })
  local inner_windows = set_inner_windows(layout, results_buf, preview_buf)

  acive_windows = { layout.win, inner_windows.results_win, inner_windows.preview_win }

  setup_close_funcs(layout_buf)
  setup_close_funcs(results_buf)

  setup_preview_autocmd(results_buf, preview_buf, inner_windows.results_win)

  setup_select_keymap(callback, results_buf, inner_windows.results_win)
end

return M
