local player = ...

local stageStats = STATSMAN:GetCurStageStats()
local currentCombo = stageStats:GetPlayerStageStats(player):GetCurrentCombo()

local totalTime = 0
local songsPlayedThisGame = 0

-- Use pairs here (instead of ipairs) because this player might have late-joined
-- which will result in nil entries in the the Stats table, which halts ipairs.
-- We're just summing total time anyway, so order doesn't matter.
for i,stats in pairs( SL[ToEnumShortString(player)].Stages.Stats ) do
	totalTime = totalTime + (stats and stats.duration or 0)
	songsPlayedThisGame = songsPlayedThisGame + (stats and 1 or 0)
end

local hours = math.floor(totalTime/3600)
local minutes = math.floor((totalTime-(hours*3600))/60)
local seconds = round(totalTime%60)

local lines = {
	ScreenString("CurrentCombo") .. "\n"..currentCombo,
	ScreenString("SongsPlayedThisGame") .. "\n"..songsPlayedThisGame,
	ScreenString("TimeSpentThisGame") .. "\n".. minutes .. THEME:GetString("ScreenGameOver", "Minutes") .. " " .. seconds .. THEME:GetString("ScreenGameOver", "Seconds")
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