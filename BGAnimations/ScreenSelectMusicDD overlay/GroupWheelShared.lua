-----------------------------------------------------------------
-- The code in this file works, but is currently not used.
-- To try it out, uncomment the group_info key near the bottom of Setup.lua

local args = ...
local row = args[1]
local col = args[1]
local group_info = args[3]
CurrentGroupIsInvalid = false

if group_info == nil then
	return Def.Actor{ InitCommand=function(self) self:visible(false) end }
end
-----------------------------------------------------------------

local af = Def.ActorFrame{ Name="GroupWheelShared" }

-----------------------------------------------------------------
-- text

af[#af+1] = Def.ActorFrame{
	Name="CurrentGroupInfoAF",
	InitCommand=function(self) self:xy( _screen.cx, _screen.cy+60 ):visible(false) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:visible(true):sleep(0.4):linear(0.15):diffusealpha(1) end,
	SwitchFocusToSongsMessageCommand=function(self) self:visible(false):diffusealpha(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:visible(false):diffusealpha(0) end,
	-- unique songs
	Def.BitmapText{
		Font="Common Normal",
		InitCommand=function(self)
			self:zoom(0.8):diffuse(Color.White):xy(IsUsingWideScreen() and 150 or 310,IsUsingWideScreen() and -15 or -113):maxwidth(300):horizalign(right)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if params.group and group_info[params.group] then
				self:settext(group_info[params.group].num_songs)
			else
				self:settext("")
			end
		end,
	},

}

return af