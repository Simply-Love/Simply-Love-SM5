local t = Def.ActorFrame{
	Name="WheelHighlight",
	InitCommand=function(self)
		self:x(IsUsingWideScreen() and _screen.cx or _screen.cx + 160)
		self:y(IsUsingWideScreen() and _screen.cy + 45 or  _screen.cy - 53)
	end,

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