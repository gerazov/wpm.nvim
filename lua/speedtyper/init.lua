local M = {}
local api = vim.api
local helper_fn = require("speedtyper.helper")
local util = require("speedtyper.util")

M.default_opts = {
    time = 30,
    window = {
        height = 0.15,      -- integer grater than 0 or float in range (0, 1)
        width = 0.55,       -- integer grater than 0 or float in range (0, 1)
        border = "rounded", -- "none" | "single" | "double" | "rounded" | "shadow" | "solid"
    },
}

---@param opts table
---@return integer, integer
M.open_float = function(opts)
    local lines = vim.o.lines - vim.o.cmdheight
    local columns = vim.o.columns
    local height = helper_fn.calc_size(opts.height, lines)
    local width = helper_fn.calc_size(opts.width, columns)
    local bufnr = api.nvim_create_buf(false, true)
    local winnr = api.nvim_open_win(bufnr, true, {
        relative = "editor",
        row = math.floor((lines - height) / 2),
        col = math.floor((columns - width) / 2),
        anchor = "NW",
        width = width,
        height = height,
        border = opts.border,
        title = "Speedtyper",
        title_pos = "center",
        noautocmd = true,
    })
    -- creating space for extmarks
    for _ = 1, 3 do
        vim.cmd.normal("o")
    end
    vim.cmd.normal("gg")
    vim.cmd.startinsert()
    return winnr, bufnr
end

---@param time_sec number
---@param bufnr integer
---@param ns_id integer
M.create_timer = function(time_sec, bufnr, ns_id)
    local extm_id = api.nvim_buf_set_extmark(bufnr, ns_id, 0, 0, {
        virt_text = {
            { "Time: " .. tostring(time_sec) .. "    ", "Error" },
        },
        virt_text_pos = "right_align",
    })
    local timer
    if vim.uv ~= nil then
        timer = vim.uv.new_timer()
    else
        timer = vim.loop.new_timer()
    end

    timer:start(0, 1000, vim.schedule_wrap(function()
        if time_sec <= 0 then
            extm_id = api.nvim_buf_set_extmark(bufnr, ns_id, 0, 0, {
                virt_text = {
                    { "Time's up!", "WarningMsg" },
                },
                virt_text_pos = "right_align",
                id = extm_id
            })
            timer:stop()
            timer:close()
        else
            extm_id = api.nvim_buf_set_extmark(bufnr, ns_id, 0, 0, {
                virt_text = {
                    { "Time: " .. tostring(time_sec) .. "    ", "Error" },
                },
                virt_text_pos = "right_align",
                id = extm_id
            })
            time_sec = time_sec - 1
        end
    end))
end

---@param bufnr integer
---@param ns_id integer
M.start = function(bufnr, ns_id)
    math.randomseed(os.time())
    local extm_ids, sentences = helper_fn.generate_extmark(bufnr, ns_id)
    api.nvim_create_autocmd("CursorMovedI", {
        group = api.nvim_create_augroup("Speedtyper", { clear = true }),
        buffer = bufnr,
        callback = function()
            helper_fn.update_extmarks(sentences, extm_ids, bufnr, ns_id)
        end,
        desc = "Update extmarks while typing.",
    })
end

---@param opts table
M.setup = function(opts)
    opts = opts or M.default_opts
    -- one or zero arguments
    api.nvim_create_user_command("Speedtyper", function(event)
        if #event.fargs > 1 then
            util.error("Too many arguments!")
            return
        end
        local time = tonumber(event.fargs[1]) or opts.time
        local ns_id = api.nvim_create_namespace("Speedtyper")
        local winnr, bufnr = M.open_float(opts.window)
        M.start(bufnr, ns_id)
        M.create_timer(time, bufnr, ns_id)
    end, {
        nargs = "*",
        desc = "Start Speedtyper with <arg> (or default if not provided) time on the clock.",
    })
end

return M
