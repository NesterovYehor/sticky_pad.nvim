---@class Results The resutls opts
---@field width integer The width of results window.
---@field height integer The height of the results window.
---@field win integer The results window.

---@class Preview The preview opts
---@field width integer The width of preview window.
---@field height integer The height of the preview window.
---@field win integer The preview window.

---@class Layout The Layout opts
---@field width integer The width of layout window.
---@field height integer The height of the layout window.
---@field win integer The layout window.


---@class Floats
---@field layout Layout
---@field results Results
---@field preview Preview

---@class Dashboard
---@field floats Floats The windows
---@field results_buf integer The buf of results window.
---@field preview_buf integer The buf of preview window.
---@field callback function The function to call when an item is selected.
---@field results_list string[] The list of all file names that we got from list.

local Dashboard = {}
Dashboard.__index = Dashboard

local dashboard_dir = ""
local core = require("sticky_pad.core")
local list = require("sticky_pad.list")

local is_closing = false

--- @param callback function
--- @return table
function Dashboard.new(callback)
  dashboard_dir = core.get_dashboard_dir()
  local instance = {
    results_buf  = 0,
    preview_buf  = 0,
    callback     = callback,
    results_list = {},
    floats       = {
      layout = {
        width = 0,
        height = 0,
        win = 0,
      },
      results = {
        width = 0,
        height = 0,
        win = 0,
      },
      preview = {
        width = 0,
        height = 0,
        win = 0,
      },
    }
  }
  setmetatable(instance, Dashboard)
  return instance
end

-- Close Dashboard Helpers
function Dashboard:close_all_windows()
  if is_closing then
    return
  end
  is_closing = true

  if vim.api.nvim_win_is_valid(self.floats.results.win) then
    vim.api.nvim_win_close(self.floats.results.win, true)
  end
  if vim.api.nvim_win_is_valid(self.floats.preview.win) then
    vim.api.nvim_win_close(self.floats.preview.win, true)
  end
  if vim.api.nvim_win_is_valid(self.floats.layout.win) then
    vim.api.nvim_win_close(self.floats.layout.win, true)
  end

  is_closing = false
end

function Dashboard:setup_close_keymap()
  local self = self
  vim.keymap.set('n', 'q', function()
    self:close_all_windows()
  end, {
    buffer = self.results_buf,
    silent = true,
    desc = "Close Dashboard",
  })
end

function Dashboard:set_inner_window_opts()
  local padding = 2
  local inner_width = self.floats.layout.width - 2
  local inner_height = self.floats.layout.height - 2

  self.floats.results.width = math.floor(inner_width * 0.3)
  local preview_col = padding + self.floats.results.width + padding
  self.floats.preview.width = inner_width - preview_col - padding
  self.floats.preview.height = inner_height - padding
  self.floats.results.height = inner_height - padding

  return {
    results = {
      width = self.floats.results.width,
      height = self.floats.results.height,
      row = 1,
      col = padding,
    },
    preview = {
      width = self.floats.preview.width,
      height = self.floats.preview.height,
      row = 1,
      col = preview_col,
    },
  }
end

function Dashboard:set_inner_windows(opts)
  local results_win_opts = vim.tbl_deep_extend("force", opts.results, {
    relative = "win",
    win = self.floats.layout.win,
    border = "rounded",
    style = "minimal",
  })

  local preview_win_opts = vim.tbl_deep_extend("force", opts.preview, {
    relative = "win",
    win = self.floats.layout.win,
    border = "rounded",
    focusable = false,
    style = "minimal",
  })

  self.floats.preview.win = vim.api.nvim_open_win(self.preview_buf, false, preview_win_opts)
  self.floats.results.win = vim.api.nvim_open_win(self.results_buf, true, results_win_opts)
  vim.api.nvim_win_set_cursor(self.floats.results.win, { 1, 0 })
end

function Dashboard:create_layout(buf)
  local width = vim.o.columns
  local height = vim.o.lines

  self.floats.layout.width = math.floor(width * 0.35)
  self.floats.layout.height = math.floor(height * 0.6)

  self.floats.layout.win = vim.api.nvim_open_win(buf, false, {
    width = self.floats.layout.width,
    height = self.floats.layout.height,
    row = math.floor((height - self.floats.layout.height) / 2),
    col = math.floor((width - self.floats.layout.width) / 2),
    border = "rounded",
    style = "minimal",
    relative = "editor",
    focusable = false,
  })
end

local function normalized_result_name(name, max_length)
  if max_length and max_length > 5 and #name > max_length then
    name = string.sub(name, 1, max_length - 5) .. "..."
  end
  return name
end

local function get_results_buf(max_length)
  local stickers = {}
  local file_name_list = {}

  for item in list.iter() do
    local clean_title = normalized_result_name(item.title, max_length)
    table.insert(stickers, clean_title)
    table.insert(file_name_list, item.file_name)
  end

  return stickers, file_name_list
end

function Dashboard:refresh_results_list()
  local stickers, file_names_list = get_results_buf(self.floats.results.width)
  vim.api.nvim_buf_set_lines(self.results_buf, 0, -1, false, stickers)
  vim.api.nvim_win_set_cursor(self.floats.results.win, { 1, 0 })
  self.results_list = file_names_list
  return true
end

-- Preview Helpers
local function update_preview_buffer(buf, path)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("0read " .. vim.fn.fnameescape(path))
  end)
end


function Dashboard:get_selected_file_name()
  local win_id = self.floats.results.win
  print(win_id)
  local current_line = core.get_current_line_number(win_id)
  return self.results_list[current_line]
end

function Dashboard:update_preview()
  local file_path = dashboard_dir .. "/" .. self:get_selected_file_name()
  update_preview_buffer(self.preview_buf, file_path)
end

function Dashboard:setup_preview_autocmd()
  local self = self
  local group = vim.api.nvim_create_augroup("StickyPadPreview", { clear = true })
  vim.api.nvim_create_autocmd('CursorMoved', {
    group = group,
    buffer = self.results_buf,
    callback = function()
      self:update_preview()
    end,
  })
end

function Dashboard:setup_keymaps()
  local self = self
  vim.keymap.set('n', 'dd', function()
    self:delete_sticker()
    self:refresh_results_list()
    local lines = vim.api.nvim_buf_get_lines(self.results_buf, 0, -1, false)
    if #lines == 0 then
      self:close_all_windows()
    end
  end, { buffer = self.results_buf })
  vim.keymap.set('n', '<Enter>', function()
    local file_name = self:get_selected_file_name()
    self:close_all_windows()

    if self.callback then
      self.callback(file_name)
    end
  end, { buffer = self.results_buf, silent = true, desc = "Select Note" })
end

function Dashboard:show()
  if list.is_empty() then
    print("There no sticers avalible")
    return
  end
  local layout_buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('bufhidden', "wipe", { buf = layout_buf })
  self:create_layout(layout_buf)

  local opts = self:set_inner_window_opts()
  self.results_buf = vim.api.nvim_create_buf(false, false)
  self:refresh_results_list()
  vim.api.nvim_set_option_value('bufhidden', "wipe", { buf = self.results_buf })
  self.preview_buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('bufhidden', "wipe", { buf = self.preview_buf })

  self:set_inner_windows(opts)

  self:setup_close_keymap()

  self:setup_preview_autocmd()
  self:setup_keymaps()
end

return Dashboard
