if not ThemePrefs.Get("RainbowMode") and ThemePrefs.Get("VisualStyle") ~= "SRPG5" then return Def.Actor{ InitCommand=function(self) self:visible(false) end } end

return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(self) self:FullScreen():Center():diffuse( Color.White ) end
	},

	LoadActor( THEME:GetPathB("", "_shared background") ),

	Def.Quad{
		InitCommand=function(self)
			self:diffuse(ThemePrefs.Get("VisualStyle") == "SRPG5" and Color.Black or Color.White):Center():FullScreen()
				:sleep(0.6):linear(0.5):diffusealpha(0)
				:queuecommand("Hide")
		end,
		HideCommand=function(self) self:visible(false) end
	}
}
