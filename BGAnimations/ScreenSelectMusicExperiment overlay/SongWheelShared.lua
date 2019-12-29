local args = ...
local row = args[1]
local col = args[2]
local y_offset = args[3]

local af = Def.ActorFrame{
	Name="SongWheelShared",
	InitCommand=function(self) self:y(y_offset) end
}

-----------------------------------------------------------------
-- black background quad
af[#af+1] = Def.Quad{
	Name="SongWheelBackground",
	InitCommand=function(self) self:zoomto(_screen.w, _screen.h/2.25 - 3):diffuse(0,0,0,1):cropbottom(1) end,
	OnCommand=function(self)
		self:xy(_screen.cx, math.ceil((row.how_many-2)/2) * row.h + 36):finishtweening()
		    :accelerate(0.2):cropbottom(0)
			:diffusealpha(.75)
	end,
	SwitchFocusToGroupsMessageCommand=function(self) self:smooth(0.3):cropright(1) end,
	SwitchFocusToSongsMessageCommand=function(self) 	self:smooth(.3):cropright(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:smooth(0.3):cropright(1) end
}

-- rainbow glowing border top
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w, 1):diffuse(1,1,1,0):xy(_screen.cx, _screen.cy+30 + _screen.h/(row.how_many-2)*-0.5):faderight(10):rainbow() end,
	OnCommand=function(self) self:sleep(0.3):diffusealpha(0.75):queuecommand("FadeMe") end,
	FadeMeCommand=function(self) self:accelerate(1.5):faderight(0):accelerate(1.5):fadeleft(10):sleep(0):diffusealpha(0):fadeleft(0):sleep(1.5):faderight(10):diffusealpha(0.75):queuecommand("FadeMe") end,
	SwitchFocusToGroupsMessageCommand=function(self) self:visible(false) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:visible(false) end,
	SwitchFocusToSongsMessageCommand==function(self) self:visible(true) end
}

-- rainbow glowing border bottom
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w, 1):diffuse(1,1,1,0):xy(_screen.cx, _screen.cy+30 + _screen.h/(row.how_many-2) * 0.5):faderight(10):rainbow() end,
	OnCommand=function(self) self:sleep(0.3):diffusealpha(0.75):queuecommand("FadeMe") end,
	FadeMeCommand=function(self) self:accelerate(1.5):faderight(0):accelerate(1.5):fadeleft(10):sleep(0):diffusealpha(0):fadeleft(0):sleep(1.5):faderight(10):diffusealpha(0.75):queuecommand("FadeMe") end,
	SwitchFocusToGroupsMessageCommand=function(self) self:visible(false) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:visible(false) end,
	SwitchFocusToSongsMessageCommand==function(self) self:visible(true) end
}

return af