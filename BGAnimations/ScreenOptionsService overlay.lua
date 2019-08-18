return Def.Actor{
	BeginCommand=function(self)
		ThemePrefs.Save()

		-- Broadcast a message for "./BGAnimations/_shared background/" to listen for in case VisualTheme has changed.
		-- This compensates for ThemePrefsRows' current lack of support for ExportOnChange() and SaveSelections().
		MESSAGEMAN:Broadcast("BackgroundImageChanged")
	end
}