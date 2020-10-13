if ThemePrefs.Get("VisualStyle") == "Thonk" then
	return LoadActor(THEME:GetPathB("Thonk", "overlay"))
else
	return NullActor
end