local title_bg_width = SL_WideScale(115, 128)
local row_height = _screen.h * 0.0625 -- ???

local t = Def.ActorFrame{}
t.InitCommand=function(self) self:x(WideScale(12, 30)) end

-- a row
t[#t+1] = Def.Quad {
	Name="RowBackgroundQuad",
	InitCommand=function(self) self:zoomto(WideScale(304, 460), row_height):halign(0) end
}

-- black quad behind the title
t[#t+1] = Def.Quad {
	Name="TitleBackgroundQuad",
	OnCommand=function(self)
		self:zoomto(title_bg_width, row_height)
			:halign(0):x(0)
			:diffuse(Color.Black):diffusealpha( DarkUI() and 0.75 or 0.25)
	end
}

return t