local player = ...

local SongNumberInCourse = 0
local LifeLineThickness = 2
local LifeMeter = nil
local life_verts = {}
local width = GetNotefieldWidth(player)
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
				verts[#verts+1] = {{x, 0, 0}, {1,1,1,1}}
				verts[#verts+1] = {{x, y, 0}, {1,1,1,1}}
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
		end
	}

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

	local amv = Def.ActorMultiVertex{
		Name="DensityGraph_AMV",
		InitCommand=function(self)
			self:SetDrawState{Mode="DrawMode_QuadStrip"}
				:align(0, 0)
				-- offset the graph's x-position by half the thickness of the LifeLine
				:x( WideScale(0,60) + LifeLineThickness/2 )
				:y(height)
				:MaskSource()
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
	}

	local gradient = Def.Sprite{
		Texture="./NPS-gradient.png",
		InitCommand=function(self)
			self:zoomto(_screen.w/2, height)
				:align(0,0)
				:x( WideScale(0,60) )
				:ztestmode("ZTestMode_WriteOnFail")
		end
	}

	local SlopeAngle = function(p1, p2)
		return math.atan2(p2[1] - p1[1], p2[2] - p1[2])
	end

	local lifeline = Def.ActorMultiVertex{
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

			self:sleep(LifeSampleRate):queuecommand("Sample")
		end,
		CurrentSongChangedMessageCommand=function(self)
			life_verts = {}
			self:SetNumVertices(#life_verts):SetVertices(life_verts)
		end
	}

	af[#af+1] = text
	af[#af+1] = bg
	af[#af+1] = amv
	af[#af+1] = gradient
	af[#af+1] = lifeline

	return af
end
