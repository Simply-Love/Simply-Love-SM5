-- don't allow MeasureCounter to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" then return end

local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local PlayerState = GAMESTATE:GetPlayerState(player)
local streams, current_measure, previous_measure, MeasureCounterBMT
local current_count, stream_index, current_stream_length

-- We'll want to reset each of these values for each new song in the case of CourseMode
local function InitializeMeasureCounter()
	streams = SL[pn].Streams
	current_count = 0
	stream_index = 1
	current_stream_length = 0
	previous_measure = nil
end

local function GetTextForMeasure(current_measure, Measures, stream_index)
	-- Validate indices
	if Measures[stream_index] == nil then return "" end

	local streamStart = Measures[stream_index].streamStart
	local streamEnd = Measures[stream_index].streamEnd
	if current_measure < streamStart then return "" end
	if current_measure > streamEnd then return "" end

	local current_stream_length = streamEnd - streamStart
	local current_count = math.floor(current_measure - streamStart) + 1

	text = tostring(current_count .. "/" .. current_stream_length)
	if streams.Measures[stream_index].isBreak then
		text = "(" .. text .. ")"
	end
	return text, current_count > current_stream_length
end

local function Update(self, delta)

	if not streams.Measures then return end

	current_measure = (math.floor(PlayerState:GetSongPosition():GetSongBeatVisible()))/4

	-- previous_measure will initially be nil; set it to be the same as current_measure
	if not previous_measure then previous_measure = current_measure end

	local new_measure_has_occurred = current_measure > previous_measure

	if new_measure_has_occurred then

		previous_measure = current_measure
		local text, is_end = GetTextForMeasure(current_measure, streams.Measures, stream_index)
		
		-- If we're still within the current section
		if not is_end then
			MeasureCounterBMT:settext(text)
		-- In a new section, we should check if current_measure overlaps with it
		else
			stream_index = stream_index + 1
			text, is_end = GetTextForMeasure(current_measure, streams.Measures, stream_index)
			MeasureCounterBMT:settext(text)
		end
	end

	return
end

if mods.MeasureCounter and mods.MeasureCounter ~= "None" then

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

	af[#af+1] = Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			MeasureCounterBMT = self

			self:zoom(0.35):shadowlength(1):horizalign(center)
			if mods.MeasureCounterPosition == "Center" then
				self:xy( GetNotefieldX(player), _screen.cy )
			else
				local width = GAMESTATE:GetCurrentStyle(player):GetWidth(player)
				local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()

				self:xy( GetNotefieldX(player) - (width/NumColumns), _screen.cy )
			end
		end
	}

	return af

else
	return Def.Actor{}
end
