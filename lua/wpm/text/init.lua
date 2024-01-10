local M = {}

---@return string[]
function M.get_words()
  return require("wpm.text.words")
end

---@return string[]
function M.get_sentences()
  return require("wpm.text.sentences")
end

return M
