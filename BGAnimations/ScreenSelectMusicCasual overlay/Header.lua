local text = ScreenString("HeaderText")
local row = ...

return Def.ActorFrame{
	Def.Quad{
		Name="SongWheelTopBorder",
		InitCommand=cmd(diffuse, color("#999999"); zoomto,_screen.w, 32; valign, 0),
		OnCommand=function(self) self:xy( _screen.cx, 0 ) end,
		SwitchFocusToSongsMessageCommand=cmd(sleep,0.3; linear,0.1; zoomtoheight, row.h*0.5),
		SwitchFocusToGroupsMessageCommand=cmd(sleep,0.3; linear,0.1; zoomtoheight, 32),
	},

	-- "Choose Your Song"
	Def.BitmapText{
		Name="HeaderText",
		Font="_wendy small",
		Text=text,
		InitCommand=cmd(diffusealpha,0; zoom,WideScale(0.5,0.6); horizalign, left; xy, 10, 15 ),
		OnCommand=cmd(sleep, 0.1; decelerate,0.33; diffusealpha,1),
		OffCommand=cmd(accelerate,0.33; diffusealpha,0),
		SwitchFocusToSongsMessageCommand=cmd(settext, ""),
		SwitchFocusToGroupsMessageCommand=cmd(settext, text),
	},

	Def.BitmapText{
		Font=PREFSMAN:GetPreference("EventMode") and "_wendy monospace numbers" or "_wendy small",
		Name="Stage Number",
		InitCommand=function(self)
			if PREFSMAN:GetPreference("EventMode") then
				self:diffusealpha(0):zoom( WideScale(0.305,0.365) ):xy(_screen.cx, WideScale(10,9))
			else
				self:diffusealpha(0):zoom( WideScale(0.5,0.6) ):xy(_screen.cx, 15)
			end
		end,
		OnCommand=function(self)
			if not PREFSMAN:GetPreference("EventMode") then
				self:settext( SSM_Header_StageText() )
					:sleep(0.1):decelerate(0.33):diffusealpha(1)
			else
				self:visible(false)
			end
		end,
	},
}