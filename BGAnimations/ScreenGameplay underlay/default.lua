-- if the MenuTimer is enabled, we should reset SSM's MenuTimer now that we've reached Gameplay
if PREFSMAN:GetPreference("MenuTimer") then
	SL.Global.MenuTimer.ScreenSelectMusic = ThemePrefs.Get("ScreenSelectMusicMenuTimer")
end

local Players = GAMESTATE:GetHumanPlayers()
local holdingCtrl = false

local RestartHandler = function(event)
	if not event then return end

	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_left ctrl" then
			holdingCtrl = true
		elseif event.DeviceInput.button == "DeviceButton_r" then
			if holdingCtrl then
				SCREENMAN:GetTopScreen():SetPrevScreenName(Branch.GameplayScreen()):SetNextScreenName(Branch.GameplayScreen()):begin_backing_out()
			end
		end
	elseif event.type == "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_left ctrl" then
			holdingCtrl = false
		end
	end
end

local po = {}
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	po[player] = GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Song')
end
-- If the style is TwoPlayersSharedSides, we need to set the speed mod for the routine as well
if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_TwoPlayersSharedSides" then
	local xmod = po[GAMESTATE:GetMasterPlayerNumber()]:XMod()
	local mmod = po[GAMESTATE:GetMasterPlayerNumber()]:MMod()
	local cmod = po[GAMESTATE:GetMasterPlayerNumber()]:CMod()

	local mini = tonumber(SL[ToEnumShortString(GAMESTATE:GetMasterPlayerNumber())].ActiveModifiers.Mini:sub(1, -2)) / 100

	local speedmod = SL[ToEnumShortString(GAMESTATE:GetMasterPlayerNumber())].ActiveModifiers.SpeedMod
	local speedmod_str = (cmod ~= nil and "CMod") or (mmod ~= nil and "MMod") or (xmod ~= nil and "XMod")

	local fmt = {
		XMod = "mod,%.2fx",
		MMod = "mod,m%d",
		CMod = "mod,c%d",
	}
	local gcString = fmt[speedmod_str]:format(speedmod)
	gcString = gcString ..""
	GAMESTATE:ApplyGameCommand(gcString.."mod,"..SL[ToEnumShortString(GAMESTATE:GetMasterPlayerNumber())].ActiveModifiers.Mini.." mini", PLAYER_2)
	GAMESTATE:ApplyGameCommand(gcString.."mod,"..SL[ToEnumShortString(GAMESTATE:GetMasterPlayerNumber())].ActiveModifiers.Mini.." mini", PLAYER_1)

end

local t = Def.ActorFrame{
	Name="GameplayUnderlay",
	OnCommand=function(self)
		if ThemePrefs.Get("KeyboardFeatures") and PREFSMAN:GetPreference("EventMode") and not GAMESTATE:IsCourseMode() then
			SCREENMAN:GetTopScreen():AddInputCallback(RestartHandler)
		end
	end
}

for player in ivalues(Players) do
	t[#t+1] = LoadActor("./PerPlayer/Danger.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/StepStatistics/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/BackgroundFilter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/nice.lua", player)
end

-- UI elements shared by both players
t[#t+1] = LoadActor("./Shared/VersusStepStatistics.lua")
t[#t+1] = LoadActor("./Shared/Header.lua")
t[#t+1] = LoadActor("./Shared/SongInfoBar.lua") -- song title and progress bar

-- per-player UI elements
for player in ivalues(Players) do
	-- Tournament Mode modifications. Put this before everything as it sets
	-- player mods and other actors below might depend on it.
	t[#t+1] = LoadActor("./PerPlayer/TournamentMode.lua", player)

	t[#t+1] = LoadActor("./PerPlayer/UpperNPSGraph.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/Score.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/DifficultyMeter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/LifeMeter/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/TargetScore/default.lua", player)

	-- All NoteField specific actors are contained in this file.
	t[#t+1] = LoadActor("./PerPlayer/NoteField/default.lua", player)

end

-- add to the ActorFrame last; overlapped by StepStatistics otherwise
t[#t+1] = LoadActor("./Shared/BPMDisplay.lua")

return t
