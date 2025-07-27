---@class Sticker_Config
---@field width integer
---@field height integer
---@field col integer
---@field row integer
---@field position string

---@class Config
---@field sticker Sticker_Config
---@field padding integer

local Config = {}
Config.__index = Config

-- This table holds the final, merged configuration.
local config = {}

-- Helper function to set up the default values.
-- We use a function so we can reset it for testing.
local function set_defaults()
  local default_width = math.floor(vim.o.columns * 0.15)
  config = {
    sticker = {
      width = default_width,
      height = math.floor(default_width / 2),
      position = "top-right",
      col = vim.o.columns - default_width - 2,
      row = 2,
    },
    padding = 2,
  }
end

-- Initialize the defaults when the module is loaded.
set_defaults()


-- This dispatch table calculates coordinates based on the sticker's position.
-- It now correctly references the nested config table.
local cases = {
  ["top-left"] = function()
    return { config.padding, config.padding }
  end,
  ["bottom-left"] = function()
    return { vim.o.lines - config.sticker.height - config.padding, config.padding }
  end,
  ["bottom-right"] = function()
    return {
      vim.o.lines - config.sticker.height - config.padding,
      vim.o.columns - config.sticker.width - config.padding,
    }
  end,
  -- Default is "top-right"
  default = function()
    return { config.padding, vim.o.columns - config.sticker.width - config.padding }
  end,
}

-- This function merges the user's options and calculates the final position.
function Config.set(opts)
  -- Reset to defaults to ensure a clean slate before applying user options.
  set_defaults()

  -- Use vim.tbl_deep_extend to cleanly merge the user's nested options.
  config = vim.tbl_deep_extend("force", config, opts or {})

  -- Now that the config is updated, calculate the final row and column.
  local cords = (cases[config.sticker.position] or cases.default)()
  config.sticker.row = cords[1]
  config.sticker.col = cords[2]
end

function Config.get()
  return config
end

return Config

