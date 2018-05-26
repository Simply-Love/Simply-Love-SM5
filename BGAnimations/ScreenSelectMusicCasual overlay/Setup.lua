-- I think the idea with this file is just to throw setup related
-- stuff in here that we don't want cluttering up default.lua

---------------------------------------------------------------------------
-- because no one wants "Invalid PlayMode 7"
GAMESTATE:SetCurrentPlayMode(0)

---------------------------------------------------------------------------
-- a steps_type like "StepsType_Dance_Single" is needed so we can filter out steps that aren't suitable
-- there has got to be a better way to do this...
local steps_type = "StepsType_"..GAMESTATE:GetCurrentGame():GetName():gsub("^%l", string.upper).."_"
if GAMESTATE:GetCurrentStyle():GetName() == "double" then
	steps_type = steps_type .. "Double"
else
	steps_type = steps_type .. "Single"
end

---------------------------------------------------------------------------
-- parse ./Other/CasualMode-Groups.txt to create a fully custom Casual MusicWheel

local GetGroups = function()

	local contents

	-- the second argument here (the 1) signifies
	-- that we are opening the file in read-only mode
	local path = THEME:GetCurrentThemeDirectory() .. "Other/CasualMode-Groups.txt"

	if FILEMAN:DoesFileExist(path) then
		-- create a generic RageFile that we'll use to read the contents
		local file = RageFileUtil.CreateRageFile()
		if file:Open(path, 1) then
			contents = file:Read()
		end

		-- destroy the generic RageFile now that we have the contents
		file:destroy()
	end

	if contents == nil or contents == "" then
		return SONGMAN:GetSongGroupNames()
	end

	-- split the contents of the file on newline and create a table of "preliminary groups"
	-- some may not actually exist due to human error, typos, etc.
	local preliminary_groups = {}
	for line in contents:gmatch("[^\r\n]+") do
		preliminary_groups[#preliminary_groups+1] = line
	end

	local groups = {}

	for prelim_group in ivalues(preliminary_groups) do
		-- if this group exists
		if SONGMAN:DoesSongGroupExist( prelim_group ) then
			-- add this preliminary group to the table of finalized groups
			groups[#groups+1] = prelim_group
		end
	end

	if #groups > 0 then
		return groups
	else
		return SONGMAN:GetSongGroupNames()
	end
end



---------------------------------------------------------------------------
-- here, we prune out packs that have no valid steps

local current_song = GAMESTATE:GetCurrentSong()
local group_index = 1
local Groups = {}

for group in ivalues( GetGroups() ) do
	local group_has_been_added = false

	for song in ivalues(SONGMAN:GetSongsInGroup(group)) do
		if song:HasStepsType(steps_type) then

			for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
				if steps:GetMeter() < ThemePrefs.Get("CasualMaxMeter") then
					Groups[#Groups+1] = group
					group_has_been_added = true
					break
				end
			end
		end
		if group_has_been_added then break end
	end
end

if current_song then
	group_index = FindInTable(current_song:GetGroupName(), Groups) or 1

-- if no current_song, choose the first song in the first pack as a last resort...
else
	current_song = SONGMAN:GetSongsInGroup(Groups[1])[1]
	GAMESTATE:SetCurrentSong(current_song)
end

return steps_type, Groups, group_index