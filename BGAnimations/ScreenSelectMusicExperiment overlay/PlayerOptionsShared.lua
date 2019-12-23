local args = ...
local row = args[1]
local col = args[2]
local Input = args[3]

local bg_color = {0,0,0,0.9}
local divider_color = {1,1,1,0.75}

local af = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,

	Def.Quad{
		Name="SongInfoBG",
		InitCommand=function(self) self:diffuse(bg_color):zoomto(_screen.w/WideScale(1.15,1.5), row.h) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy - row.h/1.6 ) end,
	},

	Def.Quad{
		Name="PlayerOptionsBG",
		InitCommand=function(self) self:diffuse(bg_color):zoomto(_screen.w/WideScale(1.15,1.5), row.h*1.5) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy + row.h/1.5 ) end,
	},

	Def.Quad{
		Name="PlayerOptionsDivider",
		InitCommand=function(self) self:diffuse(divider_color):zoomto(2, row.h*1.25) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy + row.h/1.5 ) end,
	},
}

return af