local M = {}

---@type table<string, any>
M.default_opts = {
  window = {
    height = 10, -- integer >= 5 | float in range (0, 1)
    width = 60, -- integer | float in range (0, 1)
    border = "rounded", -- "none" | "single" | "double" | "rounded" | "shadow" | "solid"
  },
  text = "sentences", -- "words" | "sentences"
  custom_text_file = nil, -- provide a path to file that contains your custom text (if this is not nil, language option will be ignored)
  game_modes = { -- prefered settings for different game modes
    -- type until time expires
    countdown = {
      time = 30,
    },
    -- type until you complete one page
    stopwatch = {
      hide_time = true, -- hide time while typing
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
