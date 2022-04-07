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

return lines