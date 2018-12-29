local player = ...

local SongNumberInCourse = 0
local LifeLineThickness = 2
local LifeMeter = nil
local life_verts = {}

-- max_seconds is how seconds of a song is visualized before we don't display the entire
-- density graph on-screen at once. For very long songs (longer than, say, 10 minutes)
-- the density graph otherwise becomes too horizontally compressed (squeezed in, so to speak)
-- and it's dificult get any useful information out of it, visually.
--
-- So, we hardcode it to 4 minutes here. If the song is longer than 4 minutes, the density graph will
-- scroll with the song.  If the song is shorter than 4 minutes, we'll scale the width of the graph
-- to take up the full width available in the StepStatistics sidebar.
local max_seconds = 4 * 60

-- width is how wide, in pixels, the density graph will be
-- it will be given a larger value in InitializeNPSHistogram() if the song is longer than max_seconds
local width = GetNotefieldWidth(player)
-- height is how tall, in pixels, the density graph will be
local height = GetNotefieldWidth(player)/2.25


local LifeBaseSampleRate = 0.25
local MaxVertices = 2000 -- based on noticeable lag at ~3.5k
local LifeSampleRate

local Song, Steps, StepsType, Difficulty, TrailEntry
local PeakNPS, NPSperMeasure, PeakNPS_BMT
local TimingData, FirstSecond, TotalSeconds
local verts, x, y, t

