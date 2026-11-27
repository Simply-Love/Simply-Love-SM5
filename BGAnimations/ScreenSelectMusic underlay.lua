return Def.Quad{
	InitCommand=function(self)
		self:diffuse((ThemePrefs.Get("VisualStyle") == "SRPG6") and Color.Black or Color.White)
			:Center()
			:FullScreen()
			:sleep(0.6):linear(0.5):diffusealpha(0)
			:queuecommand("Hide")
	end,
	HideCommand=function(self) self:visible(false) end
}
