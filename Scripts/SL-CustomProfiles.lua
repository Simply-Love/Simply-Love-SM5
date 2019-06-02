-- It's possible for players to edit their Simply Love UserPrefs.ini file
-- in various ways that might break the theme.  Also, sometimes theme-specific mods
-- are deprecated or change their internal name, leaving old values behind in player profiles
-- that might break the theme as well. Use this table to validate settings read in
-- from and written out to player profiles.
--
-- For now, this table is local to this file, but might be moved into the SL table (or something)
-- in the future to facilitate type checking in ./Scripts/SL-PlayerOptions.lua and elsewhere.

local profile_whitelist = {
	SpeedModType = "string",
	SpeedMod = "number",
	Mini = "string",
	NoteSkin = "string",
	JudgmentGraphic = "string",
	BackgroundFilter = "string",

	HideTargets = "boolean",
	HideSongBG = "boolean",
	HideCombo = "boolean",
	HideLifebar = "boolean",
	HideScore = "boolean",
	HideDanger = "boolean",
	HideComboExplosions = "boolean",

	LifeMeterType = "string",
	DataVisualizations = "string",
	TargetScore = "number",
	ActionOnMissedTarget = "string",

	MeasureCounter = "string",
	MeasureCounterLeft = "boolean",
	MeasureCounterUp = "boolean",
	HideRestCounts = "boolean",

	ColumnFlashOnMiss = "boolean",
	SubtractiveScoring = "boolean",
	Pacemaker = "boolean",
	MissBecauseHeld = "boolean",
	NPSGraphAtTop = "boolean",

	Vocalization = "string",
	ReceptorArrowsPosition = "string",
}

-- ------------------------------------------

local theme_name = THEME:GetThemeDisplayName()
local filename =  theme_name .. " UserPrefs.ini"

-- Hook called during profile load
function LoadProfileCustom(profile, dir)

	local path =  dir .. filename
	local pn, filecontents

	-- we've been passed a profile object as the variable "profile"
	-- see if it matches against anything returned by PROFILEMAN:GetProfile(player)
	for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
		if profile == PROFILEMAN:GetProfile(player) then
			pn = ToEnumShortString(player)
			break
		end
	end

	if pn and FILEMAN:DoesFileExist(path) then
		filecontents = IniFile.ReadFile(path)[theme_name]

		for k,v in pairs(filecontents) do
			-- ensure that the setting read in from profile exists and type check if so
			if profile_whitelist[k] and type(v)==profile_whitelist[k] then
				SL[pn].ActiveModifiers[k] = v
			end
		end
	end

	return true
end

-- Hook called during profile save
function SaveProfileCustom(profile, dir)

	local path =  dir .. filename

	for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
		if profile == PROFILEMAN:GetProfile(player) then
			local pn = ToEnumShortString(player)
			local output = {}
			for k,v in pairs(SL[pn].ActiveModifiers) do
				if profile_whitelist[k] and type(v)==profile_whitelist[k] then
					output[k] = v
				end
			end
			IniFile.WriteFile( path, {[theme_name]=output} )
			break
		end
	end

	return true
end

-- for when you just want to retrieve profile data from disk without applying it to the SL table
function ReadProfileCustom(profile, dir)
	local path = dir .. filename
	if FILEMAN:DoesFileExist(path) then
		return IniFile.ReadFile(path)[theme_name]
	end
	return false
end