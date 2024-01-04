local dir = THEME:GetPathS("", "ScreenEvaluationMusic/")

local dirFiles = FILEMAN:GetDirListing(dir)
local soundFiles = {}

for k, file in ipairs(dirFiles) do
  if string.match(file, "%.ogg") then
    table.insert(soundFiles, THEME:GetPathS("", "ScreenEvaluationMusic/" ..file))
  end
end

if #soundFiles > 0 then
  return soundFiles[math.random(#soundFiles)]
end