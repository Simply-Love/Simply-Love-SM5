local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local streams = SL[pn].Streams
local PlayerState = GAMESTATE:GetPlayerState(player)

local current_measure, previous_measure
local MeasureCounterBMT

local current_count = 0
local stream_index = 1
local current_stream_length = 0

local function Update(self, delta)

	if not streams.Measures then return end

	current_measure = (math.floor(PlayerState:GetSongPosition():GetSongBeatVisible()))/4

	-- previous_measure will initially be nil; set it to be the same as current_measure
	if not previous_measure then previous_measure = current_measure end

	local new_measure_has_occurred = current_measure > previous_measure

	if new_measure_has_occurred then

		previous_measure = current_measure

		-- if the current measure is within the of the current stream
		if streams.Measures[stream_index]
		and current_measure >= streams.Measures[stream_index].streamStart
		and current_measure <= streams.Measures[stream_index].streamEnd then

			current_stream_length = streams.Measures[stream_index].streamEnd - streams.Measures[stream_index].streamStart
			current_count = math.floor(current_measure - streams.Measures[stream_index].streamStart) + 1

			text = tostring(current_count .. "/" .. current_stream_length)
			MeasureCounterBMT:settext( text )

			if current_count > current_stream_length then
				stream_index = stream_index + 1
				MeasureCounterBMT:settext( "" )
			end
		else
			MeasureCounterBMT:settext( "" )
		end
	end

	return
end

if mods.MeasureCounter and mods.MeasureCounter ~= "None" then

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:queuecommand("SetUpdate")
		end,
		SetUpdateCommand=function(self)
			self:SetUpdateFunction( Update )
		end
	}

	af[#af+1] = Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			MeasureCounterBMT = self

			local style = GAMESTATE:GetCurrentStyle(player)
			local width = style:GetWidth(player)
			local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()

			self:zoom(0.35)
				:xy( GetNotefieldX(player) - (width/NumColumns), _screen.cy )
				:shadowlength(1)
		end
	}

	return af

else
	return Def.Actor{}
end
