-- if the MenuTimer is enabled, we should reset SSM's MenuTimer now that we've reached Gameplay
if PREFSMAN:GetPreference("MenuTimer") then
	SL.Global.MenuTimer.ScreenSelectMusic = ThemePrefs.Get("ScreenSelectMusicMenuTimer")
end

local Players = GAMESTATE:GetHumanPlayers()
local t = Def.ActorFrame{ Name="GameplayUnderlay" }

for player in ivalues(Players) do
	t[#t+1] = LoadActor("./PerPlayer/Danger.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/StepStatistics/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/BackgroundFilter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/nice.lua", player)
end

-- UI elements shared by both players
t[#t+1] = LoadActor("./Shared/Header.lua")
t[#t+1] = LoadActor("./Shared/SongInfoBar.lua") -- song title and progress bar

-- per-player UI elements
for player in ivalues(Players) do
	t[#t+1] = LoadActor("./PerPlayer/UpperNPSGraph.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/Score.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/DifficultyMeter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/LifeMeter/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/ColumnFlashOnMiss.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/MeasureCounter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/TargetScore/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/SubtractiveScoring.lua", player)
end

-- add to the ActorFrame last; overlapped by StepStatistics otherwise
t[#t+1] = LoadActor("./Shared/BPMDisplay.lua")

return t
