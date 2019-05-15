-- AutoStyle is a Simply Love ThemePref that can allow players to always
-- automatically have one of [single, double, versus] chosen for them.
-- If AutoStyle is either "single" or "double", we don't want to load
-- SelectProfileFrames for both PLAYER_1 and PLAYER_2, but only the MasterPlayerNumber
local AutoStyle = ThemePrefs.Get("AutoStyle")

-- retrieve the MasterPlayerNumber now, at initialization, so that if AutoStyle is set
-- to "single" or "double" and that singular player unjoins, we still have a handle on
-- which PlayerNumber they're supposed to be...
local mpn = GAMESTATE:GetMasterPlayerNumber()

local invalid_count = 0

local UpdateInternal3 = function(self, Player)
	local frame = self:GetChild(ToEnumShortString(Player) .. 'Frame')
	local joinframe = frame:GetChild('JoinFrame')

	local scrollerframe = frame:GetChild('ScrollerFrame')
	local dataframe = scrollerframe:GetChild('DataFrame')
	local scroller = scrollerframe:GetChild('Scroller')

	local seltext = frame:GetChild('SelectedProfileText')
	local usbsprite = frame:GetChild('USBIcon')

	if GAMESTATE:IsHumanPlayer(Player) then

		frame:visible(true)

		if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
			--using local profile
			joinframe:visible(false)
			usbsprite:visible(false)
			scrollerframe:visible(true)
			seltext:visible(true)

			local index = SCREENMAN:GetTopScreen():GetProfileIndex(Player)

			if index > 0 then
				scroller:SetDestinationItem(index-1)
				seltext:settext(PROFILEMAN:GetLocalProfileFromIndex(index-1):GetDisplayName())
				dataframe:playcommand("Set", {PlayerNumber=Player, index=(index-1)})
			else
				if SCREENMAN:GetTopScreen():SetProfileIndex(Player, 1) then
					scroller:SetDestinationItem(0)
					self:queuecommand('UpdateInternal2')
				else
					joinframe:visible(true)
					scrollerframe:visible(false)
					seltext:settext(ScreenString("NoProfile"))
				end
			end
		else
			--using memorycard profile
			scrollerframe:visible(false)
			joinframe:visible(false)
			usbsprite:visible(true)
			seltext:visible(true):settext(MEMCARDMAN:GetName(Player))

			SCREENMAN:GetTopScreen():SetProfileIndex(Player, 0)
		end
	else
		usbsprite:visible(false)
		joinframe:visible(true)
		seltext:visible(false)
		scrollerframe:visible(false)
	end
end



local t = Def.ActorFrame {
	InitCommand=function(self) self:queuecommand("Capture") end,
	CaptureCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./Input.lua", self) ) end,

	-- the OffCommand will have been queued, when it is appropriate, from Input.lua
	-- sleep for 0.5 seconds to give the playerframes time to tween out
	-- and queue a call to finish() so that the engine can wrap things up
	OffCommand=function(self) self:sleep(0.5):queuecommand("Finish") end,
	FinishCommand=function(self) SCREENMAN:GetTopScreen():Finish() end,
	WhatMessageCommand=function(self) self:runcommandsonleaves(function(subself) if subself.distort then subself:distort(0.5) end end):sleep(4):queuecommand("Undistort") end,
	UndistortCommand=function(self) self:runcommandsonleaves(function(subself) if subself.distort then subself:distort(0) end end) end,

	StorageDevicesChangedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2')
	end,

	CodeMessageCommand=function(self, params)

		if (AutoStyle=="single" or AutoStyle=="double") and params.PlayerNumber ~= mpn then return end

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

	PlayerJoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2')
	end,

	PlayerUnjoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2')
	end,

	OnCommand=function(self, params)
		self:queuecommand('UpdateInternal2')
	end,

	UpdateInternal2Command=function(self)
		if AutoStyle=="none" or AutoStyle=="versus" then
			UpdateInternal3(self, PLAYER_1)
			UpdateInternal3(self, PLAYER_2)
		else
			UpdateInternal3(self, mpn)
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

-- load SelectProfileFrames for both
if AutoStyle=="none" or AutoStyle=="versus" then
	t[#t+1] = LoadActor("PlayerFrame.lua", PLAYER_1)
	t[#t+1] = LoadActor("PlayerFrame.lua", PLAYER_2)

-- load only for the MasterPlayerNumber
else
	t[#t+1] = LoadActor("PlayerFrame.lua", mpn)
end

return t