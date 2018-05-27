local args = ...
local row = args[1]
local col = args[2]

local bg_c = ThemePrefs.Get("RainbowMode") and {0,0,0,0.9} or {0.86, 0.86, 0.86, 0.75}
local divider_c = ThemePrefs.Get("RainbowMode") and {1,1,1,0.75} or {0,0,0,0.75}

return Def.ActorFrame{
	InitCommand=cmd(diffusealpha, 0),
	SwitchFocusToSongsMessageCommand=cmd(linear,0.1; diffusealpha,0),
	SwitchFocusToGroupsMessageCommand=cmd(linear,0.1; diffusealpha,0),
	SwitchFocusToSingleSongMessageCommand=cmd(sleep,0.3; linear,0.1; diffusealpha,1),

	Def.Quad{
		Name="SongInfo",
		InitCommand=cmd(diffuse, bg_c; zoomto, _screen.w/WideScale(1.15,1.5), row.h),
		OnCommand=cmd(xy, _screen.cx, _screen.cy - row.h/1.6 ),
	},

	Def.Quad{
		Name="PlayerOptionsBG",
		InitCommand=cmd(diffuse, bg_c; zoomto, _screen.w/WideScale(1.15,1.5), row.h*1.5),
		OnCommand=cmd(xy, _screen.cx, _screen.cy + row.h/1.5 ),
	},

	Def.Quad{
		Name="PlayerOptionsDivider",
		InitCommand=cmd(diffuse, divider_c; zoomto, 2, row.h*1.25),
		OnCommand=cmd(xy, _screen.cx, _screen.cy + row.h/1.5 ),
	},

	LoadActor("./StartButton.lua")
}