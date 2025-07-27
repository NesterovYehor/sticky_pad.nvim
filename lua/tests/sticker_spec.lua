local list = require("sticky_pad.list")
local stickers = {}
local test_path = vim.loop.cwd() .. "/temp_data/"
local test_item = {
  title = "test-title",
  top_line = 1,
  file_name = "test-title.md",
  is_last_used = true
}

local test_content = ""
local function floating_windows_num()
  local float_wins_num = 0
  local sticker_winid = 0
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win_id)
    if config.relative ~= "" then
      float_wins_num = float_wins_num + 1
      sticker_winid = win_id
    end
  end
  return float_wins_num, sticker_winid
end

describe("sticker.lua", function()
  before_each(function()
    local fake_core = {
      get_pad_dir = function()
        return test_path
      end,
      get_sticker_path = function(file_name)
        return test_path .. file_name
      end,
      get_current_line_number = function()
        return 1
      end,
      get_line_number = function()
        return 1
      end

    }
    package.loaded["sticky_pad.core"] = fake_core
    stickers = require("sticky_pad.sticker")

    vim.fn.delete(test_path, "rf")
    vim.fn.mkdir(test_path, "p")
    list.new(test_path .. "metadata.json")
    list.add(test_item)
    test_content = "this is the preview content for test.md"
    vim.fn.writefile({ test_content }, test_path .. test_item.file_name)
    stickers.reset()
  end)

  after_each(function()
    vim.fn.delete(test_path, "rf")
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win_id).relative ~= "" then
        vim.api.nvim_win_close(win_id, true)
      end
    end
  end)

  it("should set sticker of screen", function()
    stickers.show(test_item.file_name)
    vim.wait(100)
    local float_wins_num, sticker_win_id = floating_windows_num()
    assert.equals(1, float_wins_num)
    local buf = vim.api.nvim_win_get_buf(sticker_win_id)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    assert.equals(1, #lines)
    assert.equals(test_content, lines[1])
  end)

  it("should unfold sticker", function()
    stickers.show(test_item.file_name)
    vim.wait(100)
    stickers.unfold()
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
      local config = vim.api.nvim_win_get_config(win_id)
      if config.relative ~= "" then
        assert.equals(math.floor(vim.o.lines * 0.9), config.height)
      end
    end
  end)

  it("should fold sticker back", function()
    stickers.show(test_item.file_name)
    vim.wait(100)
    local _, sticker_win_id = floating_windows_num()

    local config = vim.api.nvim_win_get_config(sticker_win_id)
    local height = config.height

    stickers.unfold()

    config = vim.api.nvim_win_get_config(sticker_win_id)
    assert.equals(math.floor(vim.o.lines * 0.9), config.height)

    stickers.fold()

    config = vim.api.nvim_win_get_config(sticker_win_id)
    assert.equals(height, config.height)
  end)

  it("should remove sticker from screen", function()
    stickers.show(test_item.file_name)
    local float_wins_num, _ = floating_windows_num()
    assert.equals(1, float_wins_num)

    stickers.remove()

    float_wins_num, _ = floating_windows_num()
    assert.equals(0, float_wins_num)
  end)

  it("should create new sticker", function()
    list.remove(test_item.file_name)
    local float_wins_num, sticker_win_id = floating_windows_num()
    assert.equals(0, float_wins_num)

    stickers.create()
    float_wins_num, sticker_win_id = floating_windows_num()

    local buf = vim.api.nvim_win_get_buf(sticker_win_id)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { test_content })
    assert.equals(1, float_wins_num)

    vim.cmd("w")
    float_wins_num, _ = floating_windows_num()
    assert.equals(0, float_wins_num)
    assert.equals(false, list.is_empty())
  end)
end)
