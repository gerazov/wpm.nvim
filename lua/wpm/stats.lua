local M = {}
local api = vim.api
local ns_id = api.nvim_get_namespaces()["wpm"]

---@param time_sec number
---@param text? string[]
---@param prev_lines? string[]
---@param game_mode? string
function M.display_stats(time_sec, text, prev_lines, game_mode)

  local opts = require("wpm.config").opts
  local lines = api.nvim_buf_get_lines(0, 0, -1, false)
  local n_lines = #lines
  -- clear all lines
  local empty_lines = {}
  for _ = 1, n_lines do
    table.insert(empty_lines, "")
  end
  api.nvim_buf_set_lines(0, 0, n_lines, false, empty_lines)

  local wpm = 0
  local accuracy = 0
  if prev_lines ~= nil then
    lines = vim.list_extend(prev_lines, lines)
  end
  -- concatenate all lines as a single string
  local lines_str = table.concat(lines, "")
  -- substitute multiple spaces with a single space
  lines_str = lines_str:gsub("%s+", " ")
  -- remove trailing spaces
  lines_str = lines_str:gsub("%s$", "")
  -- split into words
  local words_typed = vim.split(lines_str, " ")
  -- loop though each word typed and compare to the target text
  local n_correct = 0
  local n_mistakes = 0  -- redefine n_mistakes to the end version
  for i, word in pairs(words_typed) do
    if text[i] and word == text[i] then
      n_correct = n_correct + 1
    else
      n_mistakes = n_mistakes + 1
    end
  end
  -- if the user didn't finish typing the last word then don't count it
  local n_words = #words_typed
  if text[n_words] and words_typed[n_words] ~= text[n_words] then
    n_words = #words_typed - 1
    n_mistakes = n_mistakes - 1
  end
  wpm = n_correct * (60 / time_sec)
  accuracy = n_correct / n_words * 100

  local wpm_text = string.format("WPM: %.2f", wpm)
  local acc_text = string.format("Accuracy: %.2f%%", accuracy)
  local time_text = string.format("Time: %d seconds", time_sec)
  local options_text = "Press <Esc> to exit, <C-Space> to restart"
  api.nvim_buf_set_lines(0, 0, 5, false, {
    wpm_text,
    acc_text,
    time_text,
    "",
    options_text,
  })
  api.nvim_buf_add_highlight(0, ns_id, "Error", 0, 0, #wpm_text)
  api.nvim_buf_add_highlight(0, ns_id, "DiagnosticWarn", 1, 0, #acc_text)
  api.nvim_buf_add_highlight(0, ns_id, "DiagnosticInfo", 2, 0, #time_text)
  api.nvim_buf_add_highlight(0, ns_id, "DiagnosticOk", 4, 0, #options_text)

  -- save stats to a tab separated csv file
  if opts.log then
    -- if file doesn't exist, create it and add the header
    local log_file
    if vim.fn.filereadable(opts.log_path) == 0 then
      local header = "date\tuser\thost\tkeyboard_model\tgame_mode\ttime\twpm\t" ..
        "accuracy\tn_words\tn_correct\tn_mistakes\tlang\ttext\tcustom_text_file\t" ..
        "target_text\ttyped_text\n"
      log_file = io.open(opts.log_path, "w")
      log_file:write(header)
      log_file:close()
    end

    log_file = io.open(opts.log_path, "a")
    -- start the log line with the date stamp, user, host, game mode
    local log_line = os.date("%Y-%m-%d %H:%M:%S") .. "\t" ..
      vim.loop.os_getenv("USER") .. "\t" ..
      vim.loop.os_gethostname() .. "\t" ..
      -- extract keyboard information via lsusb, keep from field 7 till end of line, trim trailing newline
      vim.fn.system([[ lsusb | grep -i keyboard | cut -f 7- -d\  | tr -d '\n' ]]) .. "\t" ..
      game_mode .. "\t"

    log_line = log_line .. string.format(
      "%.2f\t%.2f\t%.2f\t%d\t%d\t%d",
      time_sec, wpm, accuracy, n_words, n_correct, n_mistakes
    )

    for _, opt in pairs({
      opts.language,
      opts.text, -- "words" | "sentences" | "custom" - automatically set to "custom" if custom_text_file is not nil
      opts.custom_text_file or "",
      table.concat(text, " "),
      table.concat(words_typed, " ")
    }) do
      log_line = log_line .. "\t" .. opt
    end
    log_line = log_line .. "\n"
    log_file:write(log_line)
    log_file:close()
  end
end

return M
