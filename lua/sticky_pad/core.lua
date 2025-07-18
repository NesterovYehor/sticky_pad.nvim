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
  local cursor_pos = vim.api.nvim_win_get_cursor(win_id)
  local current_row = cursor_pos[1]
  return current_row
end

return Core
