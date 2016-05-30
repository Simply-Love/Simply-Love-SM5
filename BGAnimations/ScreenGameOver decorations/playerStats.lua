local player = ...
local profile = PROFILEMAN:GetProfile(player)
local playerName = profile:GetLastUsedHighScoreName()
local totalSongs = profile:GetNumTotalSongsPlayed()
local calories = round(profile:GetCaloriesBurnedToday())

local stageStats = STATSMAN:GetCurStageStats()
local currentCombo = stageStats:GetPlayerStageStats(player):GetCurrentCombo()
local x_pos = player == PLAYER_1 and 80 or _screen.w-80

local totalTime = 0
for i,stats in ipairs(SL[ToEnumShortString(player)].Stages.Stats) do
	totalTime = stats.duration and (totalTime + stats.duration) or 0
end

local minutes = math.floor(totalTime/60)
local seconds = round(totalTime%60)

local text = {
	playerName,
	THEME:GetString("ScreenGameOver", "CaloriesBurned") .. "\n" .. calories,
	THEME:GetString("ScreenGameOver", "CurrentCombo") .. "\n"..currentCombo,
	THEME:GetString("ScreenGameOver", "TotalSongsPlayed") .. "\n"..totalSongs,
	THEME:GetString("ScreenGameOver", "TotalTimeSpent") .. ":\n".. minutes .. THEME:GetString("ScreenGameOver", "Minutes") .. " " .. seconds .. THEME:GetString("ScreenGameOver", "Seconds")
}

-- if the player has opted to ignore the engine's sense of Calories burned
-- in favor of the HeartRate entry screen, then remove the line regarding
-- calories burned, which relies on the engine.
if profile:GetIgnoreStepCountCalories() then
	table.remove(text, 2)
end

local t = Def.ActorFrame{}

for i,txt in ipairs(text) do
	t[#t+1] = Def.BitmapText{
		Font="_miso",
		Text=txt,
		InitCommand=cmd(diffuse, PlayerColor(player); xy, x_pos, (60*(i-1)) + 40)
	}
end

return t