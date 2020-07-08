if ThemePrefs.Get("VisualTheme") == "Thonk" then
	return LoadActor(THEME:GetPathB("Thonk", "overlay"))
else
	return NullActor
end