local HasData = function()
	return (PeakNPS and NPSperMeasure and #NPSperMeasure > 1)
end

-- -------------------------------------------------
local InitializeNPSHistogram = function()

	if GAMESTATE:IsCourseMode() then
		TrailEntry = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()[SongNumberInCourse+1]
		Steps = TrailEntry:GetSteps()
		Song = TrailEntry:GetSong()
	else
		Steps = GAMESTATE:GetCurrentSteps(player)
		Song = GAMESTATE:GetCurrentSong()
	end

	StepsType = ToEnumShortString( Steps:GetStepsType() ):gsub("_", "-"):lower()
	Difficulty = ToEnumShortString( Steps:GetDifficulty() )

	PeakNPS, NPSperMeasure = GetNPSperMeasure(Song, StepsType, Difficulty)

	LifeSampleRate = BaseRate

	if HasData() then

		TimingData = Song:GetTimingData()

		-- Don't use Song:MusicLengthSeconds() because it includes time
		-- at the beginning before beat 0 has occurred
		FirstSecond =  Song:GetFirstSecond()
		TotalSeconds = Song:GetLastSecond() - FirstSecond

		-- assume the song is shorter than max_seconds and make the width of the graph
		-- the same as the width of a Notefield
		width = GetNotefieldWidth(player)
		-- if the song is longer than max_seconds, scale up the width of the graph
		if TotalSeconds > max_seconds then
			width = width * (TotalSeconds/max_seconds)
		end

		LifeSampleRate = LifeBaseSampleRate + TotalSeconds / MaxVertices

		-- if the song has a 'simple' BPM, then quantize the timing
		-- to the nearest multiple of 8ths to avoid jaggies
		if not TimingData:HasBPMChanges() then
			local theBPM = TimingData:GetBPMs()[1]
			if theBPM >= 60 and theBPM <= 300 then
				-- make sure that the BPM makes sense
				local Interval8th = (60 / theBPM) / 2
				LifeSampleRate = Interval8th * math.ceil(LifeSampleRate / Interval8th)
			end
		end

		verts = {}
		x, y, t = nil, nil, nil

		-- magic numbers obtained from Photoshop's Eyedrop tool
		local yellow = {0.968, 0.953, 0.2, 1}
		local orange = {0.863, 0.553, 0.2, 1}
		local upper

		for i, nps in ipairs(NPSperMeasure) do
			-- i will represent the current measure number but will be 1 larger than
			-- it should be (measures in SM start at 0; indexed Lua tables start at 1)
			-- subtract 1 from i now to get the actual measure number to calculate time
			t = TimingData:GetElapsedTimeFromBeat((i-1)*4)

			x = scale(t, 0, TotalSeconds, 0, width)
			y = round(-1 * scale(nps, 0, PeakNPS, 0, height))

			-- if the height of this measure is the same as the previous two measures
			-- we don't need to add two more points (bottom and top) to the verts table,
			-- we can just "extend" the previous two points by updating their x position
			-- to that of the current measure.  For songs with long streams, this should
			-- cut down on the overall size of the verts table significantly.
			if i > 2 and verts[#verts][1][2] == y and verts[#verts-2][1][2] == y then
				verts[#verts][1][1] = x
				verts[#verts-1][1][1] = x
			else
				-- lerp_color() take a float between [0,1], color1, and color2, and returns a color
				-- that has been linearly interpolated by that percent between the colors provided
				upper = lerp_color(math.abs(y/height), yellow, orange )

				verts[#verts+1] = {{x, 0, 0}, yellow} -- bottom of graph (yellow)
				verts[#verts+1] = {{x, y, 0}, upper}  -- top of graph (somewhere between yellow and orange)
			end
		end
	end
end

InitializeNPSHistogram()

-- -------------------------------------------------
-- Actors defined below this line
if HasData() then

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:xy( WideScale(-160, -214), 48 )
				:queuecommand("Sample")

			if (PREFSMAN:GetPreference("Center1Player") and IsUsingWideScreen()) then
				-- 16:9 aspect ratio (approximately 1.7778)
				if GetScreenAspectRatio() > 1.7 then
					self:y(60)
				-- if 16:10 aspect ratio
				else
					self:y(80)
				end
			end
		end,
		OnCommand=function(self)
			LifeMeter = SCREENMAN:GetTopScreen():GetChild("Life"..ToEnumShortString(player))
		end,
		SampleCommand=function(self)
			self:sleep(LifeSampleRate):queuecommand("Sample")
		end
	}

	-- PeakNPS text
	local text = Def.BitmapText{
		Font="_miso",
		InitCommand=function(self)
			self:settext( THEME:GetString("ScreenGameplay", "PeakNPS") .. ": " .. round(PeakNPS * SL.Global.ActiveModifiers.MusicRate,2) )
			self:x( _screen.w/2 - self:GetWidth()/2 - 2 + WideScale(0,-60) )
				:y( -self:GetHeight()/2 - 2 )
				:zoom(0.9)

			PeakNPS_BMT = self
		end,
	}

	-- gray background Quad
	local bg = Def.Quad{
		InitCommand=function(self)
			self:zoomto(_screen.w/2,height)
				:align(0,0)
				:diffuse(color("#1E282F"))

			if (PREFSMAN:GetPreference("Center1Player") and IsUsingWideScreen()) then
				-- 16:9 aspect ratio (approximately 1.7778)
				if GetScreenAspectRatio() > 1.7 then
					self:x(45 * (player==PLAYER_1 and 1 or -1))

				-- if 16:10 aspect ratio
				else
					self:x(36 * (player==PLAYER_1 and 1 or -1))
				end
			end
		end
	}

	-- helper function
	local SlopeAngle = function(p1, p2)
		return math.atan2(p2[1] - p1[1], p2[2] - p1[2])
	end

	local density_graph_and_lifeline = Def.ActorFrame{
		-- reset x-offset between songs in CourseMode
		CurrentSongChangedMessageCommand=function(self) self:x(0) end,

		SampleCommand=function(self)
			-- if it's not a long graph, there's no need to scroll it at all
			if width <= GetNotefieldWidth(player) then return end

			local current_second = GAMESTATE:GetCurMusicSeconds()

			-- if the end of the song is close, no need to keep scrolling
			if current_second > TotalSeconds - (max_seconds*WideScale(0.25,0.5)) then return end

			-- use 1/4 of whatever max_seconds is as the cutoff to start scrolling the graph
			local seconds_past_one_fourth = current_second-(max_seconds*0.25)

			if seconds_past_one_fourth > 0 then
				local offset = scale(seconds_past_one_fourth, 0, TotalSeconds-(max_seconds*0.25), 0, width-(GetNotefieldWidth(player)*0.75))
				self:x(-offset)
			end
		end,

		-- density graph
		Def.ActorMultiVertex{
			Name="DensityGraph_AMV",
			InitCommand=function(self)
				self:SetDrawState{Mode="DrawMode_QuadStrip"}
					:align(0, 0)
					-- offset the graph's x-position by half the thickness of the LifeLine
					:x( WideScale(0,60) + LifeLineThickness/2 )
					:y(height)
			end,
			CurrentSongChangedMessageCommand=function(self)
				-- we've reached a new song, so reset the vertices for the density graph
				-- this will occur at the start of each new song in CourseMode
				-- and at the start of "normal" gameplay
				verts = {}
				self:SetNumVertices(#verts):SetVertices(verts)
				self:queuecommand("Reinitalize")
			end,
			ReinitalizeCommand=function(self)
				InitializeNPSHistogram()
				SongNumberInCourse = SongNumberInCourse + 1
				self:queuecommand("SetVerts")
			end,
			SetVertsCommand=function(self)
				-- update the text for PeakNPS and reposition since it may now be longer/shorter
				PeakNPS_BMT:queuecommand( "Init" )
				-- update the density graph's vertices
				self:SetVertices(verts)
			end
		},

		-- lifeline
		Def.ActorMultiVertex{
			Name="LifeLine_AMV",
			InitCommand=function(self)
				self:SetDrawState{Mode="DrawMode_LineStrip"}
					:SetLineWidth( LifeLineThickness )
					:align(0, 0)
					:x( WideScale(0,60) )
			end,
			SampleCommand=function(self)
				if GAMESTATE:GetCurMusicSeconds() > 0 then
					x = scale( GAMESTATE:GetCurMusicSeconds(), 0, TotalSeconds, 0, width )
					y = scale( LifeMeter:GetLife(), 1, 0, 0, height )

					-- if the slopes of the newest line segment is similar
					-- to the previous segment, just extend the old one.
					local condense = false
					if (#life_verts >= 2) then
						slope_original = SlopeAngle(life_verts[#life_verts-1][1], life_verts[#life_verts][1])
						slope_new = SlopeAngle(life_verts[#life_verts][1], {x,y})

						-- 0.18 rad = ~10 deg
						condense = math.abs(slope_new - slope_original) < 0.18 and slope_original > 0 and slope_new > 0
					end

					if condense then
						life_verts[#life_verts][1] = {x,y,0}
					else
						life_verts[#life_verts+1] = {{x, y, 0}, {1,1,1,1}}
					end

					self:SetVertices(life_verts)
				end
			end,
			CurrentSongChangedMessageCommand=function(self)
				life_verts = {}
				self:SetNumVertices(#life_verts):SetVertices(life_verts)
			end
		},
	}

	-- The "graph_mask" here is not a "mask" in the proper sense.  I did experiment with that briefly,
	-- but abandoned it because it impacted the rendering of many ITG NoteSkins that also use masks...
	-- So, the graph_mask is really just a black quad positioned in front of the density_graph_and_lifeline
	-- but behind all other underlay elements (like danger and subtractive scoring and etc.)
	local graph_mask = Def.Quad{
		InitCommand=function(self)
			self:zoomto(_screen.w/2, _screen.h)
				:x( WideScale(160, 214) + _screen.cx * (player==PLAYER_1  and -1 or 1) )
				:y(-48)
				:diffuse( Color.Black )


			-- handle Center1Player begrudgingly with clumsy code
			if (PREFSMAN:GetPreference("Center1Player") and IsUsingWideScreen()) then
				self:zoomto(_screen.w, _screen.h * (1/0.9))

				-- 16:9 aspect ratio (approximately 1.7778)
				if GetScreenAspectRatio() > 1.7 then
					self:x(player==PLAYER_1 and -382 or _screen.w-44)
						:y(-55)

				-- if 16:10 aspect ratio
				else
					self:x(player==PLAYER_1 and -348 or _screen.w-36)
						:y(-104)
				end
			end
		end
	}

	af[#af+1] = text
	af[#af+1] = bg
	af[#af+1] = density_graph_and_lifeline
	af[#af+1] = graph_mask

	return af
end
