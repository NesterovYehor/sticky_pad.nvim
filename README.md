# sticky_pad.nvim

## What Is Sticky_pad?
A simple and lightweight note-taking plugin for Neovim. It lets you quickly jot down thoughts, todos, or code snippets in floating "sticky pads" without ever leaving your editor.

---
<!-- 
======================================================================
======================================================================
 VVVV                                                            VVVV
 VVVV       PASTE YOUR MAIN DEMO GIF URL IN THE LINE BELOW       VVVV
 VVVV                                                            VVVV
======================================================================
====================================================================== 
-->

![pad_preview](https://github.com/user-attachments/assets/8bcd4cf4-1874-4912-9ec3-2912f0eb5312)

---
## Contents

- [Getting Started](#getting-started)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

---

## Getting Started

1. **Install the plugin** using your favorite plugin manager and add `require("sticky_pad").setup()` somewhere in your Neovim config.

2. **Test** if it's working by creating your first note with the command `:StickyPadCreate`, typing a few lines, and saving with `:w`.

3. **Explore** your notes by opening the main view with the command `:StickyPad`.

After this setup, you can continue reading here or switch to `:help sticky_pad.nvim` to get a full understanding of how to use and configure the plugin.

## Installation

Install with your favorite plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- lua/plugins/sticky_pad.lua
return {
  "NesterovYehor/sticky_pad.nvim",
  -- You can optionally specify a version tag once you create one, e.g., version = "1.0.0"
  config = function()
    require("sticky_pad").setup()
  end,
}
```

##  Features

* **Floating Stickers:** Display your notes as unobtrusive, floating "sticky pads" on your screen.

* **Interactive Pad:** A clean, interactive UI to browse, preview, and manage all your notes.
<!-- 
======================================================================
 VVVV  (Optional) ADD A GIF/SCREENSHOT OF THE PAD UI HERE VVVV
====================================================================== 
-->


* **Dynamic Sizing:** Stickers automatically resize to fit their content, up to a configurable maximum height.

* **Seamless Editing:** Quickly "unfold" a sticker into a full editing window and "fold" it back when you're done.

* **Responsive UI:** The Pad automatically adjusts its layout when you resize your Neovim window.

* **Configurable:** Customize the size, position, and appearance of your stickers.


## Usage

It is recommended to map the plugin's functions to keybindings for easy access.

### Example Keymaps

Here are some example keymaps you can add to your configuration:

```lua
-- Get the plugin's modules
local sticker = require("sticky_pad.sticker")
local pad = require("sticky_pad.pad")

-- A callback function for the pad to open the selected sticker
local function open_sticker_callback(file_name)
  if file_name then
    sticker.show(file_name)
  end
end

-- Create a new sticker
vim.keymap.set("n", "<leader>sn", function()
  sticker.create()
end, { desc = "[S]ticker [N]ew" })

-- Open the Pad UI
vim.keymap.set("n", "<leader>sp", function()
  pad.new(open_sticker_callback):show()
end, { desc = "[S]ticker [P]ad" })

-- Show the last used sticker
vim.keymap.set("n", "<leader>sl", function()
  sticker.show_last_used()
end, { desc = "[S]ticker [L]ast Used" })

-- Remove the current sticker from the screen
vim.keymap.set("n", "<leader>sx", function()
  sticker.remove()
end, { desc = "[S]ticker Close [X]" })
```

### Commands

While keymaps are recommended, the plugin also provides the following commands:

* **`:StickyPadCreate`**: Opens a new window to create a sticker.
* **`:StickyPad`**: Opens the Pad UI to manage all stickers.
* **`:StickyPadShowLastUsed`**: Shows the most recently viewed sticker.
* **`:StickyPadRemove`**: Closes the currently active sticker.

## Configuration

This section should help you explore available options to configure and customize your `sticky_pad.nvim`.

### Setup Structure

Here is an example `setup()` call with all the default values:

```lua
require("sticky_pad").setup({
  sticker = {
    -- The position of the sticker on the screen.
    -- Options: "top-left", "bottom-left", "bottom-right", "top-right" (default)
    position = "top-right",

    -- The maximum height of the sticker window.
    -- The window will shrink to fit content if it's smaller than this.
    sticker_height = 15,

    -- The width of the sticker window.
    -- Default is calculated as 15% of the editor width.
    sticker_width = math.floor(vim.o.columns * 0.15),
  },
  -- The padding in cells from the editor edges.
  padding = 2,
})
```

## Contributing

Contributions are always welcome! Please feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. You can see the `LICENSE` file for details.

