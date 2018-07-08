return Def.Actor{
	BeginCommand=function(self)
		ThemePrefs.Save()

		-- Broadcast a message for "_shared background normal" to listen for in case VisualTheme has changed.
		-- This compensates for ThemePrefsRows' lack of support for ExportOnChange() and SaveSelections().
		MESSAGEMAN:Broadcast("BackgroundImageChanged")
	end
}