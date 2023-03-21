local songs = {
	Hearts = "feel",
	Arrows = "cloud break",
	Bears  = "crystalis",
	Ducks  = "Xuxa fami VRC6",
	Cats   = "Beanmania IIDX",
	Spooky = "Spooky Scary Chiptunes",
	Gay    = "Mystical Wheelbarrow Journey",
	Stars  = "Shooting Star - faux VRC6 remix",
	Thonk  = "Da Box of Kardboard Too (feat Naoki vs ZigZag) - TaroNuke Remix",
	Technique = "Quaq",
	SRPG6  = "SRPG6",
}

-- retrieve the current VisualStyle from the ThemePrefs system
local style = ThemePrefs.Get("VisualStyle")

-- use the style to index the songs table (above)
-- and get the song associated with this VisualStyle
local file = songs[ style ]

-- if a song file wasn't defined in the songs table above
-- fall back on the song for Hearts as default music
-- (this sometimes happens when people are experimenting
-- with making their own custom VisualStyles)
if not file then file = songs.Hearts end

-- annnnnd some EasterEggs
if PREFSMAN:GetPreference("EasterEggs") and style ~= "Thonk" then
	--  41 days remain until the end of the year.
	if MonthOfYear()==10 and DayOfMonth()==20 then file = "20" end
	-- the best way to spread holiday cheer is singing loud for all to hear
	if MonthOfYear()==11 then file = "HolidayCheer" end
end

return THEME:GetPathS("", "_common menu music/" .. file)
