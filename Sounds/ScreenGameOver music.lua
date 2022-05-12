local audio_file = "serenity in ruin.ogg"

local style = ThemePrefs.Get("VisualStyle")
if style == "SRPG6" then
	audio_file = "SRPG6-GameOver.ogg"
end

return THEME:GetPathS("", audio_file)
