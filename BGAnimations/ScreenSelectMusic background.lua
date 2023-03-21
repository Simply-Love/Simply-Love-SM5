if not ThemePrefs.Get("RainbowMode") and ThemePrefs.Get("VisualStyle") ~= "SRPG6" and ThemePrefs.Get("VisualStyle") ~= "Technique" then return Def.Actor{ InitCommand=function(self) self:visible(false) end } end

return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(self) self:FullScreen():Center():diffuse( Color.White ) end
	},

	LoadActor( THEME:GetPathB("", "_shared background") ),

	Def.Quad{
		InitCommand=function(self)
			self:diffuse((ThemePrefs.Get("VisualStyle") == "SRPG6" or ThemePrefs.Get("VisualStyle" == "Technique")) and Color.Black or Color.White):Center():FullScreen()
				:sleep(0.6):linear(0.5):diffusealpha(0)
				:queuecommand("Hide")
		end,
		HideCommand=function(self) self:visible(false) end
	}
}
