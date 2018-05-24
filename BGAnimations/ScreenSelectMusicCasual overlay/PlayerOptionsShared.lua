local args = ...
local row = args[1]
local col = args[2]

return Def.ActorFrame{
	OnCommand=cmd(diffusealpha, 0),
	SwitchFocusToSongsMessageCommand=cmd(linear,0.1; diffusealpha,0),
	SwitchFocusToGroupsMessageCommand=cmd(linear,0.1; diffusealpha,0),
	SwitchFocusToSingleSongMessageCommand=cmd(sleep,0.3; linear,0.1; diffusealpha,1),

	Def.Quad{
		Name="SongInfo",
		InitCommand=cmd(diffuse, color("#dddddd"); diffusealpha,0.75; zoomto, _screen.w/WideScale(1.15,1.5), row.h),
		OnCommand=cmd(xy, _screen.cx, _screen.cy - row.h/1.6 ),
	},

	Def.Quad{
		Name="PlayerOptionsBG",
		InitCommand=cmd(diffuse, color("#dddddd"); diffusealpha,0.75; zoomto, _screen.w/WideScale(1.15,1.5), row.h*1.5),
		OnCommand=cmd(xy, _screen.cx, _screen.cy + row.h/1.5 ),
	},

	Def.Quad{
		Name="PlayerOptionsDivider",
		InitCommand=cmd(diffuse, Color.Black; diffusealpha,0.75; zoomto, 2, row.h*1.25),
		OnCommand=cmd(xy, _screen.cx, _screen.cy + row.h/1.5 ),
	}
}