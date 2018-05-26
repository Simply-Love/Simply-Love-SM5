local text = ScreenString("HeaderText")
local row = ...

local af = Def.ActorFrame{
	InitCommand=function(self) self:queuecommand("Hide"):visible(false) end,
	SwitchFocusToSongsMessageCommand=function(self) self:queuecommand("Hide"):visible(false) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:queuecommand("Show"):visible(true) end,

	Def.Quad{
		Name="SongWheelTopBorder",
		InitCommand=function(self)
			if ThemePrefs.Get("RainbowMode") then
				self:diffuse(color("#000000dd"))
			else
				self:diffuse(0.86, 0.86, 0.86, 0.75)
			end

			self:zoomto(_screen.w, 32):valign(0)
		end,
		OnCommand=function(self) self:xy( _screen.cx, 0 ) end,
		HideCommand=cmd(zoomtoheight, 0),
		ShowCommand=cmd(sleep,0.2; zoomtoheight, 32),
	},

	-- "Choose Your Song"
	Def.BitmapText{
		Name="HeaderText",
		Font="_wendy small",
		InitCommand=function(self)
			self:diffusealpha(0):zoom(WideScale(0.5,0.6)):horizalign(left):xy(10, 15)
			if not ThemePrefs.Get("RainbowMode") then self:diffuse(0,0,0,0.9) end
		end,
		OnCommand=cmd(sleep, 0.1; decelerate,0.33; diffusealpha,0.9),
		OffCommand=cmd(accelerate,0.33; diffusealpha,0),
		HideCommand=function(self) self:settext(""):diffusealpha(0) end,
		ShowCommand=function(self) self:settext(text):sleep(0.2):linear(0.2):diffusealpha(0.9) end,
	},
}

-- Stage Number
if not PREFSMAN:GetPreference("EventMode") then
	Def.BitmapText{
		Font=PREFSMAN:GetPreference("EventMode") and "_wendy monospace numbers" or "_wendy small",
		Name="Stage Number",
		InitCommand=function(self)
			self:diffusealpha(0):zoom( WideScale(0.5,0.6) ):xy(_screen.cx, 15)
		end,
		OnCommand=function(self)
			self:settext( SSM_Header_StageText() )
				:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	}
end

return af