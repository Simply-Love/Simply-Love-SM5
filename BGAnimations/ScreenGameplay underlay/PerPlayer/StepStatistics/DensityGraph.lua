local player, width = unpack(...)

local pn = ToEnumShortString(player)
-- height is how tall, in pixels, the density graph will be
local height = 105

local LifeBaseSampleRate = 0.25
local LifeLineThickness = 2
local LifeMeter = nil
local life_verts = {}
local offset = 0

local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

-- -----------------------------------------------------------------------
local BothUsingStepStats = (#GAMESTATE:GetHumanPlayers()==2
and SL.P1.ActiveModifiers.DataVisualizations == "Step Statistics"
and SL.P2.ActiveModifiers.DataVisualizations == "Step Statistics")
-- -----------------------------------------------------------------------

-- max_seconds is how many seconds of a stepchart we want visualized on-screen at once.
-- For very long songs (longer than, say, 10 minutes) the density graph becomes too
-- horizontally compressed (squeezed in, so to speak) and it's dificult to get any useful
-- information out of it, visually.  And there are a lot of Very Long Songs™.
--
-- So, we hardcode it to 4 minutes here. If the song is longer than 4 minutes, the density
-- graph will scroll with the song.  If the song is shorter than 4 minutes, we'll scale
-- the width of the graph to take up the full width available in the StepStatistics sidebar.
local max_seconds = 4 * 60

-- width and position of the density graph
local pos_x = -width / 2

local scaled_width = width
local UpdateRate, first_second, last_second

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:xy( pos_x, 55 ):queuecommand("Update")
	end,
	OnCommand=function(self)
		LifeMeter = SCREENMAN:GetTopScreen():GetChild("Life"..pn)
	end,
	UpdateCommand=function(self)
		if UpdateRate ~= nil then
			self:sleep(UpdateRate):queuecommand("Update")
		else
			self:sleep(LifeBaseSampleRate):queuecommand("Update")
		end
	end
}

-- gray background Quad
local bg = Def.Quad{
	InitCommand=function(self)
		self:zoomto(width, height)
			:align(0,0)
			:diffuse(color("#1E282F"))
	end
}

-- FIXME: add inline comments explaining the intent/purpose of this code
local SlopeAngle = function(p1, p2)
	return math.atan2(p2[1] - p1[1], p2[2] - p1[2])
end

local histogram_amv = Scrolling_NPS_Histogram(player, width, height)..{
	OnCommand=function(self)
		-- offset the graph's x-position by half the thickness of the LifeLine
		self:xy( LifeLineThickness/2, height )
	end,
	PeakNPSUpdatedMessageCommand=function(self) self:queuecommand("Size") end,
	SizeCommand=function(self)
		if BothUsingStepStats then
			local my_peak = GAMESTATE:Env()[pn.."PeakNPS"]
			local their_peak = GAMESTATE:Env()[ToEnumShortString(OtherPlayer[player]).."PeakNPS"]

			if my_peak < their_peak then
				self:zoomtoheight(my_peak/their_peak)
			end
		end
	end
}

-- PeakNPS text
local text = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:zoom(0.9)
		self:halign( PlayerNumber:Reverse()[OtherPlayer[player]] )
		self:vertalign(bottom)

		-- flip alignment if ultrawide and both players joined because the pane
		-- will now appear on the player's side of the screen rather than opposite
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			self:halign( PlayerNumber:Reverse()[player] )
		end
	end,
	PeakNPSUpdatedMessageCommand=function(self)
		local my_peak = GAMESTATE:Env()[pn.."PeakNPS"]

		if my_peak == nil then
			self:settext("")
			return
		end

		if player == PLAYER_1 then
			self:x(_screen.w*0.5 - SL_WideScale(6,59))

			if NoteFieldIsCentered then
				self:x(_screen.w*0.5 - 134)
			end
			if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
				self:x(52)
			end
		else
			self:x(SL_WideScale(6,130))
			if NoteFieldIsCentered then
				self:x(69)
			end
			if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
				self:x(180)
			end
		end

		self:y( -self:GetHeight()/2 - 2 )
		self:settext( ("%s: %g"):format(THEME:GetString("ScreenGameplay", "PeakNPS"), round(my_peak * SL.Global.ActiveModifiers.MusicRate,2)) )
	end,
}

