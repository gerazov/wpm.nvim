local M = {}
local api = vim.api
local util = require("wpm.util")
local ns_id = api.nvim_get_namespaces()["wpm"]
local opts = require("wpm.config").opts
local hl = require("wpm.config").opts.highlights
local normal = vim.cmd.normal

local sentences = {}
local words = {}
if opts.text == "sentences" then
  sentences = require("wpm.text").get_sentences()
elseif opts.text == "words" then
  words = require("wpm.text").get_words()
elseif opts.text == "custom" then
  words = require("wpm.text").get_words()
end

---@type integer
M.next_word_id = 0
---@type integer
M.num_of_chars = 0
---@type string[]
M.sentence = nil
---@type string[]
M.text = {}
---@type string[]
M.lines = nil

-- used to make number of lines = window height
local n_lines = opts.window.height

---@return string[]
function M.new_sentence()
  return vim.split(sentences[math.random(1, #sentences)], " ")
end

---@return string
function M.new_word()
  if opts.text == "sentences" then
    M.next_word_id = M.next_word_id + 1
    if M.sentence == nil or M.next_word_id == #M.sentence then
      M.sentence = M.new_sentence()
      M.next_word_id = 0
    end
    return M.sentence[M.next_word_id + 1]
  else
    return words[math.random(1, #words)]
  end
end

---@return string
function M.generate_line()
  local win_width = api.nvim_win_get_width(0)
  local border_width = 4
  local word = M.new_word()
  table.insert(M.text, word)
  local line = word
  while true do
    word = M.new_word()
    if #line + #word >= win_width - border_width then
      M.next_word_id = M.next_word_id - 1
      break
    end
    line = line .. " " .. word
    table.insert(M.text, word)
  end
  return line .. " "
end

---@return integer[]
---@return string[]
function M.generate_extmarks()
  util.clear_text(n_lines)
  local extm_ids = {}
  local lines = {}
  for i = 1, n_lines - 1 do
    local line = M.generate_line()
    local extm_id = api.nvim_buf_set_extmark(0, ns_id, i - 1, 0, {
      virt_text = {
        { line, hl.untyped_text },
      },
      hl_mode = "combine",
      virt_text_win_col = 0,
    })
    table.insert(lines, line)
    table.insert(extm_ids, extm_id)
  end

  return extm_ids, lines
end

---additional variables used for fixing edge cases
---@type integer
M.prev_line = 0
---@type integer
M.prev_col = 0

---update extmarks according to the cursor position
---@param lines string[]
---@param extm_ids integer[]
---@return integer[]
---@return string[]
function M.update_extmarks(lines, extm_ids)
  local line, col = util.get_cursor_pos()
  -- NOTE: so I don't forget what is going on here
  --[[
    - a lot of +- 1 because of inconsistent indexing in provided functions
    - the main problem is jumping to the end of the previous line when deleting
    - "CursorMovedI" is triggered for the 'next' (the one that has yet to be typed) character,
    so we need to examine 'previous' cursor positon
    - col - 1 and col - 2 is the product of the above statement and the fact that every line
    ends with " " (see wpm.util.generate_sentence), there is no logical explanation,
    the problem was aligning 0-based and 1-based indexing
    ]]
  if col - 1 == #lines[line] or col - 2 == #lines[line] then
    if line < M.prev_line or col == M.prev_col then
      --[[ <bspace> will remove the current line and move the cursor to the beginning of the previous,
      so we need to restore the deleted line with 'o' (could be done with api functions) and re-add the virtual text ]]
      normal("o")
      normal("k$")
      api.nvim_buf_set_extmark(0, ns_id, line, 0, {
        id = extm_ids[line + 1],
        virt_text = {
          { lines[line + 1], hl.untyped_text },
        },
        virt_text_win_col = 0,
      })
    elseif line == n_lines - 1 then
      -- move cursor to the beginning of the first line and generate new sentences after the final space in the last line
      local buf_lines = api.nvim_buf_get_lines(0, 0, -1, false)
      if M.lines == nil then
        M.lines = buf_lines
      else
        vim.list_extend(M.lines, buf_lines)
      end
      normal("gg0")
      util.clear_extmarks(extm_ids)
      for _, s in pairs(lines) do
        M.num_of_chars = M.num_of_chars + #s
      end
      return M.generate_extmarks()
    else
      -- move cursor to the beginning of the next line after the final space in the previous line
      normal("j0")
    end
  end
  api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, {
    id = extm_ids[line],
    virt_text = {
      { string.sub(lines[line], col), hl.untyped_text },
    },
    virt_text_win_col = col - 1,
  })

  M.prev_line = line
  M.prev_col = col

  return extm_ids, lines
end

return M
