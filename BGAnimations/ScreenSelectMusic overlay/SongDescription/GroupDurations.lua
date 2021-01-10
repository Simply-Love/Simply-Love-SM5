-- before loading actors, pre-calculate each group's overall duration by
-- looping through its songs and summing their durations.
--
-- store each group's overall duration in a lookup table, keyed by group_name,
-- to be retrieved + displayed when actively hovering on a group (not a song)

local group_durations = {}
local stages_remaining = GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber())

for _,group_name in ipairs(SONGMAN:GetSongGroupNames()) do
	group_durations[group_name] = 0

	for _,song in ipairs(SONGMAN:GetSongsInGroup(group_name)) do

		-- only include songs if they have playable steps
		-- for the current game (dance, pump, etc.) and style (single, double, solo, etc.)
		if #SongUtil.GetPlayableSteps(song) > 0
		and (GAMESTATE:IsEventMode() or song:GetStageCost() <= stages_remaining)
		then
			group_durations[group_name] = group_durations[group_name] + song:MusicLengthSeconds()
		end
	end
end

-- aside: A consequence of pre-calculating and storing the group_durations like this is
-- that reloading a song on ScreenSelectMusic via [Shift Control R] might cause the
-- group duration to then be inaccurate until the screen is reloaded.
-- ScreenSelectMusic.cpp does not broadcast anything to Lua when a song reload occurs,
-- so there's not much that can be done to handle this (admittedly uncommon) event.

return group_durations