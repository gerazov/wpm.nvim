local M = {}
local api = vim.api

M.available_game_modes = {
  "countdown",
  "stopwatch",
}

M.game_mode = ""

function M.set_game_mode(game_mode)
  M.game_mode = game_mode
end

function M.start_game()
  api.nvim_create_autocmd("BufLeave", {
    group = api.nvim_create_augroup("wpmEarlyExit", { clear = true }),
    once = true,
    callback = function()
      M.end_game(false)
      api.nvim_buf_delete(0, { force = true })
      api.nvim_win_close(0, true)
    end,
    desc = "End game when leaving buffer.",
  })
  require("wpm.game_modes." .. M.game_mode).start()
end

---@param ok boolean  -- did the user force stop the game before it ended
function M.end_game(ok)
  require("wpm.game_modes." .. M.game_mode).stop(ok)
end

return M
