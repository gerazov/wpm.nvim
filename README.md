# ⌨️ WPM.nvim

Measure your WPM within Neovim ⚡️

This is based on [speedtyper.nvim](https://github.com/NStefan002/speedtyper.nvim) with added features.

## Features 

- Measures WPM in two modes:
    - _Countdown_ : type until the time is up.
    - _Stopwatch_ : type the whole text.

- Calculates WPM based on the words typed in the task, taking into account mistakes and corrections made.

- Implements WPM logging.

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

## Logging

Logging is turned on by default via the `logging` option. 

The log file is saved in the data folder (`~/.local/share/nvim` by default) and
is named `wpm-nvim.tsv`. The log file is a tab separated file and can be opened
in any spreadsheet program or read easily via code. The first line of the file
is a header that describes the columns. 

Basic logging (default) will log only the date and wpm. Full logging, set 
via the `full_logging` option, will log the following columns:
-  date: date and time of the game
-  wpm: words per minute
-  time: time in seconds
-  accuracy: accuracy in percent
-  n_words: number of words in the text
-  n_correct: number of correctly typed words
-  n_mistakes: number of mistakes
-  game_mode: game mode (countdown or stopwatch)
-  language
-  text: text type (words, sentences or custom)
-  custom_text_file: path to custom text file
-  user
-  host
-  keyboard_model
-  target_text
-  typed_text

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
  loging = true, -- log typing speed to a file
  full_logging = false, -- if false log only date and wpm
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
