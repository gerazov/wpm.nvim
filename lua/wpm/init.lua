local M = {}
local api = vim.api

math.randomseed(os.time())

---@param opts table<string, any>
function M.setup(opts)

  require("wpm.config").override_opts(opts)
  api.nvim_create_namespace("wpm")
  local util = require("wpm.util")

  api.nvim_create_user_command("WPM", function(event)
    if #event.fargs > 0 then
      util.error("Too many arguments!")
      return
    end
    require("wpm.menu").show()
  end, {
    nargs = 0,
    desc = "WPM Menu",
  })

  api.nvim_create_user_command("WPMCountdown", function(event)
    if #event.fargs > 0 then
      util.error("Too many arguments!")
      return
    end
    require("wpm.menu").select_and_start("countdown")
  end, {
    nargs = 0,
    desc = "WPM Countdown",
  })

  api.nvim_create_user_command("WPMStopwatch", function(event)
    if #event.fargs > 0 then
      util.error("Too many arguments!")
      return
    end
    require("wpm.menu").select_and_start("stopwatch")
  end, {
    nargs = 0,
    desc = "WPM Countdown",
  })

end

return M
