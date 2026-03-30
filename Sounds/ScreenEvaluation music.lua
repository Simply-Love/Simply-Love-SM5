-- Plays a random sound based on pass/fail
-- (theme dir)/Sounds/Evaluation Pass/
-- (theme dir)/Sounds/Evaluation Fail/
-- Name your files in numerical order 1.ogg / 2.ogg / etc
-- Currently does not support looping
-- findFiles function in Scripts/Z-NewFunctions.lua

local dir = THEME:GetCurrentThemeDirectory() .. "Sounds/Evaluation Fail/"

local players = GAMESTATE:GetHumanPlayers()
for player in ivalues(players) do
    local pn = ToEnumShortString(player) 
    local p = tonumber(player:sub(-1))-1
    local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(p)
    if stats:GetGrade() ~= "Grade_Failed" then dir = THEME:GetCurrentThemeDirectory() .. "Sounds/Evaluation Pass/" end
end

local evaluation_sounds = findFiles(dir)
if #evaluation_sounds > 0 then
    return evaluation_sounds[math.random(#evaluation_sounds)]
end