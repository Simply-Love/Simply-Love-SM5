local dir = THEME:GetCurrentThemeDirectory() .. "Sounds/"

audio_file = dir .. "song_fail.ogg" -- fail sound

local passed = false -- We want to know if at least one player passed
local players = GAMESTATE:GetHumanPlayers()
for player in ivalues(players) do
    local pn = ToEnumShortString(player) 
    local p = tonumber(player:sub(-1))-1
    local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(p)
    if stats:GetGrade() ~= "Grade_Failed" then passed = true end
end

if passed then
    audio_file = dir .. "song_pass.ogg"
end


if FILEMAN:DoesFileExist(audio_file) then return audio_file end