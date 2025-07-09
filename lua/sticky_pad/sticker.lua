local M = {}


local active_sticker_win_id

local core = require("sticky_pad.core")
local function sanitize_slug(slug)
  local slug_without_spaces = string.gsub(slug, " ", "-")
  local cleaned_slug = string.gsub(slug_without_spaces, "-+", "-")

  cleaned_slug = string.gsub(cleaned_slug, "^-", "")

  cleaned_slug = string.gsub(cleaned_slug, "-$", "")

  return cleaned_slug
end


local function open_full_note(opts)
  local width = math.min(math.floor(vim.o.columns * 0.8), 50)
  local height = math.floor(vim.o.lines * 0.8)
  local win_opst = {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 5,
    row = 5,
    border = "single"
  }

  if opts.buff then
    vim.api.nvim_open_win(opts.buff, true, win_opst)
  end
end

function M.new()
  local dashboard_dir = core.get_dashboard_dir()
  local augroup = vim.api.nvim_create_augroup("StickyPad", { clear = true })
  if dashboard_dir then
    local curr_time = os.time()
    local buff = vim.api.nvim_create_buf(false, false)
    vim.keymap.set('n', 'q', ':q<CR>', {
      buffer = buff,
      silent = true,
      desc = "New sticker created"
    })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      buffer = buff,
      desc = "Save sticker note content to file",
      callback = function()
        local lines = vim.api.nvim_buf_get_lines(buff, 0, 1, false)
        for _, line in ipairs(lines) do
          if #line > 0 then
            local sticker_path = dashboard_dir ..
                "/" .. tostring(curr_time) .. "-" .. sanitize_slug(line) .. ".md"
            vim.api.nvim_buf_set_name(buff, sticker_path)
          end
        end
      end
    })
    vim.api.nvim_buf_set_name(buff, tostring(curr_time))
    open_full_note({ buff = buff })
  end
end

local function set_sticker_win(buf)
  local width = vim.o.columns

  local col = width - 35

  local win_conf = {
    width = 30,
    height = 15,
    row = 1,
    col = col,
    relative = "editor",
    border = "single",
    style = "minimal",
  }

  local win = vim.api.nvim_open_win(buf, true, win_conf)
  return win
end

function M.remove()
  if active_sticker_win_id then
    vim.api.nvim_win_close(active_sticker_win_id, true)
  end
end

function M.show(file_path)
  local buf = vim.fn.bufnr(file_path, true)
  if active_sticker_win_id then
    vim.api.nvim_win_set_buf(active_sticker_win_id, buf)
  else
    active_sticker_win_id = set_sticker_win(buf)
  end
end

return M
