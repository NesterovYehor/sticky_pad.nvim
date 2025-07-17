--- @class ListItem
--- @field file_name string Name of file with sticker's content
--- @field title string Title of sticker that used as title in dashboard and is a first line of sticker
--- @field is_last_used boolean Used to set last used sticker to screen while sutuping pluguin

--- @class List
--- @field items ListItem[]
--- @field last_used ListItem 


local core = require("sticky_pad.core")

local M = {}

local state = {
  items = {},
  last_used = nil,
}

local metadata_file_path = string.format("%s/metadata.json", core.get_dashboard_dir())

function M.new()
  state.items = {}
  state.last_used = nil

  local ok, data = pcall(function()
    if vim.fn.filereadable(metadata_file_path) == 0 then
      return {}
    end
    local json_string = table.concat(vim.fn.readfile(metadata_file_path), "\n")
    return vim.json.decode(json_string)
  end)

  if not ok then
    data = {}
  end

  for key, values in pairs(data) do
    local item = {
      file_name = key,
      title = values["title"],
      is_last_used = values["is_last_used"],
    }
    if item.is_last_used then
      state.last_used = item
    end
    table.insert(state.items, item)
  end
end

function M.iter()
  local i = 0
  local items = state.items

  return function()
    i = i + 1
    return items[i]
  end
end

function M.get_all()
  return state.items
end

function M.get_by_index(i)
  local itme = state.items[i]
  return itme
end

function M.add(item)
  table.insert(state.items, item)
end

function M.get_last_used()
  return state.last_used
end

function M.sync()
  local data = {}
  for _, item in ipairs(state.items) do
    data[item.file_name] = {
      title = item.title,
      is_last_used = item.is_last_used,
    }
  end
  local json_string = vim.json.encode(data)
  vim.fn.writefile({ json_string }, metadata_file_path)
end

function M.remove(i)
  table.remove(state.items, i)
end

function M.is_empty()
  return #state.items == 0
end

return M
