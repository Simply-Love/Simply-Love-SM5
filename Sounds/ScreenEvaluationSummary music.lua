local audio_file = "_silent"

-- the best way to spread holiday cheer is singing loud for all to hear
if HolidayCheer() then
	audio_file = "jinglebells.ogg"
end

return THEME:GetPathS("", audio_file)