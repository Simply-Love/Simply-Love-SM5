local audio_file =  ThemePrefs.Get("VisualTheme")

-- the best way to spread holiday cheer is singing loud for all to hear
if PREFSMAN:GetPreference("EasterEggs") and MonthOfYear()==11 then
	audio_file = "HolidayCheer"
end

return THEME:GetPathS("", "_common menu music/" .. audio_file)