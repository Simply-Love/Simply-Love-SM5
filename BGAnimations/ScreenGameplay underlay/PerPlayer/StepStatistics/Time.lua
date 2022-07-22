local player = ...
local PlayerState  = GAMESTATE:GetPlayerState(player)
local SongPosition = GAMESTATE:GetPlayerState(player):GetSongPosition()
local rate = SL.Global.ActiveModifiers.MusicRate

local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)
local IsUltraWide = (GetScreenAspectRatio() > 21/9)

-- -----------------------------------------------------------------------
-- reference to the BitmapText actor that will display remaining time
local remBMT
-- how wide (in visual pixels) the total time is, used to offset the label
local total_width

-- simple flag used in the Update function to stop updating remBMT once the player runs out of life
local alive = true

-- -----------------------------------------------------------------------
-- reference to the function we'll use to format long-form seconds (like 208.64382946)
-- to something presentable (like 3:28)
local fmt = nil

-- how long this song or course is, in seconds
-- we'll use this to choose a formatting function
local totalseconds = totalLengthSongOrCourse(player)

-- choose the appropriate time-to-string formatting function

-- shorter than 10 minutes (M:SS)
if totalseconds < 600 then
	fmt = SecondsToMSS

-- at least 10 minutes, shorter than 1 hour (MM:SS)
elseif totalseconds >= 360 and totalseconds < 3600 then
	fmt = SecondsToMMSS

-- somewhere between 1 and 10 hours (H:MM:SS)
elseif totalseconds >= 3600 and totalseconds < 36000 then
	fmt = SecondsToHMMSS

-- 10 hours or longer (HH:MM:SS)
else
	fmt = SecondsToHHMMSS
end

-- -----------------------------------------------------------------------
-- In CourseMode, we want to show how far into the overall Course the player is,
-- but SongPosition:GetMusicSeconds() only gives us the current second into the current
-- song.  We'll need to track how long each song is, and add (cumulatively-increasing)
-- seconds to SongPosition:GetMusicSeconds() for each song past the first.
--
-- Here, set up a table with cumulative seconds-per-Song for the overall Course.
local cumulative_seconds = {}
if GAMESTATE:IsCourseMode() then
	cumulative_seconds = courseLengthBySong(player)
end

-- use seconds_offset in CourseMode to initialize timer text
-- for songs after the first
-- (i.e. by the start of the 4th song, 6 minutes have already elapsed)
--
-- seconds_offset is scoped to this entire file and updated in
-- CurrentSongChangedMessageCommand so it can be referenced
-- from within Update()
local seconds_offset = 0

-- -----------------------------------------------------------------------
-- this Update function will be called every frame (I think)
-- it's potentially dangerous for framerate

local Update = function(af, delta)
	if not alive then return end

	-- SongPosition:GetMusicSeconds() can be negative for a bit at
	-- the beginnging depending on how the stepartist set the offset
	-- don't show negative time; just use 0
	if SongPosition:GetMusicSeconds() < 0 then
		remBMT:settext(fmt(totalseconds - seconds_offset))
		return
	end

	remBMT:settext( fmt(clamp(totalseconds - seconds_offset - (SongPosition:GetMusicSeconds()/rate), 0, totalseconds)) )
end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}
af.InitCommand=function(self)
	self:SetUpdateFunction(Update)
	self:x(SL_WideScale(150,202) * (player==PLAYER_1 and -1 or 1))
	self:y(-40)

	if NoteFieldIsCentered and IsUsingWideScreen() then
		self:x( 154 * (player==PLAYER_1 and -1 or 1) )
	end

	-- flip alignment when ultrawide and both players joined
	if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
		self:x(self:GetX() * -1)
	end
end

