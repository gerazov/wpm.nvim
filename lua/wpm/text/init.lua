local M = {}
local util = require("wpm.util")
local opts = require("wpm.config").opts

M.supported_words = {
  "custom", -- if custom_text option is provided
  "en",
  "sr",
}

M.supported_sentences = {
  "en",
}

M.lang = ""

---@param lang string
function M.set_lang(lang)
  local supported = false
  local supported_langs
  if opts.sentence_mode then
    supported_langs = M.supported_sentences
  else
    supported_langs = M.supported_words
  end
  for _, l in pairs(supported_langs) do
    if lang == l then
      supported = true
    end
  end
  if not supported then
    if opts.sentence_mode then
      util.error("Language " .. lang .. " is not supported for sentence mode!")
    else
      util.error("Language " .. lang .. " is not supported!")
    end
  else
    M.lang = lang
  end
end

---get list of words for selected language
---@return string[]
function M.get_words()
  return require("wpm.langs." .. M.lang)
end

---get list of sentences for selected language
---@return string[]
function M.get_sentences()
  return require("wpm.langs.sentences." .. M.lang)
end

return M
