local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- don't allow MeasureCounter to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual"
or not mods.MeasureCounter
or mods.MeasureCounter == "None" then
	return
end


local PlayerState = GAMESTATE:GetPlayerState(player)
local streams, prev_measure, MeasureCounterBMT
local current_count, stream_index, current_stream_length

-- We'll want to reset each of these values for each new song in the case of CourseMode
local InitializeMeasureCounter = function()
	-- SL[pn].Streams is initially set (and updated in CourseMode)
	-- in ./ScreenGameplay in/MeasureCounterAndModsLevel.lua
	streams = SL[pn].Streams
	current_count = 0
	stream_index = 1
	current_stream_length = 0
	prev_measure = 0
end

local GetTextForMeasure = function(current_measure, Measures, stream_index)
	-- Validate indices
	if Measures[stream_index] == nil then return "" end

	local streamStart = Measures[stream_index].streamStart
	local streamEnd = Measures[stream_index].streamEnd
	if current_measure < streamStart then return "" end
	if current_measure > streamEnd then return "" end

	local current_stream_length = streamEnd - streamStart
	local current_count = math.floor(current_measure - streamStart) + 1

	local text = ""
	if Measures[stream_index].isBreak then
		if mods.HideRestCounts == false then
			-- NOTE: We let the lowest value be 0. This means that e.g.,
			-- for an 8 measure break, we will display the numbers 7 -> 0
			local measures_left = current_stream_length - current_count

			if measures_left >= (current_stream_length-1) or measures_left <= 0 then
				text = ""
			else
				text = "(" .. measures_left .. ")"
			end
			-- diffuse break counter to be Still Grey, just like Pendulum intended
			MeasureCounterBMT:diffuse(0.5,0.5,0.5,1)
		end
	else
		text = tostring(current_count .. "/" .. current_stream_length)
		MeasureCounterBMT:diffuse(1,1,1,1)
	end
	return text, current_count > current_stream_length
end

local Update = function(self, delta)

	if not streams.Measures then return end

	local curr_measure = (math.floor(PlayerState:GetSongPosition():GetSongBeatVisible()))/4

	-- if a new measure has occurred
	if curr_measure > prev_measure then

		prev_measure = curr_measure
		local text, is_end = GetTextForMeasure(curr_measure, streams.Measures, stream_index)

		-- If we're still within the current section
		if not is_end then
			MeasureCounterBMT:settext(text)
		-- In a new section, we should check if curr_measure overlaps with it
		else
			stream_index = stream_index + 1
			text, is_end = GetTextForMeasure(curr_measure, streams.Measures, stream_index)
			MeasureCounterBMT:settext(text)
		end
	end
end


local af = Def.ActorFrame{
	InitCommand=function(self)
		self:queuecommand("SetUpdate")
	end,
	CurrentSongChangedMessageCommand=function(self)
		InitializeMeasureCounter()
	end,
	SetUpdateCommand=function(self)
		self:SetUpdateFunction( Update )
	end
}

af[#af+1] = LoadFont("_wendy small")..{
	InitCommand=function(self)
		MeasureCounterBMT = self

		self:zoom(0.35):shadowlength(1):horizalign(center)
		self:xy( GetNotefieldX(player), _screen.cy )

		if mods.MeasureCounterLeft then
			local width = GAMESTATE:GetCurrentStyle(player):GetWidth(player)
			local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
			self:x( GetNotefieldX(player) - (width/NumColumns) )
		end

		if mods.MeasureCounterUp then
			self:y(_screen.cy - 55)
		end
	end
}

return af
