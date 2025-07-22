local list = require("sticky_pad.list")
local test_path = vim.loop.cwd() .. "/test_metadata.json"
list.new(test_path)
local test_item = {
  title = "test-title",
  top_line = 1,
  file_name = "test-title.md",
  is_last_used = true
}

describe("list.lua", function()
  before_each(function()
    pcall(os.remove, test_path)
    list.new(test_path)
    test_item = {
      title = "test-title",
      top_line = 1,
      file_name = "test-title.md",
      is_last_used = true
    }
  end)

  after_each(function()
    pcall(os.remove, test_path)
  end)

  it("should add a new item to the list", function()
    list.add(test_item)

    assert.are.equal(test_item, list.get_items()[test_item.file_name])
    assert.are.same(test_item, list.get_by_file_name(test_item.file_name))
  end)

  it("should update an existing item", function()
    list.add(test_item)

    list.update_item(test_item.file_name, { is_last_used = false })

    local updated_item = list.get_by_file_name(test_item.file_name)
    assert.is_false(updated_item.is_last_used)
  end)

  it("should get item from list by name", function()
    list.add(test_item)

    local item = list.get_by_file_name(test_item.file_name)
    assert.are.equals(item, test_item)
  end)

  it("should get last used item from list", function()
    list.add(test_item)

    assert.are.equals(test_item.is_last_used, true)
    assert.are.equals(test_item, list.get_last_used())
  end)

  it("should remove item from list", function()
    list.add(test_item)
    assert.are.equals(test_item, list.get_items()[test_item.file_name])
    list.remove(test_item.file_name)
    assert.are.equals(list.is_empty(), true)
  end)

  it("should create metadata.json file and write there", function()
    list.add(test_item)
    list.sync(test_path)

    list.new(test_path)

    assert.are.same(test_item, list.get_by_file_name(test_item.file_name))
  end)
end)
