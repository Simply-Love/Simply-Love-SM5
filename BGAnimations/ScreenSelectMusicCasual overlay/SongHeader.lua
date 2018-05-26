local row = ...

return Def.Quad{
	Name="SongWheelTopBorder",
	InitCommand=function(self)
		if ThemePrefs.Get("RainbowMode") then
			self:diffuse(color("#000000dd"))
		else
			self:diffuse(0.86, 0.86, 0.86, 0.75)
		end
		self:zoomto(_screen.w, row.h*0.5):valign(0):xy( _screen.cx, 0 )
	end,
	SwitchFocusToSongsMessageCommand=function(self)
		-- we only want this animation to trigger when switch from GroupWheel to SongWheel
		-- not from IndividualSong back to SongWheel
		if self:GetZoomY() == 0 then
			self:zoomtoheight(32):sleep(0.1):linear(0.1):zoomtoheight(row.h*0.5)
		end
	end,
	SwitchFocusToGroupsMessageCommand=cmd(linear,0.1; zoomtoheight, 32; sleep,0.2; zoomtoheight, 0),
}