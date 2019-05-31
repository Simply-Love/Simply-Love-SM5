local player = ...

local LifeBaseSampleRate = 0.25
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
local width = GetNotefieldWidth(player)
local scaled_width = width

-- height is how tall, in pixels, the density graph will be
local height = width/2.25

local UpdateRate, last_second

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:xy( WideScale(-160, -214), 48 )
			:queuecommand("Update")

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
	UpdateCommand=function(self)
		self:sleep(UpdateRate):queuecommand("Update")
	end
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

local histogram_amv = NPS_Histogram(player, width, height)..{
	OnCommand=function(self)
		-- offset the graph's x-position by half the thickness of the LifeLine
		self:x( WideScale(0,60) + LifeLineThickness/2 )
			:y(height)
	end
}

-- PeakNPS text
local text = LoadFont("_miso")..{
	PeakNPSUpdatedMessageCommand=function(self, params)
		self:settext( THEME:GetString("ScreenGameplay", "PeakNPS") .. ": " .. round(params.PeakNPS * SL.Global.ActiveModifiers.MusicRate,2) )
		self:x( _screen.w/2 - self:GetWidth()/2 - 2 + WideScale(0,-60) )
			:y( -self:GetHeight()/2 - 2 )
			:zoom(0.9)
	end,
}

local graph_and_lifeline = Def.ActorFrame{

	CurrentSongChangedMessageCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		last_second = song:GetLastSecond()
		-- reset scaled_width now to be only as wide as the notefield
		scaled_width = width
		TimingData = song:GetTimingData()

		-- if the song is longer than max_seconds, scale up the width of the graph
		if last_second > max_seconds then
			local ratio = (last_second/max_seconds)
			scaled_width = width * ratio
			self:GetChild("DensityGraph_AMV"):zoomtowidth(ratio)
		end

		UpdateRate = LifeBaseSampleRate + (last_second / histogram_amv.MaxVertices)

		-- if the song has a 'simple' BPM, then quantize the timing
		-- to the nearest multiple of 8ths to avoid jaggies
		if not TimingData:HasBPMChanges() then
			local bpm = TimingData:GetBPMs()[1]
			if bpm >= 60 and bpm <= 300 then
				-- make sure that the BPM makes sense
				local Interval8th = (60 / bpm) / 2
				UpdateRate = Interval8th * math.ceil(UpdateRate / Interval8th)
			end
		end

		-- reset x-offset between songs in CourseMode
		self:x(0)
	end,

	UpdateCommand=function(self)
		-- if it's not a long graph, there's no need to scroll it at all
		if scaled_width <= width then return end

		local current_second = GAMESTATE:GetCurMusicSeconds()

		-- if the end of the song is close, no need to keep scrolling
		if current_second > last_second - (max_seconds*WideScale(0.25,0.5)) then return end

		-- use 1/4 of whatever max_seconds is as the cutoff to start scrolling the graph
		local seconds_past_one_fourth = current_second-(max_seconds*0.25)

		if seconds_past_one_fourth > 0 then
			local offset = scale(seconds_past_one_fourth, 0, last_second-(max_seconds*0.25), 0, scaled_width-(width*0.75))
			self:x(-offset)
		end
	end,

	-- density graph
	histogram_amv,

	-- lifeline
	Def.ActorMultiVertex{
		Name="LifeLine_AMV",
		InitCommand=function(self)
			self:SetDrawState({Mode="DrawMode_LineStrip"})
				:SetLineWidth( LifeLineThickness )
				:align(0, 0)
				:x( WideScale(0,60) )
		end,
		UpdateCommand=function(self)
			if GAMESTATE:GetCurMusicSeconds() > 0 then
				x = scale( GAMESTATE:GetCurMusicSeconds(), 0, last_second, 0, scaled_width )
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
-- So, the graph_mask is really just a black quad positioned in front of the graph_and_lifeline
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
af[#af+1] = graph_and_lifeline
af[#af+1] = graph_mask

return af
