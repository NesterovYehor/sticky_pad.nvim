local M = {}
local dashboard = require("sticky_pad.dashboard")
local stickers = require("sticky_pad.sticker")
local list = require("sticky_pad.list")
list.new()

local function open_dashboard()
  local my_dashboard = dashboard.new(function(file_name)
    stickers.show(file_name)
  end)

  my_dashboard:show()
end

local function setup_user_commands(opts)
  local targe_file = opts.targe_file or "todo.md"
  vim.api.nvim_create_user_command("NS", function()
    stickers.create()
  end, {})
  vim.api.nvim_create_user_command("SD", function()
    open_dashboard()
  end, {})
  vim.api.nvim_create_user_command("MD", function(opts)
    stickers.move_topline(opts.count)
  end, {count = 1})
  vim.api.nvim_create_user_command("MU", function(opts)
    stickers.move_topline(-1 * opts.count)
  end, {count = 1})
  vim.api.nvim_create_user_command("RS", function()
    stickers.remove()
  end, {})
  vim.api.nvim_create_user_command("Unfold", function()
    stickers.unfold()
  end, {})
  vim.api.nvim_create_user_command("Fold", function()
    stickers.fold()
  end, {})
  return targe_file
end


local function setup_autocmd()
  local group = vim.api.nvim_create_augroup("StickyPadSaveOnExit", { clear = true })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    desc = "Save sticker list before quitting",
    callback = list.sync
  })
end

function M.setup(opts)
  setup_user_commands(opts)
  setup_autocmd()
  if list.get_last_used() then
    stickers.show(list.get_last_used().file_name)
  end
end

return M
