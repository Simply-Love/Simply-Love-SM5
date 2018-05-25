local row = ...

return Def.Quad{
	Name="SongWheelTopBorder",
	InitCommand=function(self) self:diffuse(color("#999999")):zoomto(_screen.w, row.h*0.5):valign(0):xy( _screen.cx, 0 ) end,
	SwitchFocusToSongsMessageCommand=function(self)
		-- we only want this animation to trigger when switch from GroupWheel to SongWheel
		-- not from IndividualSong back to SongWheel
		if self:GetZoomY() == 0 then
			self:zoomtoheight(32):sleep(0.1):linear(0.1):zoomtoheight(row.h*0.5)
		end
	end,
	SwitchFocusToGroupsMessageCommand=cmd(linear,0.1; zoomtoheight, 32; sleep,0.2; zoomtoheight, 0),
}