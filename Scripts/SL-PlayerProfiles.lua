-- It's possible for players to edit their Simply Love UserPrefs.ini file
-- in various ways that might break the theme.  Also, sometimes theme-specific mods
-- are deprecated or change their internal name, leaving old values behind in player profiles
-- that might break the theme as well. Use this table to validate settings read in
-- from and written out to player profiles.
--
-- For now, this table is local to this file, but might be moved into the SL table (or something)
-- in the future to facilitate type checking in ./Scripts/SL-PlayerOptions.lua and elsewhere.

local permitted_profile_settings = {

	----------------------------------
	-- "Main Modifiers"
	-- OptionRows that appear in SL's first page of PlayerOptions

	SpeedModType     = "string",
	SpeedMod         = "number",
	Mini             = "string",
	NoteSkin         = "string",
	JudgmentGraphic  = "string",
	ComboFont        = "string",
	HoldJudgment     = "string",
	BackgroundFilter = "string",

	----------------------------------
	-- "Advanced Modifiers"
	-- OptionRows that appear in SL's second page of PlayerOptions

	HideTargets          = "boolean",
	HideSongBG           = "boolean",
	HideCombo            = "boolean",
	HideLifebar          = "boolean",
	HideScore            = "boolean",
	HideDanger           = "boolean",
	HideComboExplosions  = "boolean",

	LifeMeterType        = "string",
	DataVisualizations   = "string",
	StepStatsExtra       = "string",
	TargetScore          = "number",
	ActionOnMissedTarget = "string",

	MeasureCounter       = "string",
	MeasureCounterLeft   = "boolean",
	MeasureCounterUp     = "boolean",
	BrokenRun            = "boolean",
	RunTimer             = "boolean",
	MeasureCounterLookahead = "number",
	
	RainbowMax           = "boolean",
	ResponsiveColors     = "boolean",
	
	MiniIndicator		 = "string",
	MiniIndicatorColor	 = "string",

	ColumnFlashOnMiss    = "boolean",
	SubtractiveScoring   = "boolean",
	Pacemaker            = "boolean",
	MissBecauseHeld      = "boolean",
	TrackEarlyJudgments  = "boolean",
	NPSGraphAtTop        = "boolean",
	JudgmentTilt         = "boolean",
	ColumnCues           = "boolean",
	ColumnCountdown      = "boolean",
	DisplayScorebox      = "boolean",

	ErrorBar             = "string",
	ErrorBarUp           = "boolean",
	ErrorBarMultiTick    = "boolean",
	ErrorBarCap    		 = "number",

	ShowFaPlusWindow = "boolean",
	ShowEXScore      = "boolean",
	ShowFaPlusPane   = "boolean",
	SmallerWhite     = "boolean",

	VisualDelay          = "string",
	NotefieldShift       = "string",
	
	FlashMiss            = "boolean",
	FlashWayOff          = "boolean",
	FlashDecent          = "boolean",
	FlashGreat           = "boolean",
	FlashExcellent       = "boolean",
	FlashFantastic       = "boolean",
	
	BeatBars			 = "string",

	GrowCombo			 = "boolean",
	SpinCombo			 = "boolean",
	WildCombo			 = "boolean",
	RainbowComboOptions	 = "string",
	TiltOptions			 = "string",
	Waterfall			 = "boolean",
	FadeFantastic		 = "boolean",
	NoBar				 = "boolean",

	----------------------------------
	-- Profile Settings without OptionRows
	-- these settings are saved per-profile, but are transparently managed by the theme
	-- they have no player-facing OptionRows

	PlayerOptionsString = "string",
}

-- -----------------------------------------------------------------------

local theme_name = THEME:GetThemeDisplayName()
local filename =  theme_name .. " UserPrefs.ini"