local graph_and_lifeline = Def.ActorFrame{

	CurrentSongChangedMessageCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		first_second = math.min(song:GetTimingData():GetElapsedTimeFromBeat(0), 0)
		last_second = song:GetLastSecond()
		-- reset scaled_width now to be only as wide as the notefield
		scaled_width = width
		TimingData = song:GetTimingData()

		-- if the song is longer than max_seconds, scale up the width of the graph
		local duration = last_second - first_second
		if duration > max_seconds then
			local ratio = duration / max_seconds
			scaled_width = width * ratio
		end

		histogram_amv:LoadCurrentSong(scaled_width)

		UpdateRate = LifeBaseSampleRate

		-- round up UpdateRate and quantize it to an 8th note interval
		-- for streams, this means each update interval contains a consistent number of notes,
		-- so that when one keeps combo, the total life gained between updates will be similar,
		-- which makes the similar slope optimization below more likely to take place
		-- but if we have BPM changes, then a single interval doesn't work
		if not TimingData:HasBPMChanges() then
			local bpm = TimingData:GetBPMs()[1]
			-- also avoid this for low BPMs because that might make the interval too long to be useful
			if bpm >= 60 then
				local Interval8th = (60 / bpm) / 2
				UpdateRate = Interval8th * math.ceil(UpdateRate / Interval8th)
			end
		end

		-- reset x-offset between songs in CourseMode
		self:x(0)
		offset = 0
	end,

	UpdateCommand=function(self)
		-- if it's not a long graph, there's no need to scroll it at all
		if scaled_width <= width then return end

		local current_second = GAMESTATE:GetCurMusicSeconds()

		-- if the end of the song is close, no need to keep scrolling
		if current_second > last_second - (max_seconds*0.75) then return end

		-- use 1/4 of whatever max_seconds is as the cutoff to start scrolling the graph
		local seconds_past_one_fourth = (current_second-first_second) - (max_seconds*0.25)

		if seconds_past_one_fourth > 0 then
			offset = scale(seconds_past_one_fourth, 0, last_second-first_second, 0, scaled_width)
			self:x(-offset)
			histogram_amv:SetScrollOffset(offset)
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
		end,
		UpdateCommand=function(self)
			if GAMESTATE:GetCurMusicSeconds() > 0 then
				local seconds = GAMESTATE:GetCurMusicSeconds()
				if seconds > last_second then return end

				local x = scale( seconds, first_second, last_second, 0, scaled_width )
				local y = scale( LifeMeter:GetLife(), 1, 0, 0, height )

				-- if the slope of the newest line segment is similar
				-- to the slope of the previous segment, extend the old one.
				local condense = false
				if (#life_verts >= 2) then
					local slope_original = SlopeAngle(life_verts[#life_verts-1][1], life_verts[#life_verts][1])
					local slope_new = SlopeAngle(life_verts[#life_verts][1], {x,y})

					-- 0.18 rad = ~10 deg
					condense = math.abs(slope_new - slope_original) < 0.18 and slope_original > 0 and slope_new > 0
				end

				if condense then
					life_verts[#life_verts][1] = {x, y, 0}
				else
					life_verts[#life_verts+1] = {{x, y, 0}, {1,1,1,1}}
				end

				while #life_verts > 0 and life_verts[1][1][1] < offset do
					if #life_verts > 1 and life_verts[2][1][1] >= offset then
						life_verts[1] = interpolate_vert(life_verts[1], life_verts[2], offset)
						break
					else
						table.remove(life_verts, 1)
					end
				end

				self:SetNumVertices(#life_verts):SetVertices(life_verts)
			end
		end,
		CurrentSongChangedMessageCommand=function(self)
			life_verts = {}
			self:SetNumVertices(#life_verts):SetVertices(life_verts)
		end
	},
}

af[#af+1] = text
af[#af+1] = bg
af[#af+1] = graph_and_lifeline

return af
