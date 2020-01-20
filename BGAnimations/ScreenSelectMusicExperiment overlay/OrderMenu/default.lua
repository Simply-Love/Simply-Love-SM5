local scrollers = {}
scrollers[PLAYER_1] = setmetatable({disable_wrapping=true}, sick_wheel_mt)
scrollers[PLAYER_2] = setmetatable({disable_wrapping=true}, sick_wheel_mt)

local mpn = GAMESTATE:GetMasterPlayerNumber()
-- ----------------------------------------------------
local invalid_count = 0
local t = Def.ActorFrame {
	-- FIXME: stall for 0.5 seconds so that the Lua InputCallback doesn't get immediately added to the screen.
	-- It's otherwise possible to enter the screen with MenuLeft/MenuRight already held and firing off events,
	-- which causes the sick_wheel of profile names to not display.  I don't have time to debug it right now.
	InitCommand=function(self)
		self:visible(false)
		orderMenu_input = LoadActor("./Input.lua", {af=self, Scrollers=scrollers})
	end,
	DirectInputToOrderMenuCommand=function(self) self:playcommand("ShowOrderMenu"):queuecommand("Stall") end,
	StallCommand=function(self) 
		self:visible(true):sleep(0.25):queuecommand("CaptureTest")
	end,
	CaptureTestCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( orderMenu_input ) end,

	-- the OffCommand will have been queued, when it is appropriate, from ./Input.lua
	-- sleep for 0.5 seconds to give the PlayerFrames time to tween out
	-- and queue a call to Finish() so that the engine can wrap things up
	OffCommand=function(self)
		self:sleep(0.5):queuecommand("Finish")
	end,
	FinishTextMessageCommand=function(self)
		self:sleep(0.5):queuecommand("Finish")
	end,
	FinishCommand=function(self)
		self:visible(false)
		local screen   = SCREENMAN:GetTopScreen()
		local overlay  = screen:GetChild("Overlay")
		screen:RemoveInputCallback( orderMenu_input)
		overlay:queuecommand("DirectInputToEngine")
	end,
	WhatMessageCommand=function(self) self:runcommandsonleaves(function(subself) if subself.distort then subself:distort(0.5) end end):sleep(4):queuecommand("Undistort") end,
	UndistortCommand=function(self) self:runcommandsonleaves(function(subself) if subself.distort then subself:distort(0) end end) end,
	-- sounds
	LoadActor( THEME:GetPathS("Common", "start") )..{
		StartButtonMessageCommand=function(self) self:play() end
	},
	LoadActor( THEME:GetPathS("ScreenSelectMusic", "select down") )..{
		BackButtonMessageCommand=function(self) self:play() end
	},
	LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{
		DirectionButtonMessageCommand=function(self)
			self:play()
			if invalid_count then invalid_count = 0 end
		end
	},
	LoadActor( THEME:GetPathS("Common", "invalid") )..{
		InvalidChoiceMessageCommand=function(self)
			self:play()
			if invalid_count then
				invalid_count = invalid_count + 1
				if invalid_count >= 10 then MESSAGEMAN:Broadcast("What"); invalid_count = nil end
			end
		end
	},
	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=function(self) self:FullScreen():diffuse(Color.Black):diffusealpha(0.8) end
	},
}

-- top mask
t[#t+1] = Def.Quad{
	InitCommand=function(self) self:horizalign(left):vertalign(bottom):setsize(540,50):xy(_screen.cx-self:GetWidth()/2, _screen.cy-110):MaskSource() end
}
-- bottom mask
t[#t+1] = Def.Quad{
	InitCommand=function(self) self:horizalign(left):vertalign(top):setsize(540,120):xy(_screen.cx-self:GetWidth()/2, _screen.cy+111):MaskSource() end
}

-- Both players will use the same menu so just load for master player number.
t[#t+1] = LoadActor("PlayerFrame.lua", {Player=mpn, Scroller=scrollers[mpn]})

return t