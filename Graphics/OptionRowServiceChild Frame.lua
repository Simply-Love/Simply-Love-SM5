local title_bg_width = _screen.w*WideScale(0.18,0.15)
local t = Def.ActorFrame{}
t.InitCommand=function(self) self:x(WideScale(12,30)) end

-- a row
t[#t+1] = Def.Quad {
	Name="RowBackgroundQuad",
	InitCommand=function(self) self:zoomto(_screen.w * WideScale(0.475,0.54), _screen.h*0.0625):halign(0) end
}

-- black quad behind the title
t[#t+1] = Def.Quad {
	Name="TitleBackgroundQuad",
	OnCommand=function(self)
		self:zoomto(title_bg_width, _screen.h*0.0625)
			:halign(0):x(0)
			:diffuse(Color.Black):diffusealpha( BrighterOptionRows() and 0.75 or 0.25)
	end
}

return t