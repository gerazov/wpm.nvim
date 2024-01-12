# ⌨️ WPM.nvim

Measure your WPM within Neovim ⚡️

This is based on [speedtyper.nvim](https://github.com/NStefan002/speedtyper.nvim) with added features.

## Features 

WPM supports two modes:
- _Countdown_ : type until the time is up.
- _Stopwatch_ : type the whole text.

WPM is calculated based on the words typed in the task, taking into account mistakes and corrections made.

\* [speedtyper.nvim](https://github.com/NStefan002/speedtyper.nvim) also has a *Rain* game mode.

## Install

```lua
{
  "gerazov/wpm.nvim",
  lazy = true,
  cmd = { "WPM", "WPMCountdown", "WPMStopwatch" },  -- lazy start on command
  keys = {
    { "<leader>ty", "<cmd>WPM<cr>", desc = "WPMCountdown" },
  },
  opts = {
  }
}
```
## Usage

- You can start the mode selection menu with `WPM` or directly the Countdown mode with `WPMCountdown`, or the Stopwatch with `WPMStopwatch`.
- You can exit the run using `<Esc>` in normal mode. 
- You can start again using `<C-Space>` in normal mode. 

## Languages

The plugin has English built in. Other languages can be added via custom `txt` files.

## Recommended plugins

- [dressing.nvim](https://github.com/stevearc/dressing.nvim)
- [nvim-notify](https://github.com/rcarriga/nvim-notify)

## Default configuration

```lua
opts = {
  window = {
    height = 10, -- integer >= 5 | float in range (0, 1)
    width = 60, -- integer | float in range (0, 1)
    border = "rounded", -- "none" | "single" | "double" | "rounded" | "shadow" | "solid"
  },
  language = "en",
  text = "sentences", -- "words" | "sentences" | "custom" - automatically set to "custom" if custom_text_file is not nil
  custom_text_file = nil, -- path to custom file, overrides text
  log = true, -- log typing speed to a file
  log_path = vim.fn.stdpath("data") .. "/wpm-nvim.tsv", -- data folder is ~/.local/share/nvim
  game_modes = { -- preferred settings for different game modes
    -- type until time expires
    countdown = {
      time = 60,
    },
    -- type until you complete one page
    stopwatch = {
      show_time = true, -- show time while typing
    },
  },
  -- specify highlight group for each component
  highlights = {
    untyped_text = "Comment",
    typo = "ErrorMsg",
    clock = "ErrorMsg",
  },
  -- this values will be restored to your preferred settings after the game ends
  vim_opt = {
    -- only applies to insert mode, while playing the game
    guicursor = nil, -- "ver25" | "hor20" | "block" | nil means do not change
  },
}
```

## Similar projects

- [speedtyper.nvim](https://github.com/NStefan002/speedtyper.nvim)
- [vim-apm](https://github.com/ThePrimeagen/vim-apm)
- [duckytype.nvim](https://github.com/kwakzalver/duckytype.nvim)
- [jcdickinson/wpm.nvim](https://github.com/jcdickinson/wpm.nvim) - archived
