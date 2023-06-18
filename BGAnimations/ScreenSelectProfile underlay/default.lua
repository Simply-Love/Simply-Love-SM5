-- AutoStyle is a Simply Love ThemePref that can allow players to always
-- automatically have one of [single, double, versus] chosen for them.
-- If AutoStyle is either "single" or "double", we don't want to load
-- SelectProfileFrames for both PLAYER_1 and PLAYER_2, but only the MasterPlayerNumber
local AutoStyle = ThemePrefs.Get("AutoStyle")

-- retrieve the MasterPlayerNumber now, at initialization, so that if AutoStyle is set
-- to "single" or "double" and that singular player unjoins, we still have a handle on
-- which PlayerNumber they're supposed to be...
local mpn = GAMESTATE:GetMasterPlayerNumber()

-- a table of profile data (highscore name, most recent song, mods, etc.)
-- indexed by "ProfileIndex" (provided by engine)
local profile_data = LoadActor("./PlayerProfileData.lua")

local scrollers = {}
scrollers[PLAYER_1] = setmetatable({disable_wrapping=true}, sick_wheel_mt)
scrollers[PLAYER_2] = setmetatable({disable_wrapping=true}, sick_wheel_mt)

-- ----------------------------------------------------

local HandleStateChange = function(self, Player)
	local frame = self:GetChild(ToEnumShortString(Player) .. 'Frame')
	local joinframe = frame:GetChild('JoinFrame')

	local scrollerframe = frame:GetChild('ScrollerFrame')
	local dataframe = scrollerframe:GetChild('DataFrame')
	local scroller = scrollerframe:GetChild('Scroller')

	local seltext = frame:GetChild('SelectedProfileText')
	local usbsprite = frame:GetChild('USBIcon')

	if GAMESTATE:IsHumanPlayer(Player) then

		if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
			-- using local profile
			joinframe:visible(false)
			scrollerframe:visible(true)
			seltext:visible(true)
			usbsprite:visible(false)
		else
			-- using memorycard profile
			joinframe:visible(false)
			scrollerframe:visible(false)
			seltext:visible(true):settext(MEMCARDMAN:GetName(Player))
			usbsprite:visible(true)

			SCREENMAN:GetTopScreen():SetProfileIndex(Player, 0)
		end
	else
		joinframe:visible(true)
		scrollerframe:visible(false)
		seltext:visible(false)
		usbsprite:visible(false)
	end
end

-- ----------------------------------------------------

local invalid_count = 0

