local player = ...
local profile = PROFILEMAN:GetProfile(player)
local playerName = profile:GetDisplayName()
local calories = round(profile:GetCaloriesBurnedToday())
local totalSongs = profile:GetNumTotalSongsPlayed()

local lines = {
	playerName,
	ScreenString("CaloriesBurned") .. "\n" .. calories,
	ScreenString("TotalSongsPlayed") .. "\n"..totalSongs,
}

-- if the player has opted to ignore the engine's sense of Calories burned
-- in favor of the HeartRate entry screen, then remove the line regarding
-- calories burned, which relies on the engine.
if profile:GetIgnoreStepCountCalories() then
	lines[2] = ""
end

return lines