local row = ...

return Def.Quad{
	Name="SongWheelTopBorder",
	InitCommand=function(self) self:diffuse(color("#999999")):zoomto(_screen.w, 0):valign(0):xy( _screen.cx, 0 ) end,
	SwitchFocusToSongsMessageCommand=cmd(sleep,0.3; linear,0.1; zoomtoheight, row.h*0.5),
	SwitchFocusToGroupsMessageCommand=cmd(sleep,0.3; linear,0.1; zoomtoheight, 0),
}