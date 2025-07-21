local Core = {}
local data_path = string.format("%s/sticker.pad", vim.fn.stdpath("data"))

function Core.center_in(outer, inner)
  return (outer / inner) / 2
end

function Core.sanitize_slug(slug)
  local slug_without_spaces = string.gsub(slug, " ", "-")
  local cleaned_slug = string.gsub(slug_without_spaces, "-+", "-")

  cleaned_slug = string.gsub(cleaned_slug, "^-", "")

  cleaned_slug = string.gsub(cleaned_slug, "-$", "")

  return cleaned_slug
end

function Core.fullpath()
  local hash = vim.fn.sha256(vim.loop.cwd())
  return string.format("%s/%s", data_path, hash)
end

function Core.get_dashboard_dir()
  local path = Core.fullpath()

  local exist = vim.fn.isdirectory(path)

  if exist == 0 then
    vim.fn.mkdir(path, 'p')
  end
  return path
end

function Core.get_sticker_path(file_name)
  return string.format("%s/%s", Core.get_dashboard_dir(), file_name)
end

function Core.get_current_line_number(win_id)
  -- This runs vim.fn.winline() inside the specified window
  -- and returns its visual line number.
  return vim.api.nvim_win_call(win_id, function()
    return vim.fn.winline()
  end)
end

---@param buf_id integer
---@param win_width integer
function Core.get_line_number(buf_id, win_width)
  local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
  local chars_num = 0
  for _, line in pairs(lines) do
    chars_num = chars_num + #line
  end
  return #lines + math.floor(chars_num / win_width)
end

return Core
