local row_height = 30
local row_width = {
	active   = WideScale(304, 460),
	inactive = WideScale(300, 456)
}


local t = Def.ActorFrame{}
t.InitCommand=function(self) self:x(WideScale(12, 30)) end

-- a row
t[#t+1] = Def.Quad {
	Name="RowBackgroundQuad",
	InitCommand=function(self) self:zoomto(row_width.active, row_height):horizalign(left) end,
	OnCommand=function(self) self:diffusealpha(1) end,
	GainFocusCommand=function(self) self:zoomtowidth(row_width.active)   end,
	LoseFocusCommand=function(self) self:zoomtowidth(row_width.inactive) end
}

return t