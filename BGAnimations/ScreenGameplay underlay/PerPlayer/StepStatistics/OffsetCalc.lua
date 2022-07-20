local player = ...
local pn = ToEnumShortString(player)

local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)
local IsUltraWide = (GetScreenAspectRatio() > 21/9)

-- simple flag used in the Update function to stop updating remBMT once the player runs out of life
local alive = true

local num_judgments_available = NumJudgmentsAvailable()
local worst_window = GetTimingWindow(num_judgments_available)

local mean_taps = 0
local median_taps = 0
local offsets = {}
local med_seq = {}
local mean_seq = {}

-- ---------------------------------------------
-- MEDIAN, and AVG TIMING ERROR VARIABLES
-- initialize all to zero

-- median_offset is the offset in the middle of an ordered list of all offsets
-- 2 is the median in a set of { 1, 1, 2, 3, 4 } because it is in the middle
local median_offset = 0

-- highest_offset_count is how many times the mode_offset occurred
-- we'll use it to scale the histogram to be an appropriate height
local highest_offset_count = 0

-- sum_timing_error will be used in a loop to sum the total timing error
-- accumulated over the entire stepchart during gameplay
local sum_timing_error = 0
-- we'll divide sum_timing_error by the number of judgments that occured
-- to get the mean timing error
local avg_timing_error = 0

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

-- -----------------------------------------------------------------------
-- median number
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:x(260)
		self:halign(PlayerNumber:Reverse()[player]):vertalign(bottom)
		self:settext("0.0ms")

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
	end,
	
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end
		if not params.TapNoteScore then return end
		if params.TapNoteScore == "TapNoteScore_Miss" or params.TapNoteScore == "TapNoteScore_AvoidMine" or params.TapNoteScore == "TapNoteScore_HitMine" then return end
		
		median_taps = median_taps + 1
		
		local val = (math.floor(params.TapNoteOffset*1000))/1000
		med_seq[#med_seq+1] = val

		if not offsets[val] then
			offsets[val] = 1
		else
			offsets[val] = offsets[val] + 1
		end
		
		if #med_seq > 64 then
			offsets[med_seq[#med_seq-64]] = offsets[med_seq[#med_seq-64]] - 1
		end
		
		-- transform a key=value table in the format of offset_value=count
		-- into an ordered list of offset values
		-- this will make calculating the median very straightforward
		local list = {}
		for offset=-worst_window, worst_window, 0.001 do

			-- TODO: Ruminate over whether rounding to 3 decimal places (millisecond precision)
			-- is the right thing to be doing here.  Things to consider include:
			--   • are we losing precision in a way that could impact players?
			--   • does Lua 5.1's floating point precision come into play here?
			--   • should hardware (e.g. low polling rates) be considered here?  can it?
			--   • does the judgment offset histogram really need 10x more verts to draw?
			offset = round(offset,3)

			if offsets[offset] then
				for i=1,offsets[offset] do
					list[#list+1] = offset
				end
			end
		end
		
		if #list % 2 == 1 then
			median_offset = list[math.ceil(#list/2)]
		else
			median_offset = (list[#list/2] + list[#list/2+1])/2
		end
		
		self:settext(("%.1fms"):format(median_offset*1000))
	end,
	
	OnCommand=function(self)
		if player==PLAYER_1 then
			self:x( 250 + (total_width-28))
		else
			self:x(-122 - (total_width-28))
		end

		-- flip offset when ultrawide and both players
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			if player==PLAYER_1 then
				self:x(-186 - (total_width-28))
			else
				self:x( 186 + (total_width-28))
			end
		end
	end
}

-- median label
af[#af+1] = LoadFont("Common Normal")..{
	Text="Median Offset (64n)",
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
			self:x( 132 + (total_width-28))
		else
			self:x(-192 - (total_width-28))
		end

		-- flip offset when ultrawide and both players
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			if player==PLAYER_1 then
				self:x(-186 - (total_width-28))
			else
				self:x( 186 + (total_width-28))
			end
		end
	end
}

-- -----------------------------------------------------------------------
-- mean number
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:xy(260,20)
		self:halign(PlayerNumber:Reverse()[player]):vertalign(bottom)
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			self:halign( PlayerNumber:Reverse()[OtherPlayer[player]] )
			self:x(50 * (player==PLAYER_1 and -1 or 1))
		end

		self:settext("0.0ms")
		total_width = self:GetWidth()
	end,
	
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end
		if not params.TapNoteScore then return end
		if params.TapNoteScore == "TapNoteScore_Miss" or params.TapNoteScore == "TapNoteScore_AvoidMine" or params.TapNoteScore == "TapNoteScore_HitMine" then return end
		
		mean_taps = mean_taps + 1
		mean_seq[#mean_seq+1] = math.abs(params.TapNoteOffset)
		if #mean_seq > 64 then
			sum_timing_error = sum_timing_error - mean_seq[#mean_seq-64]
		end
		
		sum_timing_error = sum_timing_error + math.abs(params.TapNoteOffset)
		avg_timing_error = sum_timing_error / math.min(64, mean_taps) * 1000
		
		self:settext(("%.1fms"):format(avg_timing_error))
	end,
	
	OnCommand=function(self)
		if player==PLAYER_1 then
			self:x( 250 + (total_width-28))
		else
			self:x(-122 - (total_width-28))
		end

		-- flip offset when ultrawide and both players
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			if player==PLAYER_1 then
				self:x(-186 - (total_width-28))
			else
				self:x( 186 + (total_width-28))
			end
		end
	end
}

-- mean label
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:zoom(0.833)
		self:halign(PlayerNumber:Reverse()[player]):vertalign(bottom)
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			self:halign( PlayerNumber:Reverse()[OtherPlayer[player]] )
		end

		self:settext( "Mean Error (64n)" )
	end,
	OnCommand=function(self)
		if player==PLAYER_1 then
			self:x(132 + (total_width-28))
		else
			self:x(-192 - (total_width-28))
		end
		self:y(20)

		-- flip offset when ultrawide and both players
		if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
			if player==PLAYER_1 then
				self:x(-186 - (total_width-28))
			else
				self:x( 186 + (total_width-28))
			end
		end
	end
}

-- -----------------------------------------------------------------------

return af