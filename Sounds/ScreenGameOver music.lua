local audio_file = "serenity in ruin.ogg"

local style = ThemePrefs.Get("VisualStyle")
if style == "SRPG8" then
	audio_file = "SRPG8-GameOver.ogg"
end

return THEME:GetPathS("", audio_file)
