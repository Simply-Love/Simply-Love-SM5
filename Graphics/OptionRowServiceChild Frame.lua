local t = Def.ActorFrame{}
local title_bg_width = _screen.w*WideScale(0.18,0.15)

-- a row
t[#t+1] = Def.Quad {
	Name="RowBackgroundQuad",
	InitCommand=function(self) self:zoomto(_screen.w * WideScale(0.475,0.45), _screen.h*0.0625) end
}

-- black quad behind the title
t[#t+1] = Def.Quad {
	Name="TitleBackgroundQuad",
	OnCommand=function(self)
		self:zoomto(title_bg_width, _screen.h*0.0625)
			:x( -self:GetParent():GetX() + WideScale(70,90) )
			:diffuse(Color.Black):diffusealpha(0.25)
	end
}

return t