-- function assigned to "CustomLoadFunction" under [Profile] in metrics.ini
LoadProfileCustom = function(profile, dir)

	local path =  dir .. filename
	local player, pn, filecontents

	-- we've been passed a profile object as the variable "profile"
	-- see if it matches against anything returned by PROFILEMAN:GetProfile(player)
	for p in ivalues( GAMESTATE:GetHumanPlayers() ) do
		if profile == PROFILEMAN:GetProfile(p) then
			player = p
			pn = ToEnumShortString(p)
			break
		end
	end

	if pn then
		SL[pn]:initialize()
		ParseGrooveStatsIni(player)
	end

	if pn and FILEMAN:DoesFileExist(path) then
		filecontents = IniFile.ReadFile(path)[theme_name]

		-- for each key/value pair read in from the player's profile
		for k,v in pairs(filecontents) do
			-- ensure that the key has a corresponding key in permitted_profile_settings
			if permitted_profile_settings[k]
			--  ensure that the datatype of the value matches the datatype specified in permitted_profile_settings
			and type(v)==permitted_profile_settings[k] then
				-- if the datatype is string and this key corresponds with an OptionRow in ScreenPlayerOptions
				-- ensure that the string read in from the player's profile
				-- is a valid value (or choice) for the corresponding OptionRow
				if type(v) == "string" and CustomOptionRow(k) and FindInTable(v, CustomOptionRow(k).Values or CustomOptionRow(k).Choices)
				or type(v) ~= "string" then
					SL[pn].ActiveModifiers[k] = v
				end

				-- special-case PlayerOptionsString for now
				-- it is saved to and read from profile as a string, but doesn't have a corresponding
				-- OptionRow in ScreenPlayerOptions, so it will fail validation above
				-- we want engine-defined mods (e.g. dizzy) to be applied as well, not just SL-defined mods
				if k=="PlayerOptionsString" and type(v)=="string" then
					-- v here is the comma-delimited set of modifiers the engine's PlayerOptions interface understands

					-- update the SL table so that this PlayerOptionsString value is easily accessible throughout the theme
					SL[pn].PlayerOptionsString = v

					-- use the engine's SetPlayerOptions() method to set a whole bunch of mods in the engine all at once
					GAMESTATE:GetPlayerState(player):SetPlayerOptions("ModsLevel_Preferred", v)

					-- However! It's quite likely that a FailType mod could be in that^ string, meaning a player could
					-- have their own setting for FailType saved to their profile.  I think it makes more sense to let
					-- machine operators specify a default FailType at a global/machine level, so use this opportunity to
					-- use the PlayerOptions interface to set FailSetting() using the default FailType setting from
					-- the operator menu's Advanced Options
					GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):FailSetting( GetDefaultFailType() )
				end
			end
		end
	end

	return true
end

-- function assigned to "CustomSaveFunction" under [Profile] in metrics.ini
SaveProfileCustom = function(profile, dir)

	local path =  dir .. filename

	for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
		if profile == PROFILEMAN:GetProfile(player) then
			local pn = ToEnumShortString(player)
			local output = {}
			for k,v in pairs(SL[pn].ActiveModifiers) do
				if permitted_profile_settings[k] and type(v)==permitted_profile_settings[k] then
					output[k] = v
				end
			end

			-- these values are saved outside the SL[pn].ActiveModifiers tables
			-- and thus won't be handled in the loop above
			output.PlayerOptionsString = SL[pn].PlayerOptionsString

			IniFile.WriteFile( path, {[theme_name]=output} )

			-- Write to the ITL file if we need to.
			-- The ITLData table will only contain data for memory cards.
			if #SL[pn].ITLData ~= 0 then
				WriteItlFile(dir, table.concat(SL[pn].ITLData, ""))
			end

			break
		end
	end

	return true
end

-- -----------------------------------------------------------------------
-- returns a path to a profile avatar, or nil if none is found

GetAvatarPath = function(profileDirectory, displayName)

	if type(profileDirectory) ~= "string" then return end

	local path = nil

	-- sequence matters here
	-- prefer png first, then jpg, then jpeg, etc.
	-- (note that SM5 does not support animated gifs at this time, so SL doesn't either)
	-- TODO: investigate effects (memory footprint, fps) of allowing movie files as avatars in SL
	local extensions = { "png", "jpg", "jpeg", "bmp", "gif" }

	-- prefer an avatar named:
	--    "avatar" in the player's profile directory (preferred by Simply Love)
	--    then "profile picture" in the player's profile directory (used by Digital Dance)
	--    then (whatever the profile's DisplayName is) in /Appearance/Avatars/ (used in OutFox?)
	local paths = {
		("%savatar"):format(profileDirectory),
		("%sprofile picture"):format(profileDirectory),
		("/Appearance/Avatars/%s"):format(displayName)
	}

	for _, path in ipairs(paths) do
		for _, extension in ipairs(extensions) do
			local avatar_path = ("%s.%s"):format(path, extension)

			if FILEMAN:DoesFileExist(avatar_path)
			and ActorUtil.GetFileType(avatar_path) == "FileType_Bitmap"
			then
				-- return the first valid avatar path that is found
				return avatar_path
			end
		end
	end

	-- or, return nil if no avatars were found in any of the permitted paths
	return nil
end

-- -----------------------------------------------------------------------
-- returns a path to a player's profile avatar, or nil if none is found

GetPlayerAvatarPath = function(player)
	if not player then return end

	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}

	if not profile_slot[player] then return end

	local dir  = PROFILEMAN:GetProfileDir(profile_slot[player])
	local name = PROFILEMAN:GetProfile(player):GetDisplayName()

	return GetAvatarPath(dir, name)
end
