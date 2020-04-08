local bmt_actor
local DrawNinePanelPad = LoadActor( THEME:GetPathB("ScreenSelectStyle", "underlay/pad.lua") )

local Update = function(af, dt)
	local seconds = GetTimeSinceStart() - SL.Global.TimeAtSessionStart

	-- if this game session is less than 1 hour in duration so far
	if seconds < 3600 then
		bmt_actor:settext( SecondsToMMSS(seconds) )
	else
		bmt_actor:settext( SecondsToHHMMSS(seconds) )
	end
end

local af = Def.ActorFrame{ OffCommand=function(self) self:linear(0.1):diffusealpha(0) end }

-- only add this InitCommand to the main ActorFrame in EventMode
if PREFSMAN:GetPreference("EventMode") then
	af.InitCommand=function(self)
		-- TimeAtSessionStart will be reset to nil between game sessions
		-- thus, if it's currently nil, we're loading ScreenSelectMusic
		-- for the first time this particular game session
		if SL.Global.TimeAtSessionStart == nil then
			SL.Global.TimeAtSessionStart = GetTimeSinceStart()
		end

		self:SetUpdateFunction( Update )
	end
end


-- generic header elements (background Def.Quad, left-aligned screen name)
af[#af+1] = LoadActor( THEME:GetPathG("", "_header.lua") )

-- centered text
-- session timer in EventMode
if PREFSMAN:GetPreference("EventMode") then

	af[#af+1] = LoadFont("_wendy monospace numbers")..{
		Name="Session Timer",
		InitCommand=function(self)
			bmt_actor = self
			self:zoom( clamp(WideScale(0.3,0.36), 0.3, 0.36) )
			self:y( clamp(WideScale(3.15,3.5), 3.15, 3.5) / self:GetZoom() )
			self:diffusealpha(0):x(_screen.cx)
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	}

-- stage number when not EventMode
else

	af[#af+1] = LoadFont("_wendy small")..{
		Name="Stage Number",
		Text=SSM_Header_StageText(),
		InitCommand=function(self)
			self:zoom( clamp(WideScale(0.5,0.6), 0.5, 0.6) )
			self:y( clamp(WideScale(7.5,9), 7.5, 9) / self:GetZoom() )
			self:diffusealpha(0):x(_screen.cx)
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	}

end

-- "ITG" or "FA+"; aligned to right of screen
af[#af+1] = LoadFont("_wendy small")..{
	Name="GameModeText",
	Text=THEME:GetString("ScreenSelectPlayMode", SL.Global.GameMode),
	InitCommand=function(self)
		self:diffusealpha(0):halign(1):y(15)
		self:zoom( clamp(WideScale(0.5,0.6), 0.5, 0.6) )

		-- move the GameMode text further left if MenuTimer is enabled
		if PREFSMAN:GetPreference("MenuTimer") then
			self:x(_screen.w - clamp(WideScale(110, 125), 110, 125))
		else
			self:x(_screen.w - clamp(WideScale(55,62), 55, 62))
		end
	end,
	OnCommand=function(self)
		self:sleep(0.1):decelerate(0.33):diffusealpha(1)
	end,
	SLGameModeChangedMessageCommand=function(self)
		self:settext(THEME:GetString("ScreenSelectPlayMode", SL.Global.GameMode))
	end
}

-- P1 pad
af[#af+1] = DrawNinePanelPad()..{
	InitCommand=function(self)
		self:x(_screen.w - (PREFSMAN:GetPreference("MenuTimer") and clamp(WideScale(90,105), 90, 105) or clamp(WideScale(35, 41), 35, 41)))
		self:y( clamp(WideScale(22,23.5), 22, 23.5) ):zoom(0.24)
		self:playcommand("Set", {Player=PLAYER_1})
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_1 then
			self:playcommand("Set", {Player=PLAYER_1})
		end
	end
}

-- P2 pad
af[#af+1] = DrawNinePanelPad()..{
	InitCommand=function(self)
		self:x(_screen.w - (PREFSMAN:GetPreference("MenuTimer") and clamp(WideScale(70,81), 70, 81) or clamp(WideScale(15, 17), 15, 17)))
		self:y( clamp(WideScale(22,23.5), 22, 23.5) ):zoom(0.24)
		self:playcommand("Set", {Player=PLAYER_2})
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_2 then
			self:playcommand("Set", {Player=PLAYER_2})
		end
	end
}

return af