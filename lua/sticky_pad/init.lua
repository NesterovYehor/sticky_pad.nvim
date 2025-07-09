local M = {}
local dashboard = require("sticky_pad.dashboard")
local stickers = require("sticky_pad.sticker")

local function expand_path(path)
  if path:sub(1, 1) == "~" then
    return os.getenv("HOME") .. path:sub(2)
  end
  return path
end

local function win_config()
  local width = math.min(math.floor(vim.o.columns * 0.1), 50)
  local height = math.min(math.floor(vim.o.lines * 0.1), 50)
  return {
    relative = "editor",
    width = width,
    height = height,
    col = 1,
    row = 1,
    border = "single"
  }
end

local function open_floating_file(targe_file)
  local expanded_path = expand_path(targe_file)
  if vim.fn.filereadable(expanded_path) == 0 then
    vim.notify("todo file does not exist in directory:" .. expanded_path, vim.log.levels.ERROR)
  end
  local buf = vim.fn.bufnr(expanded_path, true)
  if buf == -1 then
    buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buf, expanded_path)
  end
  vim.bo[buf].swapfile = false
  local win = vim.api.nvim_open_win(buf, true, win_config())
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
    noremap = true,
    silent = true,
    callback = function()
      if vim.api.nvim_get_option_value("modified", { buf = buf }) then
        vim.notify("save your changes", vim.log.levels.WARN)
      else
        vim.api.nvim_win_close(0, true)
      end
    end
  })
end

local function setup_user_commands(opts)
  local targe_file = opts.targe_file or "todo.md"
  vim.api.nvim_create_user_command("Td", function()
    vim.notify("Hello from todo.lua!")
    open_floating_file(setup_user_commands(opts))
  end, {})
  vim.api.nvim_create_user_command("CreateDashboard", function()
    dashboard.create_dashboard()
  end, {})
  vim.api.nvim_create_user_command("NewSticker", function()
    stickers.new()
  end, {})
  vim.api.nvim_create_user_command("ShowDashboard", function()
    local callback = function(file_path)
      stickers.show(file_path)
    end
    dashboard.show(callback)
  end, {})
  vim.api.nvim_create_user_command("RS", function()
    stickers.remove()
  end, {})
  return targe_file
end

function M.setup(opts)
  setup_user_commands(opts)
end

return M
