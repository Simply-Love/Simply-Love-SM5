-- ----------------------------------------------------
-- some local functions that will help process profile data into presentable strings

local noteskins = NOTESKIN:GetNoteSkinNames()
local judgment_graphics = {
	ITG=GetJudgmentGraphics("ITG"),
	["FA+"]=GetJudgmentGraphics("FA+"),
	StomperZ=GetJudgmentGraphics("StomperZ"),
}

local RecentMods = function(mods)
	if type(mods) ~= "table" then return "" end

	local text = ""

	-- SpeedModType should be a string and SpeedMod should be a number
	if type(mods.SpeedModType)=="string" and type(mods.SpeedMod)=="number" then
		if mods.SpeedModType=="x" and mods.SpeedMod > 0 then text = text..tostring(mods.SpeedMod).."x"
		elseif (mods.SpeedModType=="M" or mods.SpeedModType=="C") and mods.SpeedMod > 0 then text = text..mods.SpeedModType..tostring(mods.SpeedMod)
		end
	end

	-- Mini should definitely be a string
	if type(mods.Mini)=="string" and mods.Mini ~= "" then text = text..", "..mods.Mini.." "..THEME:GetString("OptionTitles", "Mini") end
	-- time for a linebreak
	text = text.."\n"

	-- a NoteSkin title might consist of only numbers and be read in by the IniFile utility as a number, so just ensure it isn't nil
	if mods.NoteSkin ~= nil and mods.NoteSkin ~= "" then
		if not FindInTable(mods.NoteSkin, noteskins) then
			-- the NoteSkin is not available, so just append the NoteSkin name to the string
			text = text..mods.NoteSkin
		end
		text = text.."\n"
	end

	-- JudgmentGraphic and ComboFont should definitely be strings
	if type(mods.JudgmentGraphic)=="string" and mods.JudgmentGraphic ~= "" then
		if not (FindInTable(mods.JudgmentGraphic, judgment_graphics.ITG) or FindInTable(mods.JudgmentGraphic, judgment_graphics["FA+"]) or FindInTable(mods.JudgmentGraphic, judgment_graphics.StomperZ)) then
			-- the judgment graphic is not available, so just append the JudgmentGraphic to the string
			text = text..StripSpriteHints(mods.JudgmentGraphic)
		end
		text = text.."\n"
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

	-- DataVisualizations should be a string and a specific string at that
	if mods.DataVisualizations=="Target Score Graph" or mods.DataVisualizations=="Step Statistics" then
		text = text .. THEME:GetString("SLPlayerOptions", mods.DataVisualizations)..", "
	end
	-- remove trailing comma and whitespace
	text = text:sub(1,-3)

	return text, mods.NoteSkin, mods.JudgmentGraphic
end
-- ----------------------------------------------------
local RecentSong = function(song)
	if not song then return "" end
	return (song:GetGroupName() .. "/" .. song:GetDisplayMainTitle())
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
	local userprefs = ReadProfileCustom(profile, dir)
	local mods, noteskin, judgment = RecentMods(userprefs)

	local data = {
		index = i,
		displayname = profile:GetDisplayName(),
		highscorename = profile:GetLastUsedHighScoreName(),
		recentsong = RecentSong(profile:GetLastPlayedSong()),
		totalsongs = TotalSongs(profile:GetNumTotalSongsPlayed()),
		mods = mods,
		noteskin = noteskin,
		judgment = judgment,
	}

	table.insert(profile_data, data)
end

return profile_data