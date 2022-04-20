-- tables of rgba values
local light = {0.65,0.65,0.65,1}
local P1 = SCREEN_LEFT + 20
local P2 = SCREEN_RIGHT - 20
local nsj = GAMESTATE:GetNumSidesJoined()

local bmt_actor
local hours, mins, secs
local hmmss = "%d:%02d:%02d"

local filter

if GAMESTATE:IsCourseMode() then
	filter = IsUsingCourseFilters()
else
	filter = IsUsingFilters()
end

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

return Def.ActorFrame{
	InitCommand=function(self)
		if SL.Global.TimeAtSessionStart == nil then
			SL.Global.TimeAtSessionStart = GetTimeSinceStart()
		end
		self:SetUpdateFunction( UpdateTimer )
	end,
	
	Def.Quad{
		Name="Footer",
		InitCommand=function(self)
			self:zoomto(_screen.w, 32)
			self:vertalign(bottom)
			self:y(SCREEN_BOTTOM)
			self:x(SCREEN_CENTER_X)
			self:diffuse(light)
		end,
		ScreenChangedMessageCommand=function(self)
		end
	},
	
	LoadFont("Wendy/_wendy monospace numbers")..{
	Name="Session Timer",
	InitCommand=function(self)
		bmt_actor = self
		self:zoom( SL_WideScale(0.36, 0.36) )
		self:y( SL_WideScale(165, 165) / self:GetZoom() )
		self:diffusealpha(0):x(_screen.cx)
	end,
	OnCommand=function(self)
		self:sleep(0.1):decelerate(0.33):diffusealpha(1)
	end,
	},
	
	-- Text to warn the player that songs may be missing from the music wheel with their current filters. 
	-- Otherwise nothing here is necessary.
	LoadFont("Miso/_miso")..{
		Name="Filter_Warning",
		Text="",
		InitCommand=function(self)
			if filter then
				self:settext("Filters Active!")
			else
				self:settext("")
			end
			self:draworder(102)
			self:zoom(0.95)
			self:y(SCREEN_BOTTOM - 16)
			if nsj == 1 then
				if GAMESTATE:IsPlayerEnabled(0) == true then
					self:x(P1)
					self:horizalign(left)
				else
					self:x(P2)
					self:horizalign(right)
				end
			elseif nsj == 2 then
				self:x(P1)
				self:horizalign(left)
			end
			self:diffuse(color("#780000"))
			self:diffusealpha(0)
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	},
	
	-- Text to warn the player that songs may be missing from the music wheel with their current filters. 
	-- Otherwise nothing here is necessary.
	LoadFont("Miso/_miso")..{
		Name="Filter_Warning",
		Text="",
		InitCommand=function(self)
			if nsj == 2 then
				if filter then
					self:settext("Filters Active!")
				else
					self:settext("")
				end
				self:draworder(102)
				self:zoom(0.95)
				self:y(SCREEN_BOTTOM - 16)
				self:x(P2)
				self:horizalign(right)
				self:diffuse(color("#780000"))
				self:diffusealpha(0)
			else 
			end
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	},
	
}