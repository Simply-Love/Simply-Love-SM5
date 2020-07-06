local player = ...
local PlayerState  = GAMESTATE:GetPlayerState(player)
local SongPosition = GAMESTATE:GetPlayerState(player):GetSongPosition()
local rate = SL.Global.ActiveModifiers.MusicRate

-- reference to the BitmapText actor that will display elapsed time (current BitmapText)
local curBMT

-- reference to the function we'll use to format long-form seconds (like 208.64382946)
-- to something presentable (like 3:28)
-- initialize it to use SecondsToMSS (good for songs shorter than 10 minutes)
-- change it later if needed
local fmt = SecondsToMSS

-- simple flag used in the Update function to stop updating curBMT once the player runs out of life
local alive = true

-- -----------------------------------------------------------------------
-- prefer the engine's SecondsToHMMSS()
-- but define it ourselves if it isn't provided by this version of SM5
local hours, mins, secs
local hmmss = "%d:%02d:%02d"

local SecondsToHMMSS = SecondsToHMMSS or function(s)
	-- native floor division sounds nice but isn't available in Lua 5.1
	hours = math.floor(s/3600)
	mins  = math.floor((s % 3600) / 60)
	secs  = s - (hours * 3600) - (mins * 60)
	return hmmss:format(hours, mins, secs)
end

-- -----------------------------------------------------------------------
-- this Update function will be called every frame (I think)
-- it's potentially dangerous for framerate

local Update = function(af, delta)
	if not alive then return end

	-- SongPosition:GetMusicSeconds() can be negative for a bit at
	-- the beginnging depending on how the stepartist set the offset
	-- don't show negative time; just use 0
	if SongPosition:GetMusicSeconds() < 0 then
		curBMT:settext(fmt(0))
		return
	end

	curBMT:settext( fmt(SongPosition:GetMusicSeconds() / rate) )
end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}
af.InitCommand=function(self)
	self:SetUpdateFunction(Update)
	self:xy(-85,-50)
end

-- current time label
af[#af+1] = LoadFont("Common Normal")..{
	Text=("%s "):format( THEME:GetString("ScreenGameplay", "Current") ),
	InitCommand=function(self) self:horizalign(right):xy(-4, 0):zoom(0.833) end
}

-- current time number
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		curBMT = self
		self:horizalign(left):xy(0,0)
	end,

	-- HealthStateChanged is going to be broadcast quite a bit by the engine.
	-- Here, we're only really interested in detecting when the player has fully depleted
	-- their lifemeter and run out of life, but I don't see anything specifically being
	-- broadcast for that.  So, this.
	HealthStateChangedMessageCommand=function(self, params)
		-- color time red if the player reaches a HealthState of Dead
		if params.PlayerNumber == player and params.HealthState == "HealthState_Dead" then
			self:diffuse(color("#ff3030"))
			alive = false
		end
	end
}

-- total time number
af[#af+1] = LoadFont("Common Normal")..{
	Text=("%s "):format( THEME:GetString("ScreenGameplay", "Total") ),
	InitCommand=function(self) self:horizalign(right):xy(-4, 22):zoom(0.833) end
}

-- total time number
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:horizalign(left):xy(0,22)
	end,
	CurrentSongChangedMessageCommand=function(self)

		local totalseconds = GAMESTATE:GetCurrentSong():GetLastSecond() / rate

		if totalseconds < 600 then
			fmt = SecondsToMSS

		-- at least 10 minutes, shorter than 1 hour
		elseif totalseconds >= 360 and totalseconds < 3600 then
			fmt = SecondsToMMSS

		-- somewhere between 1 and 10 hours
		elseif totalseconds >= 3600 and totalseconds < 36000 then
			fmt = SecondsToHMMSS

		-- 10 hours or longer
		else
			fmt = SecondsToHHMMSS
		end

		self:settext( fmt(totalseconds) )
	end
}

return af