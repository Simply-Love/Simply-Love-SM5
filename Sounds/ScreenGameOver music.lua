local audio_file = "serenity in ruin.ogg"

local style = ThemePrefs.Get("VisualStyle")
if style == "SRPG7" then
	audio_file = "SRPG7-GameOver.ogg"
end

return THEME:GetPathS("", audio_file)
