local M = {}
local pad = require("sticky_pad.pad")
local stickers = require("sticky_pad.sticker")
local list = require("sticky_pad.list")
local config = require("sticky_pad.config")
local core = require("sticky_pad.core")
list.new(core.get_pad_dir() .. "/metadata.json")

local function open_pad()
  local my_pad = pad.new(function(file_name)
    stickers.show(file_name)
  end, core.get_pad_dir())

  my_pad:show()
end

local function setup_user_commands()
  vim.api.nvim_create_user_command("StickyPadCreate", function()
    stickers.create()
  end, {})
  vim.api.nvim_create_user_command("StickyPad", function()
    open_pad()
  end, {})
  vim.api.nvim_create_user_command("Down", function(opts)
    stickers.move_topline(opts.count)
  end, { count = 1 })
  vim.api.nvim_create_user_command("Up", function(opts)
    stickers.move_topline(-1 * opts.count)
  end, { count = 1 })
  vim.api.nvim_create_user_command("RemoveSticker", function()
    stickers.remove()
  end, {})
  vim.api.nvim_create_user_command("Unfold", function()
    stickers.unfold()
  end, {})
  vim.api.nvim_create_user_command("Fold", function()
    stickers.fold()
  end, {})
end


local function setup_autocmd()
  local group = vim.api.nvim_create_augroup("StickyPadSaveOnExit", { clear = true })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    desc = "Save sticker list before quitting",
    callback = function()
      list.sync(core.get_pad_dir().. "/metadata.json")
    end
  })
end

function M.setup(opts)
  config.set(opts)
  setup_user_commands()
  setup_autocmd()
  if list.get_last_used() then
    stickers.show(list.get_last_used().file_name)
  end
end

return M
