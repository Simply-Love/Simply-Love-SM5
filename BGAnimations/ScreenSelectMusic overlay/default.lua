local ResetModsInput = function(event)
	if event.type == "InputEventType_Release" then return false end
	if event.GameButton ~= "EffectUp" then return false end
	local player = event.PlayerNumber
	if player and GAMESTATE:IsSideJoined(player) then
		ResetPlayerMods(player)
		local pn = player == PLAYER_1 and "1" or "2"
        SCREENMAN:SystemMessage("P"..pn.." mods reset")
end
	return false
end

local ClampCasualDifficulty = function(player)
	if SL.Global.GameMode ~= "Casual" then return end
	local song = GAMESTATE:GetCurrentSong()
	if not song then return end
	local current = GAMESTATE:GetCurrentSteps(player)
	if not current then return end
	local maxMeter = ThemePrefs.Get("CasualMaxMeter")
	if current:GetMeter() <= maxMeter then return end
	local bestSteps = nil
	for _, s in ipairs(SongUtil.GetPlayableSteps(song)) do
		if s:GetMeter() <= maxMeter then
			if bestSteps == nil or s:GetMeter() > bestSteps:GetMeter() then
				bestSteps = s
			end
		end
	end
	if bestSteps then
		GAMESTATE:SetCurrentSteps(player, bestSteps)
	end
end

local af = Def.ActorFrame{
	-- GameplayReloadCheck is a kludgy global variable used in ScreenGameplay in.lua to check
	-- if ScreenGameplay is being entered "properly" or being reloaded by a scripted mod-chart.
	-- If we're here in SelectMusic, set GameplayReloadCheck to false, signifying that the next
	-- time ScreenGameplay loads, it should have a properly animated entrance.
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(ResetModsInput)
	end,
	InitCommand=function(self)
		SL.Global.GameplayReloadCheck = false
		generateFavoritesForMusicWheel()
		
		-- reset song start time here in case player force-escaped
		start_time = -1

		-- While other SM versions don't need this, Outfox resets the
		-- the music rate to 1 between songs, but we want to be using
		-- the preselected music rate.
		local songOptions = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred")
		songOptions:MusicRate(SL.Global.ActiveModifiers.MusicRate)
	end,

	PlayerProfileSetMessageCommand=function(self, params)
		if not PROFILEMAN:IsPersistentProfile(params.Player) then
			LoadGuest(params.Player)
		end
		generateFavoritesForMusicWheel()
		ApplyMods(params.Player)
	end,

	PlayerJoinedMessageCommand=function(self, params)
		if not PROFILEMAN:IsPersistentProfile(params.Player) then
			LoadGuest(params.Player)
		end
		ApplyMods(params.Player)
	end,
	CodeMessageCommand=function(self, params)
		if params.Name == "Favorite1" or params.Name == "Favorite2" then
			addOrRemoveFavorite(params.PlayerNumber)
		elseif params.Name == "EscapeFromEventMode" then
			SCREENMAN:GetTopScreen():Cancel()
		end
	end,
	CurrentStepsP1ChangedMessageCommand=function(self) ClampCasualDifficulty(PLAYER_1) end,
	CurrentStepsP2ChangedMessageCommand=function(self) ClampCasualDifficulty(PLAYER_2) end,

	ReloadScreenForMemoryCardsMessageCommand=function(self, params)
		-- Wait some time for the profile screen to finish transitioning
		-- before reloading the screen.
		self:sleep(0.10):queuecommand("Reload")
	end,
	ReloadCommand=function(self)
		SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSM")
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
	-- ---------------------------------------------------
	--  first, load files that contain no visual elements, just code that needs to run

	-- MenuTimer code for preserving SSM's timer value when going
	-- from SSM to a different screen and back to SSM (i.e. returning from PlayerOptions).
	LoadActor("./PreserveMenuTimer.lua"),
	-- Apply player modifiers from profile
	LoadActor("./PlayerModifiers.lua"),

	-- ---------------------------------------------------
	-- next, load visual elements; the order of these matters
	-- i.e. content in PerPlayer/Over needs to draw on top of content from PerPlayer/Under

	-- make the MusicWheel appear to cascade down; this should draw underneath P2's PaneDisplay
	LoadActor("./MusicWheelAnimation.lua"),

	-- number of steps, jumps, holds, etc., and high scores associated with the current stepchart
	LoadActor("./PaneDisplay.lua"),

	-- elements we need two of (one for each player) that draw underneath the StepsDisplayList
	-- this includes the stepartist boxes, the density graph, and the cursors.
	LoadActor("./PerPlayer/default.lua"),
	-- The grid for the difficulty picker (normal) or CourseContentsList (CourseMode)
	LoadActor("./StepsDisplayList/default.lua"),

	-- Song's Musical Artist, BPM, Duration
	LoadActor("./SongDescription/SongDescription.lua"),

	-- Banner Art
	LoadActor("./Banner.lua"),

	-- ---------------------------------------------------
	-- finally, load the overlay used for sorting the MusicWheel (and more), hidden by default
	LoadActor("./SortMenu/default.lua"),
	-- a Test Input overlay can (maybe) be accessed from the SortMenu
	LoadActor("./TestInput.lua"),

	-- The GrooveStats leaderboard that can (maybe) be accessed from the SortMenu
	-- This is only added in "dance" mode and if the service is available.
	LoadActor("./Leaderboard.lua"),

	LoadActor("./SongSearch/default.lua"),

}

return af
