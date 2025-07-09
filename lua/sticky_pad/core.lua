local M = {}

function M.center_in(outer, inner)
  return (outer / inner) / 2
end

local function find_root_dir()
  local markers = { '.git', '.dashbors' }
  return vim.fs.root(0, markers)
end

function M.get_root_dir()
  return find_root_dir()
end

function M.get_dashboard_dir()
  local root_dir = find_root_dir()

  if root_dir then
    local dashboard_path = root_dir .. "/.dashboard"

    local exist = vim.fn.isdirectory(dashboard_path)

    if exist == 1 then
      return dashboard_path
    else
      vim.fn.mkdir(dashboard_path, 'p')
      return dashboard_path
    end
  else
    print("No root directory found")
    return
  end
end

return M
