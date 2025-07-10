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

local function get_full_note_conf()
  local width = 35
  local height = math.floor(vim.o.lines * 0.8)
  local win_opst = {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 5,
    row = 5,
    border = "single",
    focusable = true,
  }
  return win_opst
end


function M.new()
  local dashboard_dir = core.get_dashboard_dir()
  local augroup = vim.api.nvim_create_augroup("StickyPad", { clear = true })
  if dashboard_dir then
    local curr_time = os.time()
    local buf = vim.api.nvim_create_buf(false, false)
    vim.keymap.set('n', 'q', ':q<CR>', {
      buffer = buf,
      silent = true,
      desc = "New sticker created"
    })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      buffer = buf,
      desc = "Save sticker note content to file",
      callback = function()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
        for _, line in ipairs(lines) do
          if #line > 0 then
            local sticker_path = dashboard_dir ..
                "/" .. tostring(curr_time) .. "-" .. sanitize_slug(line) .. ".md"
            vim.api.nvim_buf_set_name(buf, sticker_path)
          end
        end
      end
    })
    vim.api.nvim_buf_set_name(buf, tostring(curr_time))
    vim.api.nvim_open_win(buf, true, get_full_note_conf())
  end
end

local function get_sticker_win_conf()
  local width = vim.o.columns

  local col = width - 40

  return {
    width = 35,
    height = 15,
    row = 1,
    col = col,
    relative = "editor",
    border = "single",
    style = "minimal",
    focusable = false,
  }
end

function M.remove()
  if active_sticker_win_id then
    vim.api.nvim_win_close(active_sticker_win_id, true)
  end
end

function M.unfold()
  if active_sticker_win_id then
    vim.api.nvim_win_set_config(active_sticker_win_id, get_full_note_conf())
    vim.api.nvim_set_current_win(active_sticker_win_id)
  end
end

function M.fold()
  if active_sticker_win_id then
    local handler_buf = vim.api.nvim_win_get_buf(active_sticker_win_id)
    if not vim.api.nvim_get_option_value("modified", { buf = handler_buf }) then
      vim.api.nvim_win_set_config(active_sticker_win_id, get_sticker_win_conf())
    else
      vim.api.nvim_win_set_config(active_sticker_win_id, get_sticker_win_conf())
      vim.notify("The buffer is saved and has not been changed.", vim.log.levels.WARN)
    end
  end
end

function M.show(file_path)
  local buf = vim.fn.bufnr(file_path, true)
  if active_sticker_win_id then
    vim.api.nvim_win_set_buf(active_sticker_win_id, buf)
  else
    active_sticker_win_id = vim.api.nvim_open_win(buf, true, get_sticker_win_conf())
  end
end

return M
