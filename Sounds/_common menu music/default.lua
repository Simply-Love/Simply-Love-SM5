local songs = {
	Arrows = "cloud break",
	Bears = "crystalis",
	Hearts = "feel",
	Ducks = "Xuxa fami VRC6",
	Gay = "Mystical Wheelbarrow Journey",
	Spooky = "Spooky Scary Chiptunes",
	Stars = "Shooting Star - faux VRC6 remix",
	Thonk = "Da Box of Kardboard Too (feat Naoki vs ZigZag) - TaroNuke Remix",
}

local style = ThemePrefs.Get("VisualTheme")
local file = songs[ style ]
if not file then file = songs.Hearts end

if PREFSMAN:GetPreference("EasterEggs") and style ~= "Thonk" then
	--  41 days remain until the end of the year.
	if MonthOfYear()==10 and DayOfMonth()==20 then file = "20" end
	-- the best way to spread holiday cheer is singing loud for all to hear
	if MonthOfYear()==11 then file = "HolidayCheer" end
end

return THEME:GetPathS("", "_common menu music/" .. file)
