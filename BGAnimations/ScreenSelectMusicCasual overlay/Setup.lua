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
local current_song = GAMESTATE:GetCurrentSong()
local group_index = 1

-- prune out packs that have no valid steps
local Groups = {}

for group in ivalues(SONGMAN:GetSongGroupNames()) do
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
	group_index = FindInTable(current_song:GetGroupName(), Groups)
end

-- if no current_song, choose the first song in the first pack as a last resort...
if not current_song then
	current_song = SONGMAN:GetSongsInGroup(Groups[1])[1]
	GAMESTATE:SetCurrentSong(current_song)
end

return steps_type, Groups, group_index