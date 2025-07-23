local test_path = vim.loop.cwd() .. "/temp/"

local list = require("sticky_pad.list")
local pad = {}


local test_items = {
  {
    title = "test",
    top_line = 1,
    file_name = "test_one.md",
    is_last_used = true
  }, {
  title = "test",
  top_line = 1,
  file_name = "test_two.md",
  is_last_used = false
}
}
local test_content = "this is the preview content for test.md"


local function delete_temp()
  vim.fn.delete(test_path, "rf")

  -- clean up any floating windows that might be left over from a failed test
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win_id).relative ~= "" then
      vim.api.nvim_win_close(win_id, true)
    end
  end
end

describe("pad.lua", function()
  before_each(function()
    delete_temp()
    vim.fn.mkdir(test_path, "p")
    list.new(test_path .. "metadata.json")
    pad = require("sticky_pad.pad").new(function(file_name)
      require("sticky_pad.sticker").show(file_name)
    end, test_path)
    list.add(test_items[1])
    list.add(test_items[2])
    test_content = "this is the preview content for test.md"
    vim.fn.writefile({ test_content }, test_path .. test_items[1].file_name)
    vim.fn.writefile({ test_content }, test_path .. test_items[2].file_name)
  end)


  after_each(function()
    delete_temp()
  end)

  it("should create a pad with one elemnt in list", function()
    pad:show()
    vim.wait(100)
    local float_wins_num = 0
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
      local config = vim.api.nvim_win_get_config(win_id)

      if config.relative ~= "" then
        float_wins_num = float_wins_num + 1
      end
    end
    assert.are.equals(3, float_wins_num)
    local lines = vim.api.nvim_buf_get_lines(pad.results_buf, 0, -1, true)

    assert.are.equals(2, #lines)
    assert.are.equals(#test_items[1].title, #lines[1])
    assert.are.equals(test_items[1].title, lines[1])

    lines = vim.api.nvim_buf_get_lines(pad.preview_buf, 0, -1, true)
    assert.are.equals(test_content, lines[1])
  end)

  it("should  remove elemnt form pad", function()
    pad:show()
    vim.wait(100)
    local lines = vim.api.nvim_buf_get_lines(pad.results_buf, 0, -1, true)
    assert.are.equals(2, #lines)
    pad:delete_sticker()
    pad:refresh_results_list()
    pad:update_preview()
    lines = vim.api.nvim_buf_get_lines(pad.results_buf, 0, -1, true)
    assert.are.equals(1, #lines)
  end)
end)