local t = Def.ActorFrame {

	InitCommand=function(self) self:queuecommand("Stall") end,
	StallCommand=function(self)
		-- FIXME: Stall for 0.5 seconds so that the Lua InputCallback doesn't get immediately added to the screen.
		-- It's otherwise possible to enter the screen with MenuLeft/MenuRight already held and firing off events,
		-- which causes the sick_wheel of profile names to not display.  I don't have time to debug it right now.
		self:sleep(0.5):queuecommand("InitInput")

		-- FIXME: I need to find time to look at how the engine actually handles MenuTimers because
		-- including an Actor command that queues itself every 0.5 seconds to check the MenuTimer on custom
		-- screens like this (and ScreenPlayAgain, etc.) seems like it should be unnecessary.)
		if PREFSMAN:GetPreference("MenuTimer") then
			self:queuecommand("CheckMenuTimer")
		end
	end,
	InitInputCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./Input.lua", {af=self, Scrollers=scrollers, ProfileData=profile_data}) ) end,

	CheckMenuTimerCommand=function(self)
		-- if the MenuTimer has reached 0, it's time to queue the OffCommand and force a transition to the next screen
		if SCREENMAN:GetTopScreen():GetChild("Timer"):GetSeconds() <= 0 then

			-- It's possible that both players had the same local profile selected when the MenuTimer
			-- reached 0.  Queueing the OffCommand like this would assign the same local profile to
			-- both players.  Though engine permits this, it is unclear whether that is intentional
			-- or oversight, and I've yet to meet anyone who has requested such a feature.
			-- So, if the MenuTimer reaches 0 and both players are on the same non-GUEST profile
			-- we'll set them both to GUEST before transitioning.

			-- if both players have joined
			if  #GAMESTATE:GetHumanPlayers() > 1
			-- and both players are trying to choose the same profile
			and scrollers[PLAYER_1]:get_info_at_focus_pos().index == scrollers[PLAYER_2]:get_info_at_focus_pos().index
			-- and that profile they are both trying to choose isn't [GUEST]
			and scrollers[PLAYER_1]:get_info_at_focus_pos().index ~= 0 then
				scrollers[PLAYER_1]:scroll_by_amount( -scrollers[PLAYER_1]:get_info_at_focus_pos().index )
				scrollers[PLAYER_2]:scroll_by_amount( -scrollers[PLAYER_2]:get_info_at_focus_pos().index )
				self:sleep(0.3)
			end

			self:queuecommand("Off")
		else
			self:sleep(0.5):queuecommand("CheckMenuTimer")
		end
	end,

	-- the OffCommand will have been queued, when it is appropriate, from ./Input.lua
	-- sleep for 0.5 seconds to give the PlayerFrames time to tween out
	-- and queue a call to Finish() so that the engine can wrap things up
	OffCommand=function(self)
		self:sleep(0.5):queuecommand("Finish")
	end,
	FinishCommand=function(self)
		-- Loop through the enum for PlayerNumber that the engine has exposed to Lua.
		for player in ivalues( PlayerNumber ) do
			-- check if this player is joined in
			if GAMESTATE:IsHumanPlayer(player) then
				-- this player was joined in, so get the index of their profile scroller as it is now
				local info = scrollers[player]:get_info_at_focus_pos()
				-- if there were no local profiles, there won't be any info
				-- set index to 0 if so to indicate that "[Guest]" was chosen (because it was the only choice)
				local index = type(info)=="table" and info.index or 0

				-- the engine's SetProfileIndex() method expects local profiles to use index values that are > 0
				-- it also uses the following hardcoded values:
				--   0: use the USB memory card associated with this player
				--  -1: join the player and play the theme's start sound effect
				--  -2: unjoin the player, unlock their memorycard, and unmount their memorycard
				--  -3: allow the user to play without a profile (USB or local)

				-- check for and handle USB memorycards first
				if MEMCARDMAN:GetCardState(player) ~= 'MemoryCardState_none' then
					SCREENMAN:GetTopScreen():SetProfileIndex(player, 0)

				-- local profile
				elseif index > 0 then
					SCREENMAN:GetTopScreen():SetProfileIndex(player, index)

				-- 0 here is my own stupid hardcoded number, defined over in PlayerFrame.lua for use with the "[Guest]" choice
				-- In this case, 0 is the index of the choice in the scroller.  It should not be confused the 0 passed to
				-- SetProfileIndex() to use a USB memorycard which is a different stupid hardcoded number defined by the engine. D:
				elseif index == 0 then
					-- ScreenSelectProfile's Finish() method is hardcoded to assign DefaultProfileIDs
					-- which will interfere with SL's notion of NOT requiring all players to use profiles.
					-- If the player went out of their way to enable ScreenSelectProfile, they presumably want
					-- to be able to pick, and picking (to me) means having an option for not-using-a-profile.
					PREFSMAN:SetPreference("DefaultLocalProfileIDP1", "")
					PREFSMAN:SetPreference("DefaultLocalProfileIDP2", "")

					-- Passing -3 to SetProfileIndex() will allow the player to play without a profile
					SCREENMAN:GetTopScreen():SetProfileIndex(player, -3)
				end
			end
		end

		if SL.Global.FastProfileSwitchInProgress then
			SL.Global.FastProfileSwitchInProgress = false
		end
		SCREENMAN:GetTopScreen():Finish()
	end,
	WhatMessageCommand=function(self) self:runcommandsonleaves(function(subself) if subself.distort then subself:distort(0.5) end end):sleep(4):queuecommand("Undistort") end,
	UndistortCommand=function(self) self:runcommandsonleaves(function(subself) if subself.distort then subself:distort(0) end end) end,

	CodeMessageCommand=function(self, params)

		if (AutoStyle=="single" or AutoStyle=="double") and params.PlayerNumber ~= mpn then return end

		-- Don't allow players to unjoin from SelectProfile in CoinMode_Pay.
		-- 1 credit has already been deducted from ScreenTitleJoin, so allowing players
		-- to unjoin would mean we'd have to handle credit refunding (or something).
		if GAMESTATE:GetCoinMode() == "CoinMode_Pay" then return end

		if params.Name == "Select" then
			if GAMESTATE:GetNumPlayersEnabled()==0 then
				if SL.Global.FastProfileSwitchInProgress then
					-- Going back to the song wheel without any players connected doesn't
					-- make much sense; disallow dismissing the ScreenSelectProfile
					-- top screen until at least one player has joined in
					MESSAGEMAN:Broadcast("PreventEscape")
				else
					-- On the other hand, dismissing the regular ScreenSelectProfile
					-- (not in fast switch mode) is perfectly fine since we can just go
					-- back to the previous screen
					SCREENMAN:GetTopScreen():Cancel()
				end
			else
				-- only attempt to unjoin the player if that side is currently joined
				if GAMESTATE:IsSideJoined(params.PlayerNumber) then
					MESSAGEMAN:Broadcast("BackButton")
					-- ScreenSelectProfile:SetProfileIndex() will interpret -2 as
					-- "Unjoin this player and unmount their USB stick if there is one"
					-- see ScreenSelectProfile.cpp for details
					SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -2)
				end

				-- CurrentStyle has to be explicitly set to single in order to be able to
				-- unjoin a player from a 2-player setup
				if SL.Global.FastProfileSwitchInProgress and GAMESTATE:GetNumSidesJoined() == 1 then
					GAMESTATE:SetCurrentStyle("single")
					SCREENMAN:GetTopScreen():playcommand("Update")
				end
			end
			return
		end
	end,

	-- various events can occur that require us to reassess what we're drawing
	OnCommand=function(self) self:queuecommand('Update') end,
	StorageDevicesChangedMessageCommand=function(self) self:queuecommand('Update') end,
	PlayerJoinedMessageCommand=function(self, params) self:playcommand('Update', {player=params.Player}) end,
	PlayerUnjoinedMessageCommand=function(self, params) self:playcommand('Update', {player=params.Player}) end,

	-- there are several ways to get here, but if we're here, we'll just
	-- punt to HandleStateChange() to reassess what is being drawn
	UpdateCommand=function(self, params)
		if params and params.player then
			HandleStateChange(self, params.player)
			return
		end

		if AutoStyle=="none" or AutoStyle=="versus" then
			HandleStateChange(self, PLAYER_1)
			HandleStateChange(self, PLAYER_2)
		else
			HandleStateChange(self, mpn)
		end
	end,

	-- sounds
	LoadActor( THEME:GetPathS("Common", "start") )..{
		IsAction=true,
		StartButtonMessageCommand=function(self) self:play() end
	},
	LoadActor( THEME:GetPathS("ScreenSelectMusic", "select down") )..{
		IsAction=true,
		BackButtonMessageCommand=function(self) self:play() end
	},
	LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{
		IsAction=true,
		DirectionButtonMessageCommand=function(self)
			self:play()
			if invalid_count then invalid_count = 0 end
		end
	},
	LoadActor( THEME:GetPathS("Common", "invalid") )..{
		IsAction=true,
		InvalidChoiceMessageCommand=function(self)
			self:play()
			if PREFSMAN:GetPreference("EasterEggs") and invalid_count then
				invalid_count = invalid_count + 1
				if invalid_count >= 10 then MESSAGEMAN:Broadcast("What"); invalid_count = nil end
			end
		end
	},
	LoadActor( THEME:GetPathS("", "what.ogg") )..{
		WhatMessageCommand=function(self) self:play() end
	}
}

