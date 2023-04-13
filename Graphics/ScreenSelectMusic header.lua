local bmt_actor

-- -----------------------------------------------------------------------

local hours, mins, secs
local hmmss = "%d:%02d:%02d"

-- prefer the engine's SecondsToHMMSS()
-- but define it ourselves if it isn't provided by this version of SM5
local SecondsToHMMSS = SecondsToHMMSS or function(s)
	-- native floor division sounds nice but isn't available in Lua 5.1
	hours = math.floor(s/3600)
	mins  = math.floor((s % 3600) / 60)
	secs  = s - (hours * 3600) - (mins * 60)
	return hmmss:format(hours, mins, secs)
end

local UpdateTimer = function(af, dt)
	local seconds = GetTimeSinceStart() - SL.Global.TimeAtSessionStart

	-- if this game session is less than 1 hour in duration so far
	if seconds < 3600 then
		bmt_actor:settext( SecondsToMMSS(seconds) )

	-- somewhere between 1 and 10 hours
	elseif seconds >= 3600 and seconds < 36000 then
		bmt_actor:settext( SecondsToHMMSS(seconds) )

	-- in it for the long haul
	else
		bmt_actor:settext( SecondsToHHMMSS(seconds) )
	end
end

-- -----------------------------------------------------------------------

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

		self:SetUpdateFunction( UpdateTimer )
	end
end


-- generic header elements (background Def.Quad, left-aligned screen name)
af[#af+1] = LoadActor( THEME:GetPathG("", "_header.lua") )

-- centered text
-- session timer in EventMode
if PREFSMAN:GetPreference("EventMode") then

	af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " numbers")..{
		Name="Session Timer",
		InitCommand=function(self)
			bmt_actor = self
			self:zoom( SL_WideScale(0.3, 0.36) )
			self:y( SL_WideScale(3.15, 3.5) / self:GetZoom() )
			self:diffusealpha(0):x(_screen.cx)
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	}

-- stage number when not EventMode
else

	af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Header")..{
		Name="Stage Number",
		Text=SSM_Header_StageText(),
		InitCommand=function(self)
			self:zoom( SL_WideScale(0.5, 0.6) )
			self:y( SL_WideScale(7.5, 9) / self:GetZoom() )
			self:diffusealpha(0):x(_screen.cx)
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	}

end

-- "ITG" or "FA+"; aligned to right of screen
af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Header")..{
	Name="GameModeText",
	Text=THEME:GetString("ScreenSelectPlayMode", SL.Global.GameMode),
	InitCommand=function(self)
		self:diffusealpha(0):halign(1):y(15)
		self:zoom( SL_WideScale(0.5, 0.6) )

		-- move the GameMode text further left if MenuTimer is enabled
		if PREFSMAN:GetPreference("MenuTimer") then
			self:x(_screen.w - SL_WideScale(110, 125))
		else
			self:x(_screen.w - SL_WideScale(55, 62))
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
af[#af+1] = LoadActor( THEME:GetPathB("ScreenSelectStyle", "underlay/pad.lua"), {nil, nil, 1, nil} )..{
	InitCommand=function(self)
		self:x(_screen.w - (PREFSMAN:GetPreference("MenuTimer") and SL_WideScale(90, 105) or SL_WideScale(35, 41)))
		self:y( SL_WideScale(22, 23.5) ):zoom(0.24)
		self:playcommand("Set", {Player=PLAYER_1})
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_1 then
			self:playcommand("Set", {Player=PLAYER_1})
		end
	end
}

-- P2 pad
af[#af+1] = LoadActor( THEME:GetPathB("ScreenSelectStyle", "underlay/pad.lua"), {nil, nil, 2, nil} )..{
	InitCommand=function(self)
		self:x(_screen.w - (PREFSMAN:GetPreference("MenuTimer") and SL_WideScale(70, 81) or SL_WideScale(15, 17)))
		self:y( SL_WideScale(22, 23.5) ):zoom(0.24)
		self:playcommand("Set", {Player=PLAYER_2})
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == PLAYER_2 then
			self:playcommand("Set", {Player=PLAYER_2})
		end
	end
}

return af