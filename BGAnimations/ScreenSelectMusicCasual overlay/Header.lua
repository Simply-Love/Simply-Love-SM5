local text = ScreenString("HeaderText")
local row = ...

local af = Def.ActorFrame{

	Def.Quad{
		InitCommand=function(self)
			-- if ThemePrefs.Get("RainbowMode") then
				self:diffuse(color("#000000dd"))
			-- else
			-- 	self:diffuse(0.86, 0.86, 0.86, 0.75)
			-- end
			self:zoomto(_screen.w, row.h*0.5):valign(0):xy( _screen.cx, 0 )
		end,
		SwitchFocusToSongsMessageCommand=function(self)
				self:sleep(0.1):linear(0.1):zoomtoheight(row.h*0.5)
		end,
		SwitchFocusToGroupsMessageCommand=cmd(linear,0.1; zoomtoheight, 32),
	},

	-- "Choose Your Song"
	Def.BitmapText{
		Name="HeaderText",
		Font="_wendy small",
		Text=text,
		InitCommand=function(self)
			self:diffuse(1,1,1,0):zoom(WideScale(0.5,0.6)):horizalign(left):xy(10, 15)
		end,
		OffCommand=cmd(accelerate,0.33; diffusealpha,0),
		SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
		SwitchFocusToGroupsMessageCommand=function(self) self:sleep(0.25):linear(0.1):diffusealpha(1) end,
	},
}

-- Stage Number
if not PREFSMAN:GetPreference("EventMode") then
	af[#af+1] = Def.BitmapText{
		Font=PREFSMAN:GetPreference("EventMode") and "_wendy monospace numbers" or "_wendy small",
		Name="Stage Number",
		Text=SSM_Header_StageText(),
		InitCommand=function(self)
			self:diffusealpha(0):zoom( WideScale(0.5,0.6) ):xy(_screen.cx, 15)
		end,
		SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
		SwitchFocusToGroupsMessageCommand=function(self) self:sleep(0.25):linear(0.1):diffusealpha(1) end
	}
end

return af