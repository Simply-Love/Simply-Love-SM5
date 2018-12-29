local songs = {
	Arrows = "cloud break (loop).ogg",
	Bears = "crystalis (loop).ogg",
	Hearts = "feel (loop).ogg",
	Ducks = "Xuxa fami VRC6 (loop).ogg",
	Gay = "Mystical Wheelbarrow Journey (loop).ogg",
	Spooky = "Spooky Scary Chiptunes (loop).ogg"
}

local audio_file =  songs[ ThemePrefs.Get("VisualTheme") ]

-- the best way to spread holiday cheer is singing loud for all to hear
if PREFSMAN:GetPreference("EasterEggs") and MonthOfYear()==11 then
	audio_file = "HolidayCheer"
end

return THEME:GetPathS("", "_common menu music/" .. audio_file)