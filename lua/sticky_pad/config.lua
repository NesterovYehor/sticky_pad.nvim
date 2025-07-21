---@class Config
---@field sticker_width integer
---@field sticker_height integer
---@field col integer
---@field row integer
---@field padding integer
---@field position string

local Config = {}
Config.__index = Config

local default_width = math.floor(vim.o.columns * 0.15)
local config = {
  sticker_width = default_width,
  sticker_height = math.floor(default_width / 2),
  position = "",
  col = 0,
  row = 0,
  padding = 2
}

local cases = {
  ["top-left"] = function() return { 1, 1 } end,
  ["bottom-left"] = function() return { vim.o.lines - config.sticker_height - config.padding, 1 } end,
  ["bottom-right"] = function()
    return { vim.o.lines - config.sticker_height - config.padding, vim.o.columns - config.sticker_width - config.padding }
  end,
  default = function() return { 1, vim.o.columns - config.sticker_width - config.padding } end,
}


function Config.set(opts)
  for k, v in pairs(opts) do
    if not config[k] then
      print("Unknown option for configuraiton of pluguin: ", k)
      goto continue
    end
    config[k] = v
    ::continue::
  end
  local cords = (cases[config.position] or cases.default)()
  config.row = cords[1]
  config.col = cords[2]
end

function Config.get()
  return config
end

return Config
