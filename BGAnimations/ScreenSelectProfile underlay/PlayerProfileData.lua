-- ----------------------------------------------------
-- some local functions that will help process profile data into presentable strings

local RecentMods = function(mods)
	if type(mods) ~= "table" then return "" end

	local text = ""

	-- SpeedModType should be a string and SpeedMod should be a number
	if type(mods.SpeedModType)=="string" and type(mods.SpeedMod)=="number" then
		-- for ScreenSelectProfile, allow either "x" or "X" to be in the player's profile for SpeedModType
		if (mods.SpeedModType):upper()=="X" and mods.SpeedMod > 0 then
			-- take whatever number is in the player's profile, string format it to 2 decimal places
			-- convert back to a number to remove potential trailing 0s (we want "1.5x" not "1.50x")
			-- and finally convert that back to a string
			text = ("%gx"):format(tonumber(("%.2f"):format(mods.SpeedMod)))

		elseif (mods.SpeedModType=="M" or mods.SpeedModType=="C") and mods.SpeedMod > 0 then
			text = ("%s%.0f"):format(mods.SpeedModType, mods.SpeedMod)
		end
	end

	-- -----------------------------------------------------------------------
	-- the NoteSkin and JudgmentGraphic previews are not text, and are loaded, handled, and positioned separately

	-- ASIDE: My informal testing of reading ~80 unique JudgmentGraphic files from disk and
	-- loading them into memory caused StepMania to hang for a few seconds, so
	-- JudgmentGraphicPreviews.lua and NoteSkinPreviews.lua only load assets that are
	-- needed by current player profiles (not every possible asset).

	-- FIXME: If a profile's values for NoteSkin and/or JudgmentGraphic don't match with anything
	-- available to StepMania (players commonly modify their profiles by hand and introduce typos),
	-- we currently don't show anything.  Maybe a generic graphic of a question mark (or similar)
	-- would be nice but that can wait for a future release.
	-- -----------------------------------------------------------------------

	-- Mini should definitely be a string
	if type(mods.Mini)=="string" and mods.Mini ~= "" then text = ("%s %s, "):format(mods.Mini, THEME:GetString("OptionTitles", "Mini")) end

	-- DataVisualizations should be a string and a specific string at that
	if mods.DataVisualizations=="Target Score Graph" or mods.DataVisualizations=="Step Statistics" then
		text = text .. THEME:GetString("SLPlayerOptions", mods.DataVisualizations)..", "
	end

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

	-- remove trailing comma and whitespace
	text = text:sub(1,-3)

	return text, mods.NoteSkin, mods.JudgmentGraphic
end

-- ----------------------------------------------------
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
-- retrieves profile data from disk without applying it to the SL table

local RetrieveProfileData = function(profile, dir)
	local theme_name = THEME:GetThemeDisplayName()
	local path = dir .. theme_name .. " UserPrefs.ini"
	if FILEMAN:DoesFileExist(path) then
		return IniFile.ReadFile(path)[theme_name]
	end
	return false
end

-- ----------------------------------------------------
-- Retrieve and process data (mods, most recently played song, high score name, etc.)
-- for each available local profile and put it in the profile_data table.
-- Since both players are using the same list of local profiles, this only needs to be performed once (not once for each player).
-- I'm doing it here, in PlayerProfileData.lua, to keep default.lua from growing too large/unwieldy.  Once done, pass the
-- table of data back default.lua where it can be sent via playcommand parameter to the appropriate PlayerFrames as needed.

local profile_data = {}

for i=1, PROFILEMAN:GetNumLocalProfiles() do

	-- GetLocalProfileFromIndex() expects indices to start at 0
	local profile = PROFILEMAN:GetLocalProfileFromIndex(i-1)
	-- GetLocalProfileIDFromIndex() also expects indices to start at 0
	local id = PROFILEMAN:GetLocalProfileIDFromIndex(i-1)
	local dir = PROFILEMAN:LocalProfileIDToDir(id)
	local userprefs = RetrieveProfileData(profile, dir)
	local mods, noteskin, judgment = RecentMods(userprefs)

	local data = {
		index = i,
		dir = dir,
		displayname = profile:GetDisplayName(),
		totalsongs = TotalSongs(profile:GetNumTotalSongsPlayed()),
		mods = mods,
		noteskin = noteskin,
		judgment = judgment,
		guid = profile:GetGUID(),
	}

	table.insert(profile_data, data)
end

return profile_data
