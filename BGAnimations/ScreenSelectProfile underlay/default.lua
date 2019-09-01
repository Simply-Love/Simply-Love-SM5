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
			--using local profile
			joinframe:visible(false)
			scrollerframe:visible(true)
			seltext:visible(true)
			usbsprite:visible(false)
		else
			--using memorycard profile
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

	-- FIXME: stall for 0.5 seconds so that the Lua InputCallback doesn't get immediately added to the screen.
	-- It's otherwise possible to enter the screen with MenuLeft/MenuRight already held and firing off events,
	-- which causes the sick_wheel of profile names to not display.  I don't have time to debug it right now.
	InitCommand=function(self) self:queuecommand("Stall") end,
	StallCommand=function(self) self:sleep(0.5):queuecommand("Capture") end,
	CaptureCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./Input.lua", {af=self, Scrollers=scrollers, ProfileData=profile_data}) ) end,

	-- the OffCommand will have been queued, when it is appropriate, from ./Input.lua
	-- sleep for 0.5 seconds to give the PlayerFrames time to tween out
	-- and queue a call to Finish() so that the engine can wrap things up
	OffCommand=function(self)
		self:sleep(0.5):queuecommand("Finish")
	end,
	FinishCommand=function(self)
		-- If either/both human players want to not use a local profile
		-- (that is, they've choose the first option, "[Guest]"), ScreenSelectProfile
		-- will not let us leave.  The screen's Finish() method expects all human players
		-- to have local profiles they want to use.  So, this gets tricky.
		--
		-- Loop through a hardcoded table of both possible players.
		for player in ivalues({PLAYER_1, PLAYER_2}) do
			-- check if this player is joined in
			if GAMESTATE:IsHumanPlayer(player) then
				-- this player was joined in, so get the index of their profile scroller as it is now
				local info = scrollers[player]:get_info_at_focus_pos()
				-- if there were no local profiles, there won't be any info
				-- set index to 0 if so to indicate that "[Guest]" was chosen (because it was the only choice)
				local index = type(info)=="table" and info.index or 0

				-- if the index greater than 0, it indicates the player wants to use a local profile
				if index > 0 then
					-- so use the index to associate this ProfileIndex with this player
					SCREENMAN:GetTopScreen():SetProfileIndex(player, index)

				-- if the index is 0 (or, uh, negative, but that shouldn't happen given the way I set this up)
				-- it indicates the player wanted to not use a profile; they selected the first "[Guest]" option.
				else
					-- Passing a -2 to SetProfileIndex() will unjoin the player.
					-- Unjoining like this is (studid, but) necessary to get us past this screen onto the next
					-- because ScreenSelectProfile needs all human players to have profiles assigned to them.
					SCREENMAN:GetTopScreen():SetProfileIndex(player, -2)

					-- The engine considers this player to be unjoined, but the human person playing StepMania
					-- just wanted to not use a profile.  Save this player object in the SL table.  We'll rejoin
					-- the player without a profile at the Init of the next screen (ScreenAfterSelectProfile).
					if SL.Global.PlayersToRejoin == nil then SL.Global.PlayersToRejoin = {} end
					table.insert(SL.Global.PlayersToRejoin, player)
				end
			end
		end

		-- if no available human players wanted to use a local profile, they will have been unjoined by now
		-- and we won't be able to Finish() the screen without any joined players. If this happens, don't bother
		-- trying to Finish(), just force StepMania to the next screen.
		if type(SL.Global.PlayersToRejoin) == "table" then
			if (#SL.Global.PlayersToRejoin == 1 and #GAMESTATE:GetHumanPlayers() == 0) or (#SL.Global.PlayersToRejoin == 2) then
				SCREENMAN:SetNewScreen("ScreenAfterSelectProfile")
			end
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
				SCREENMAN:GetTopScreen():Cancel()
			else
				-- only attempt to unjoin the player if that side is currently joined
				if GAMESTATE:IsSideJoined(params.PlayerNumber) then
					MESSAGEMAN:Broadcast("BackButton")
					-- ScreenSelectProfile:SetProfileIndex() will interpret -2 as
					-- "Unjoin this player and unmount their USB stick if there is one"
					-- see ScreenSelectProfile.cpp for details
					SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -2)
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
		StartButtonMessageCommand=function(self) self:play() end
	},
	LoadActor( THEME:GetPathS("ScreenSelectMusic", "select down") )..{
		BackButtonMessageCommand=function(self) self:play() end
	},
	LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{
		DirectionButtonMessageCommand=function(self)
			self:play()
			if invalid_count then invalid_count = 0 end
		end
	},
	LoadActor( THEME:GetPathS("Common", "invalid") )..{
		InvalidChoiceMessageCommand=function(self)
			self:play()
			if invalid_count then
				invalid_count = invalid_count + 1
				if invalid_count >= 10 then MESSAGEMAN:Broadcast("What"); invalid_count = nil end
			end
		end
	},
	LoadActor( THEME:GetPathS("", "what.ogg") )..{
		WhatMessageCommand=function(self) self:play() end
	}
}

-- top mask
t[#t+1] = Def.Quad{
	InitCommand=function(self) self:horizalign(left):vertalign(bottom):setsize(540,50):xy(_screen.cx-self:GetWidth()/2, _screen.cy-110):MaskSource() end
}
-- bottom mask
t[#t+1] = Def.Quad{
	InitCommand=function(self) self:horizalign(left):vertalign(top):setsize(540,120):xy(_screen.cx-self:GetWidth()/2, _screen.cy+111):MaskSource() end
}

-- load PlayerFrames for both
if AutoStyle=="none" or AutoStyle=="versus" then
	t[#t+1] = LoadActor("PlayerFrame.lua", {Player=PLAYER_1, Scroller=scrollers[PLAYER_1], ProfileData=profile_data})
	t[#t+1] = LoadActor("PlayerFrame.lua", {Player=PLAYER_2, Scroller=scrollers[PLAYER_2], ProfileData=profile_data})

-- load only for the MasterPlayerNumber
else
	t[#t+1] = LoadActor("PlayerFrame.lua", {Player=mpn, Scroller=scrollers[mpn], ProfileData=profile_data})
end

LoadActor("./JudgmentGraphicPreviews.lua", {af=t, profile_data=profile_data})
LoadActor("./NoteSkinPreviews.lua", {af=t, profile_data=profile_data})

return t