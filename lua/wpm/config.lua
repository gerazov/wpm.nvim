local M = {}

---@type table<string, any>
M.default_opts = {
  window = {
    height = 10, -- integer >= 5 | float in range (0, 1)
    width = 60, -- integer | float in range (0, 1)
    border = "rounded", -- "none" | "single" | "double" | "rounded" | "shadow" | "solid"
  },
  language = "en",
  text = "sentences", -- "words" | "sentences" | "custom" - automatically set to "custom" if custom_text_file is not nil
  custom_text_file = nil, -- provide a path to file that contains your custom text (if this is not nil, language option will be ignored)
  loging = true, -- log typing speed to a file
  full_logging = false, -- if false log only date and wpm
  log_path = vim.fn.stdpath("data") .. "/wpm-nvim.tsv", -- data folder is ~/.local/share/nvim

-- Logging is turned on by default via the `logging` option. The log file is
  -- saved in the data folder (~/.local/share/nvim by default) and is named
  -- `wpm-nvim.tsv`. The log file is a tab separated file and can be opened in
  -- any spreadsheet program. The first line of the file is a header that
  -- describes the columns.
  -- Basic logging (default) will log only the date and wpm. Full logging, set
  -- via the `full_logging` option, will log the following columns:
  --  date: date and time of the game
  --  wpm: words per minute
  --  time: time in seconds
  --  accuracy: accuracy in percent
  --  n_words: number of words in the text
  --  n_correct: number of correctly typed words
  --  n_mistakes: number of mistakes
  --  game_mode: game mode (countdown or stopwatch)
  --  lang: language
  --  text: text type (words, sentences or custom)
  --  custom_text_file: path to custom text file
  --  user: user name
  --  host: host name
  --  keyboard_model: keyboard model
  --  target_text: target text
  --  typed_text: typed text
  --
  --
  -- will log the date and wpm to a tab separated file. Full logging will log
--         header = "date\twpm\t" ..
--           "time\taccuracy\tn_words\tn_correct\tn_mistakes\t" ..
--           "game_mode\tlang\ttext\tcustom_text_file\t" ..
--           "user\thost\tkeyboard_model\t" ..
--           "target_text\ttyped_text\n"
--       else
--         header = "date\twpm\n"
  game_modes = { -- prefered settings for different game modes
    -- type until time expires
    countdown = {
      time = 30,
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
  -- this values will be restored to your prefered settings after the game ends
  vim_opt = {
    -- only applies to insert mode, while playing the game
    guicursor = nil, -- "ver25" | "hor20" | "block" | nil means do not change
  },
}

---@type table<string, any>
M.values_to_restore = {
  guicursor = vim.opt.guicursor:get(),
}

---@type table<string, any>
M.opts = {}

---@param opts table<string, any>
function M.override_opts(opts)
  M.opts = vim.tbl_deep_extend("force", M.default_opts, opts or {})
  if opts.custom_text_file then
    M.opts.text = "custom"
  end
  if M.opts.vim_opt.guicursor then
    vim.opt.guicursor = "i:" .. M.opts.vim_opt.guicursor
  end
end

function M.restore_opts()
  for option, val in pairs(M.values_to_restore) do
    vim.opt[option] = val
  end
end

return M
