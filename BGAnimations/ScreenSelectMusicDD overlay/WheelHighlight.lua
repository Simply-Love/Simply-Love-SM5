local t = Def.ActorFrame{
	Name="WheelHighlight",
	InitCommand=cmd(x,_screen.cx;y,_screen.cy + 45;),

Def.Quad{
		Name="WheelHighlight",
		InitCommand=function(self)
				self:diffusealpha(0.2)
				self:zoomx(320)
				self:zoomy(24)
				
		end,
		OnCommand=function(self)
		end
	}
}

return t