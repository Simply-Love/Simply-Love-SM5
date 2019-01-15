local player = ...

local totalTime = 0
local songsPlayedThisGame = 0
local notesHitThisGame = 0

-- Use pairs here (instead of ipairs) because this player might have late-joined
-- which will result in nil entries in the the Stats table, which halts ipairs.
-- We're just summing total time anyway, so order doesn't matter.
for i,stats in pairs( SL[ToEnumShortString(player)].Stages.Stats ) do
	totalTime = totalTime + (stats and stats.duration or 0)
	songsPlayedThisGame = songsPlayedThisGame + (stats and 1 or 0)

	-- increment notesHitThisGame by the total number of tapnotes in this particular stepchart
	-- this is more accurate than incrementing by non-Miss judgments because stepcharts can have non-1 #COMBOS parameters set
	-- which would artbitraily inflate notesHitThisGame
	-- also, use RadarCategory_Notes because we want jumps/hands to count as more than 1 here
	-- (using RadarCategory_TapsAndHolds has jumps/hands count as 1)
	notesHitThisGame = notesHitThisGame + stats.steps:GetRadarValues(player):GetValue("RadarCategory_Notes")

	-- and then subtract the number of Miss judgments that occurred this set, per-column
	-- this is more accurate than subtracting the number of Miss judgments because
	-- we want jumps/hands to count as more than 1 here
	for column, judgments in ipairs(stats.column_judgments) do
		notesHitThisGame = notesHitThisGame - judgments.Miss
	end
end

local hours = math.floor(totalTime/3600)
local minutes = math.floor((totalTime-(hours*3600))/60)
local seconds = round(totalTime%60)

local lines = {
	ScreenString("SongsPlayedThisGame") .. "\n" .. songsPlayedThisGame,
	ScreenString("NotesHitThisGame") .. "\n" .. notesHitThisGame,
	ScreenString("TimeSpentThisGame") .. "\n" .. minutes .. THEME:GetString("ScreenGameOver", "Minutes") .. " " .. seconds .. THEME:GetString("ScreenGameOver", "Seconds")
}

-- assume above that the gameplay session was < 1 hour, but check now
-- just in case, and modify the last line accordingly if needed
if hours > 0 then
	lines[3] = ScreenString("TimeSpentThisGame") .. "\n"..
		hours .. ScreenString("Hours") .. " " ..
		minutes .. ScreenString("Minutes") .. " " ..
		seconds .. ScreenString("Seconds")
end

return lines