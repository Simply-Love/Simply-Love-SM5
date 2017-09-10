-- if the MenuTimer is enabled, we should reset SSM's MenuTimer now that we've reached Gameplay
if PREFSMAN:GetPreference("MenuTimer") then
	SL.Global.MenuTimer.ScreenSelectMusic = ThemePrefs.Get("ScreenSelectMusicMenuTimer")
end

local Players = GAMESTATE:GetHumanPlayers()
local t = Def.ActorFrame{ Name="GameplayUnderlay" }

-- underlay stuff like BackgroundFilter, ColumnFlash, and MeasureCounter
for player in ivalues(Players) do
	t[#t+1] = LoadActor("./PerPlayer/Danger.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/Filter.lua", player)
end

-- semi-transparent quad at the top of ScreenGameplay
t[#t+1] = LoadActor("./Shared/Header.lua")

-- Song title and progress bar for how much song remains
t[#t+1] = LoadActor("./Shared/SongInfoBar.lua")

-- More per-player stuff
for player in ivalues(Players) do
	t[#t+1] = LoadActor("./PerPlayer/Score.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/LifeMeter/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/ColumnFlashOnMiss.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/MeasureCounter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/DifficultyMeter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/TargetScore/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/StepStatistics/default.lua", player)
end


if GAMESTATE:IsPlayerEnabled(PLAYER_1) and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	t[#t+1] = LoadActor("./Shared/WhoIsCurrentlyWinning.lua")
end

t[#t+1] = LoadActor("./Shared/BPMDisplay.lua")

return t