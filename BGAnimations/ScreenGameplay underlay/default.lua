local Players = GAMESTATE:GetHumanPlayers()
local t = Def.ActorFrame{ Name="GameplayUnderlay" }



-- FailType is not directly a Preference, not a GamePref, not ThemePref, etc.
-- FailType is stored as one of the DefaultModifiers in Prefernces.ini
--
-- It's also worth noting that if fail is set to "Immediate"
-- no corresponding value will appear in DefaultModifiers and the engine assumes FailType_Immediate
--
-- We'll need to attempt to parse it out from the other default modifiers.
local DefaultMods = PREFSMAN:GetPreference("DefaultModifiers")
local FailString

for modifier in string.gmatch(DefaultMods, "%w+") do
	if modifier:find("Fail") then
		FailString = modifier
	end
end


-- Don't bother loading Danger if FailOff is set as a DefaultModifier
if not (FailString and FailString == "FailOff") then
	-- Load Danger for any available players
	for pn in ivalues(Players) do
		t[#t+1] = LoadActor("./PerPlayer/Danger.lua", pn)
	end
end

-- underlay stuff like BackgroundFilter, ColumnFlash, and MeasureCounter
for pn in ivalues(Players) do
	t[#t+1] = LoadActor("./PerPlayer/Filter.lua", pn)
	t[#t+1] = LoadActor("./PerPlayer/ColumnFlashOnMiss.lua", pn)
	t[#t+1] = LoadActor("./PerPlayer/MeasureCounter.lua", pn)
end

-- semi-transparent quad at the top of ScreenGameplay
t[#t+1] = Def.Quad{
	Name="TopBar",
	InitCommand=cmd(diffuse,color("0,0,0,0.85"); zoomto, _screen.w, _screen.h/5;),
	OnCommand=cmd(xy, _screen.w/2, _screen.h/12 - 10 )
}


-- Song title and progress bar for how much song remains
t[#t+1] = LoadActor("./Shared/SongInfoBar.lua")

-- More per-player stuff
for player in ivalues(Players) do
	t[#t+1] = LoadActor("./PerPlayer/Score.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/LifeMeter/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/DifficultyMeter.lua", player)
end


if GAMESTATE:IsPlayerEnabled(PLAYER_1) and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	t[#t+1] = LoadActor("./Shared/WhoIsCurrentlyWinning.lua")
end

t[#t+1] = LoadActor("./Shared/BPMDisplay.lua")

return t