-- get table of player avatar paths
local avatars = {}
for profile in ivalues(profile_data) do
	if profile.dir and profile.displayname then
		avatars[profile.index] = GetAvatarPath(profile.dir, profile.displayname)
	end
end

-- if we're fast profile switching, dim the song wheel in the background
if SL.Global.FastProfileSwitchInProgress then
	t[#t+1] = Def.Quad {
		InitCommand=function(self)
			self:FullScreen():diffuse(Color.Black):diffusealpha(0.8)
		end
	}
end

-- load PlayerFrames for both
if AutoStyle=="none" or AutoStyle=="versus" then
	t[#t+1] = LoadActor("PlayerFrame.lua", {Player=PLAYER_1, Scroller=scrollers[PLAYER_1], ProfileData=profile_data, Avatars=avatars})
	t[#t+1] = LoadActor("PlayerFrame.lua", {Player=PLAYER_2, Scroller=scrollers[PLAYER_2], ProfileData=profile_data, Avatars=avatars})

-- load only for the MasterPlayerNumber
else
	t[#t+1] = LoadActor("PlayerFrame.lua", {Player=mpn, Scroller=scrollers[mpn], ProfileData=profile_data, Avatars=avatars})
end

LoadActor("./JudgmentGraphicPreviews.lua", {af=t, profile_data=profile_data})
LoadActor("./NoteSkinPreviews.lua", {af=t, profile_data=profile_data})

return t
