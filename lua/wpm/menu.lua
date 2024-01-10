local M = {}
local game = require("wpm.game_modes")
local util = require("wpm.util")
local window = require("wpm.window")

---disables some things that may be distracting
local function disable()
  vim.opt_local.nu = false
  vim.opt_local.rnu = false
  vim.opt_local.fillchars = { eob = " " }
  vim.opt_local.wrap = false
  if package.loaded["cmp"] then
    -- disable cmp if loaded, we don't want the completion while practising typing :)
    require("cmp").setup.buffer({ enabled = false })
  end
end

function M.show()
  vim.ui.select(game.available_game_modes, {
    prompt = "Select game mode:",
  }, function(selected)
    if not selected then
      util.error("Please select game mode.")
      return
    end

    local opts = require("wpm.config").opts
    window.open_float(opts.window)
    game.set_game_mode(selected)
    disable()
    game.start_game()
  end)
end

function M.select_and_start(game_mode)
  local opts = require("wpm.config").opts
  window.open_float(opts.window)
  game.set_game_mode(game_mode)
  disable()
  game.start_game()
end

return M