af.CurrentSongChangedMessageCommand=function(self,params)
	-- GAMESTATE:GetCourseSongIndex() is 0-indexed, which we'll use to our advantage here
	-- since CurrentSongChanged is broadcast by the engine at the start of every song in
	-- a course, including the first.
	--
	-- So, when ScreenGameplay appears for the first song in the course, GAMESTATE:GetCourseSongIndex()
	-- will be 0, which won't index to anything in cumulative_seconds, which is what we want.
	--
	-- When the 2nd song appears, GAMESTATE:GetCourseSongIndex() will be 1, meaning we'll index
	-- cumulative_seconds[1] to get the first song's duration.
	--
	-- When the 3rd song appears, we'll index cumulative_seconds[2] to get (1st song + 2nd song)
	-- duration.  Etc.
	local course_index = GAMESTATE:GetCourseSongIndex()
	seconds_offset = cumulative_seconds[course_index] or 0
end

-- -----------------------------------------------------------------------
-- remaining time number
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		remBMT = self
		self:x(0)
		self:halign(PlayerNumber:Reverse()[player]):vertalign(bottom)

		-- flip alignment and adjust for smaller pane size
		-- when ultrawide and both players joined
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			self:halign( PlayerNumber:Reverse()[OtherPlayer[player]] )
			self:x(50 * (player==PLAYER_1 and -1 or 1))
		end
	end,

	-- HealthStateChanged is going to be broadcast quite a bit by the engine.
	-- Here, we're only really interested in detecting when the player has fully depleted
	-- their lifemeter and run out of life, but I don't see anything specifically being
	-- broadcast for that.  So, this.
	HealthStateChangedMessageCommand=function(self, params)
		-- color the BitmapText actor red if the player reaches a HealthState of Dead
		if params.PlayerNumber == player and params.HealthState == "HealthState_Dead" then
			self:diffuse(color("#ff3030"))
			alive = false
		end
	end
}

-- remaining time label
af[#af+1] = LoadFont("Common Normal")..{
	Text=("%s "):format( THEME:GetString("ScreenGameplay", "Remaining") ),
	InitCommand=function(self)
		self:halign(PlayerNumber:Reverse()[player]):vertalign(bottom)
		self:zoom(0.833)

		-- flip alignment and adjust for smaller pane size
		-- when ultrawide and both players joined
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			self:halign( PlayerNumber:Reverse()[OtherPlayer[player]] )
			self:x(50 * (player==PLAYER_1 and -1 or 1))
		end
	end,
	OnCommand=function(self)
		if player==PLAYER_1 then
			self:x( 32 + (total_width-28))
		else
			self:x(-32 - (total_width-28))
		end

		-- flip offset when ultrawide and both players
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			if player==PLAYER_1 then
				self:x(-86 - (total_width-28))
			else
				self:x( 86 + (total_width-28))
			end
		end
	end
}

-- -----------------------------------------------------------------------
-- total time number
-- song duration in normal gameplay, overall course duration in CourseMode
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:xy(0,20)
		self:halign(PlayerNumber:Reverse()[player]):vertalign(bottom)
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			self:halign( PlayerNumber:Reverse()[OtherPlayer[player]] )
			self:x(50 * (player==PLAYER_1 and -1 or 1))
		end

		self:settext( fmt(totalseconds) )
		total_width = self:GetWidth()
	end
}

-- total time label
-- "song" in normal gameplay, "course" in CourseMode
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:zoom(0.833)
		self:halign(PlayerNumber:Reverse()[player]):vertalign(bottom)
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			self:halign( PlayerNumber:Reverse()[OtherPlayer[player]] )
		end

		local s = GAMESTATE:IsCourseMode() and THEME:GetString("ScreenGameplay", "Course") or THEME:GetString("ScreenGameplay", "Song")
		self:settext( ("%s "):format(s) )
	end,
	OnCommand=function(self)
		if player==PLAYER_1 then
			self:x(32 + (total_width-28))
		else
			self:x(-32 - (total_width-28))
		end
		self:y(20)

		-- flip offset when ultrawide and both players
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			if player==PLAYER_1 then
				self:x(-86 - (total_width-28))
			else
				self:x( 86 + (total_width-28))
			end
		end
	end
}

-- -----------------------------------------------------------------------

return af