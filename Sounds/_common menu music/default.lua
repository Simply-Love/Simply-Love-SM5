local audio_file =  ThemePrefs.Get("VisualTheme")

-- Halloween
if MonthOfYear() == 8 and DayOfMonth() >= 14 then
	audio_file = "eggs/Spooky"
end

-- xmas
if MonthOfYear() == 11 then
	audio_file = "eggs/xmas"
end

return THEME:GetPathS("", "_common menu music/" .. audio_file)