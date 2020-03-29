local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- don't allow MeasureCounter to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual"
or not mods.MeasureCounter
or mods.MeasureCounter == "None" then
	return
end

-- -----------------------------------------------------------------------

local PlayerState = GAMESTATE:GetPlayerState(player)
local streams, prev_measure, bmt
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
	-- validate indices
	if Measures[stream_index] == nil then return "" end

	-- a "segment" can be either stream or rest
	local segmentStart = Measures[stream_index].streamStart
	local segmentEnd   = Measures[stream_index].streamEnd

	if current_measure < segmentStart then return "" end
	if current_measure > segmentEnd   then return "" end

	local current_stream_length = segmentEnd - segmentStart
	local current_count = math.floor(current_measure - segmentStart) + 1

	local text = ""

	if Measures[stream_index].isBreak then
		if mods.HideRestCounts == false then

			-- For the RestCount, let the lowest value be an implied 0.
			-- e.g. for an 8 measure break, start at 7, decrement to 1, and don't show
			--      anything for the last measure immediately before the streams begins
			local remaining_rest = current_stream_length - current_count

			-- if we are at RestCount 0 (or we're somehow negative), use an empty string
			-- if the RestCount is somehow greater than the duration of this rest, use an empty string
			if remaining_rest <= 0
			or remaining_rest >= (current_stream_length-1)
			then
				text = ""
			else
				text = "(" .. remaining_rest .. ")"
			end

			-- diffuse Rest counter to be Still Grey, just like Pendulum intended
			bmt:diffuse(0.5,0.5,0.5,1)
		end
	else
		text = tostring(current_count .. "/" .. current_stream_length)
		bmt:diffuse(1,1,1,1)
	end

	return text, current_count > current_stream_length
end


local Update = function(self, delta)

	if not streams.Measures then return end

	-- Things to look into:
	-- Does PlayerState:GetSongPosition() take split timing into consideration?  Do we need to?
	-- This assumes each measure is comprised of exactly 4 beats.  Is it safe to assume this?
	local curr_measure = (math.floor(PlayerState:GetSongPosition():GetSongBeatVisible()))/4

	-- if a new measure has occurred
	if curr_measure > prev_measure then

		prev_measure = curr_measure
		local text, is_end = GetTextForMeasure(curr_measure, streams.Measures, stream_index)

		-- if we're still within the current segment
		if not is_end then
			bmt:settext(text)

		-- we're in a new segment, we should check if curr_measure overlaps with it
		--                                         (what does this^ means? -quietly)
		else
			stream_index = stream_index + 1
			text, is_end = GetTextForMeasure(curr_measure, streams.Measures, stream_index)
			bmt:settext(text)
		end
	end
end

-- I'm not crazy about special-casing Wendy to use
-- _wendy small for the Measure/Rest counter, but
-- I'm hesitant to visually alter a feature that
-- so many players have become so reliant on...
local font = mods.ComboFont
if font == "Wendy" or font == "Wendy (Cursed)" then
	font = "_wendy small"
else
	font = "_Combo Fonts/" .. font .. "/"
end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{
	InitCommand=function(self) self:queuecommand("SetUpdate") end,
	SetUpdateCommand=function(self) self:SetUpdateFunction( Update ) end,

	CurrentSongChangedMessageCommand=function(self)
		InitializeMeasureCounter()
	end,
}

af[#af+1] = LoadFont(font)..{
	InitCommand=function(self)
		-- a reference to this BitmapText actor with file scope
		bmt = self

		self:zoom(0.35):shadowlength(1):horizalign(center)
		self:xy( GetNotefieldX(player), _screen.cy )

		if mods.MeasureCounterLeft then
			local width = GetNotefieldWidth()
			local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
			self:x( GetNotefieldX(player) - (width/NumColumns) )
		end

		if mods.MeasureCounterUp then
			self:y(_screen.cy - 55)
		end
	end
}

return af
