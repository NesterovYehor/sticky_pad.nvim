--- @class ListItem
--- @field file_name string Name of file with sticker's content
--- @field top_line integer Line number form which will start content of sticker
--- @field title string Title of sticker that used as title in dashboard and is a first line of sticker
--- @field is_last_used boolean Used to set last used sticker to screen while sutuping pluguin

--- @class List
--- @field items table<string, ListItem> A map of filename to ListItem.
--- @field last_used ListItem | nil

local M = {}

local state = {
  items = {},
  last_used = nil,
}


function M.new(metadata_file_path)
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
      top_line = values["top_line"],
    }
    if item.is_last_used then
      state.last_used = item
    end
    state.items[key] = item
  end
end

--- FIX: This iterator now correctly uses `pairs` to work with the hash map.
-- It returns an iterator that yields only the item objects, not the keys.
function M.iter()
  local key, value = next(state.items)
  return function()
    if key then
      local current_value = value
      key, value = next(state.items, key)
      return current_value
    end
  end
end


---@param key string
---@return ListItem
function M.get_by_file_name(key)
  return state.items[key]
end

function M.add(item)
  state.items[item.file_name] = item
  if item.is_last_used then
    if state.last_used then
      state.items[state.last_used.file_name].is_last_used = false
    end
    state.last_used = item
  end
end

function M.get_last_used()
  return state.last_used
end

---@param file_name string The key of the item to update.
---@param new_data table A table of new key-value pairs to apply.
function M.update_item(file_name, new_data)
  local item = state.items[file_name]
  if not item then
    return
  end

  for key, value in pairs(new_data) do
    item[key] = value
    if key == "is_last_used" and value then
      state.last_used = item
    end
  end
end

function M.sync(metadata_file_path)
  local data = {}
  for file_name, item in pairs(state.items) do
    data[file_name] = {
      title = item.title,
      is_last_used = item.is_last_used,
      top_line = item.top_line,
    }
  end
  local json_string = vim.json.encode(data)
  vim.fn.writefile({ json_string }, metadata_file_path)
end

---@param key string
function M.remove(key)
  state.items[key] = nil
end

function M.is_empty()
  return next(state.items) == nil
end

function M.get_items()
  return state.items
end

return M
