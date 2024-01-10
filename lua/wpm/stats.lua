local M = {}
local api = vim.api
local ns_id = api.nvim_get_namespaces()["wpm"]

---@param time_sec number
---@param text? string[]
---@param prev_lines? string[]
function M.display_stats(time_sec, text, prev_lines)
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
  api.nvim_buf_set_lines(0, 0, 5, false, {
    wpm_text,
    "",
    acc_text,
    "",
    time_text,
  })
  api.nvim_buf_add_highlight(0, ns_id, "Error", 0, 0, #wpm_text)
  api.nvim_buf_add_highlight(0, ns_id, "DiagnosticWarn", 2, 0, #acc_text)
  api.nvim_buf_add_highlight(0, ns_id, "DiagnosticInfo", 4, 0, #time_text)
end

return M
