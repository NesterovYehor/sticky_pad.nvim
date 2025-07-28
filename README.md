<!--
<img width="24" height="24" alt="sticky-note" src="https://github.com/user-attachments/assets/994c6c4b-ac92-4486-904c-372e9f7b5cb3" />
-->

<p align="center">
<img src="https://placehold.co/128x128/2c2d72/ffffff?text=Your+Logo" alt="sticky_pad.nvim Logo">
</p>

<h1 align="center">sticky_pad.nvim</h1>

<p align="center">
<a href="https://github.com/NesterovYehor/sticky_pad.nvim/actions/workflows/ci.yml">
<img src="https://github.com/NesterovYehor/sticky_pad.nvim/actions/workflows/ci.yml/badge.svg" alt="CI Status">
</a>
<img src="https://img.shields.io/badge/Neovim-0.9.0%2B-57A143?style=flat-square&logo=neovim" alt="Neovim Version">
<img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square" alt="License: MIT">
</p>

<p align="center">
A simple and lightweight note-taking plugin for Neovim. It lets you quickly jot down thoughts, todos, or code snippets in floating "sticky pads" without ever leaving your editor.
</p>

<!--
VVVV PASTE YOUR MAIN DEMO GIF HERE VVVV
This is the most important visual. It should showcase the main workflow.
-->

<p align="center">
<img src="https://placehold.co/800x450/2c2d72/ffffff?text=Your+Main+Plugin+Demo+GIF+Here" alt="sticky_pad.nvim Demo">
</p>

✨ Features
Floating Stickers: Display your notes as unobtrusive, floating "sticky pads" on your screen.

Interactive Pad: A clean, interactive UI to browse, preview, and manage all your notes.

Dynamic Sizing: Stickers automatically resize to fit their content, up to a configurable maximum height.

Seamless Editing: Quickly "unfold" a sticker into a full editing window and "fold" it back when you're done.

Responsive UI: The Pad automatically adjusts its layout when you resize your Neovim window.

Configurable: Customize the size, position, and appearance of your stickers.

🚀 Getting Started
Install the plugin using your favorite plugin manager and add require("sticky_pad").setup() somewhere in your Neovim config.

Test if it's working by creating your first note:

Run :StickyPadCreate.

Type a few lines.

Save and close the note with :w.

Explore your notes by opening the main view:

Run :StickyPad.

You should see your new note in the list.

Read the Configuration section below to see what options you can pass to the setup() call.

Read the Usage section to learn about all the available commands and keymaps.

📦 Installation
Install with your favorite plugin manager.

lazy.nvim
-- lua/plugins/sticky_pad.lua
return {
  "NesterovYehor/sticky_pad.nvim",
  -- You can optionally specify a version tag once you create one, e.g., version = "1.0.0"
  config = function()
    require("sticky_pad").setup()
  end,
}

⚙️ Configuration
The plugin works out of the box with sensible defaults. To configure it, you can pass an options table to the setup() function.

Here is an example with all the default values:

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

🕹️ Usage
Commands
Command

Description

:StickyPadCreate

Opens a new window to create a sticker.

:StickyPad

Opens the Pad UI to manage all stickers.

:StickyPadShowLastUsed

Shows the most recently viewed sticker.

:StickyPadRemove

Closes the currently active sticker.

Keymaps
These keymaps are only active in the appropriate windows.

In the Sticker Window
Key

Description

u

Unfolds the sticker to edit.

f

Folds the editing view back.

In the Pad Window
Key

Description

<Enter>

Selects and shows a sticker.

dd

Deletes the selected sticker.

q

Closes the Pad.
