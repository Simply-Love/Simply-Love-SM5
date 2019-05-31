-- AutoStyle is a Simply Love ThemePref that can allow players to always
-- automatically have one of [single, double, versus] chosen for them.
-- If AutoStyle is either "single" or "double", we don't want to load
-- SelectProfileFrames for both PLAYER_1 and PLAYER_2, but only the MasterPlayerNumber
local AutoStyle = ThemePrefs.Get("AutoStyle")

-- retrieve the MasterPlayerNumber now, at initialization, so that if AutoStyle is set
-- to "single" or "double" and that singular player unjoins, we still have a handle on
-- which PlayerNumber they're supposed to be...
local mpn = GAMESTATE:GetMasterPlayerNumber()

-- ----------------------------------------------------
-- some local functions that will help process profile data into presentable strings

local RecentMods = function(mods)
	if type(mods) ~= "table" then return "" end

	local text = ""

	-- SpeedModType should be a string and SpeedMod should be a number
	if type(mods.SpeedModType)=="string" and type(mods.SpeedMod)=="number" then
		if mods.SpeedModType=="x" and mods.SpeedMod > 0 then text = text..tostring(mods.SpeedMod).."x, "
		elseif (mods.SpeedModType=="M" or mods.SpeedModType=="C") and mods.SpeedMod > 0 then text = text..mods.SpeedModType..tostring(mods.SpeedMod)..", "
		end
	end

	-- a NoteSkin title might consist of only numbers and be read in by the IniFile utility as a number, so just ensure it isn't nil
	if mods.NoteSkin ~= nil and mods.NoteSkin ~= "" then text = text..mods.NoteSkin..", " end

	-- Mini and JudgmentGraphic should definitely be strings
	if type(mods.Mini)=="string" and mods.Mini ~= "" and mods.Mini ~= "0%" then text = text..mods.Mini.." "..THEME:GetString("OptionTitles", "Mini")..", " end
	if type(mods.JudgmentGraphic)=="string" and mods.JudgmentGraphic ~= "" then text = text..StripSpriteHints(mods.JudgmentGraphic) .. ", " end

	-- loop for mods that save as booleans
	local flags, hideflags = "", ""
	for k,v in pairs(mods) do
		-- explicitly check for true (not Lua truthiness)
		if v == true then
			-- gsub() returns two values:
			-- the string resulting from the substitution, and the number of times the substitution occurred (0, 1, 2, 3, ...)
			-- custom modifier strings in SL should have "Hide" occur as a substring 0 or 1 times
			local mod, hide = k:gsub("Hide", "")

			if THEME:HasString("SLPlayerOptions", mod) then
				if hide == 0 then
					flags = flags..THEME:GetString("SLPlayerOptions", mod)..", "
				elseif hide == 1 then
					hideflags = hideflags..THEME:GetString("ThemePrefs", "Hide").." "..THEME:GetString("SLPlayerOptions", mod)..", "
				end
			end
		end
	end
	text = text .. hideflags .. flags

	-- DataVisualizations should be a string and a specific string at that
	if mods.DataVisualizations=="Target Score Graph" or mods.DataVisualizations=="Step Statistics" then
		text = text .. THEME:GetString("SLPlayerOptions", mods.DataVisualizations)..", "
	end
	-- remove trailing comma and whitespace
	return text:sub(1,-3)
end

local RecentSong = function(song)
	if not song then return "" end
	return (song:GetGroupName() .. "/" .. song:GetDisplayMainTitle())
end

-- profiles have a GetTotalSessions() method, but the value doesn't (seem to?) increment in EventMode
-- making it much less useful for the players who will most likely be using this screen
-- for now, just retrieve total songs played
local TotalSongs = function(numSongs)
	if numSongs == 1 then
		return Screen.String("SingularSongPlayed"):format(numSongs)
	else
		return Screen.String("SeveralSongsPlayed"):format(numSongs)
	end
	return ""
end

-- ----------------------------------------------------
-- retrieve and process data (mods, most recently played song, high score name, etc.)
-- for each profile at Init and put it in the profile_data table indexed by "ProfileIndex" (provided by engine)
-- Since both players are using the same list of local profiles, this only needs to be performed once (not once for each player)
-- so do it here, in default.lua, and pass the relevent data off to the appropriate PlayerFrames as needed.

local profile_data = {}

for i=0, PROFILEMAN:GetNumLocalProfiles()-1 do

	local profile = PROFILEMAN:GetLocalProfileFromIndex(i)
	local id = PROFILEMAN:GetLocalProfileIDFromIndex(i)
	local dir = PROFILEMAN:LocalProfileIDToDir(id)
	local userprefs = ReadProfileCustom(profile, dir)

	profile_data[i] = {
		highscorename = profile:GetLastUsedHighScoreName(),
		recentsong = RecentSong(profile:GetLastPlayedSong()),
		totalsongs = TotalSongs(profile:GetNumTotalSongsPlayed()),
		mods = RecentMods(userprefs)
	}
end

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

			local index = SCREENMAN:GetTopScreen():GetProfileIndex(Player)

			if index > 0 then
				scroller:SetDestinationItem(index-1)
				seltext:settext(PROFILEMAN:GetLocalProfileFromIndex(index-1):GetDisplayName())
				if profile_data[index-1] then
					dataframe:playcommand("Set", {data=profile_data[index-1]})
				end
			else
				if SCREENMAN:GetTopScreen():SetProfileIndex(Player, 1) then
					scroller:SetDestinationItem(0)
					self:queuecommand('Update')
				else
					-- if the profile fails to apply, we end up in here
					-- I've never seen it happen, but I guess it's possible
					joinframe:visible(true)
					scrollerframe:visible(false)
					seltext:settext(ScreenString("NoProfile"))
				end
			end
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
	InitCommand=function(self) self:queuecommand("Capture") end,
	CaptureCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./Input.lua", self) ) end,

	-- the OffCommand will have been queued, when it is appropriate, from ./Input.lua
	-- sleep for 0.5 seconds to give the PlayerFrames time to tween out
	-- and queue a call to Finish() so that the engine can wrap things up
	OffCommand=function(self) self:sleep(0.5):queuecommand("Finish") end,
	FinishCommand=function(self) SCREENMAN:GetTopScreen():Finish() end,
	WhatMessageCommand=function(self) self:runcommandsonleaves(function(subself) if subself.distort then subself:distort(0.5) end end):sleep(4):queuecommand("Undistort") end,
	UndistortCommand=function(self) self:runcommandsonleaves(function(subself) if subself.distort then subself:distort(0) end end) end,

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

-- load PlayerFrames for both
if AutoStyle=="none" or AutoStyle=="versus" then
	t[#t+1] = LoadActor("PlayerFrame.lua", PLAYER_1)
	t[#t+1] = LoadActor("PlayerFrame.lua", PLAYER_2)

-- load only for the MasterPlayerNumber
else
	t[#t+1] = LoadActor("PlayerFrame.lua", mpn)
end

return t