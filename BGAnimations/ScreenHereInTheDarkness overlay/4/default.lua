-- "I long for the day on which I can hear your voice again."

-- init mouse starting coordinates
local mouse_pos = {
	x = INPUTFILTER:GetMouseX(),
	y = INPUTFILTER:GetMouseY()
}
local mouse_has_moved = false

local Update = function(af, delta)
	if not mouse_has_moved then
		if INPUTFILTER:GetMouseX() ~= mouse_pos.x or INPUTFILTER:GetMouseY() ~= mouse_pos.y then
			mouse_has_moved = true
		end
	end

	-- the mask starts centered; only move it if the mouse coordinates have changed since init
	if mouse_has_moved then
		mask:x( clamp(INPUTFILTER:GetMouseX(), _screen.cx-175, _screen.cx+175) )
		mask:y( clamp(INPUTFILTER:GetMouseY(), _screen.cy-150, _screen.cy+150) )
	end
	-- note that INPUTFILTER:GetMouseX() and INPUTFILTER:GetMouseY() are not implemented in
	-- macOS at this time; both methods always just return 0 in SM5.0.12 and SM5.1
end


local af = Def.ActorFrame{}
af.InitCommand=function(self) self:SetUpdateFunction(Update) end
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
		self:smooth(1):diffuse(0,0,0,1):queuecommand("NextScreen")
	end
end
af.NextScreenCommand=function(self)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end


af[#af+1] = LoadActor("./recalling.ogg")..{
	OnCommand=function(self) self:play() end
}

af[#af+1] = LoadActor("./recalling (doubleres).png")..{
	InitCommand=function(self) self:zoom(0.5):Center() end
}

af[#af+1] = LoadActor("./mask.png")..{
	InitCommand=function(self) self:zoom(0.5):Center():diffuse(0,0,0,1); mask = self end,
	OnCommand=function(self) self:pulse():effectmagnitude(14,1,1):effectperiod(6) end
}

-- cover
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():Center():diffuse(0,0,0,1) end,
	OnCommand=function(self) self:sleep(2.5):smooth(3):diffuse(0,0,0,0) end
}

-- cursor
af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:align(0,0):zoomto(2,20):xy(_screen.cx-98,_screen.cy-30)
		self:diffuseblink():effectperiod(1):effectcolor1(0,0,0,1):effectcolor2(1,1,1,1)
	end
}


return af