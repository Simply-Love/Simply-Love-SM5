return Def.ActorFrame{
	OnCommand=function(self)
		ThemePrefs.Save()
	end
}