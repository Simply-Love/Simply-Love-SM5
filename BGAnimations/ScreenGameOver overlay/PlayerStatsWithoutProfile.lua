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

local minutes = math.floor(totalTime/60)
local seconds = round(totalTime%60)

local lines = {
	"",
	"",
	"",
	"---",
	ScreenString("CurrentCombo") .. "\n"..currentCombo,
	ScreenString("SongsPlayedThisGame") .. "\n"..songsPlayedThisGame,
	ScreenString("TimeSpentThisGame") .. "\n".. minutes .. THEME:GetString("ScreenGameOver", "Minutes") .. " " .. seconds .. THEME:GetString("ScreenGameOver", "Seconds")
}

return lines