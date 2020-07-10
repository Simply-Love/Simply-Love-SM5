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
local streams, prevMeasure, streamIndex
-- Collection of the BitmapTextures used for the measure counters.
local bmt = {}
-- How many streams to "look ahead"
local lookAhead = 2

-- We'll want to reset each of these values for each new song in the case of CourseMode
local InitializeMeasureCounter = function()
	-- SL[pn].Streams is initially set (and updated in CourseMode)
	-- in ./ScreenGameplay in/MeasureCounterAndModsLevel.lua
	streams = SL[pn].Streams
	streamIndex = 1
	prevMeasure = -1
end

-- Returns whether or not we've reached the end of this stream segment.
local IsEndOfStream = function(currMeasure, Measures, streamIndex)
	if Measures[streamIndex] == nil then return false end

	-- a "segment" can be either stream or rest
	local segmentStart = Measures[streamIndex].streamStart
	local segmentEnd   = Measures[streamIndex].streamEnd

	local currStreamLength = segmentEnd - segmentStart
	local currCount = math.floor(currMeasure - segmentStart) + 1

	return currCount > currStreamLength
end

local GetTextForMeasure = function(currMeasure, Measures, streamIndex, isLookAhead)
	if Measures[streamIndex] == nil then return "" end
	-- Don't display final count if it's a break.
	if streamIndex == #Measures and Measures[streamIndex].isBreak then return "" end

	-- A "segment" can be either stream or rest
	local segmentStart = Measures[streamIndex].streamStart
	local segmentEnd   = Measures[streamIndex].streamEnd

	local currStreamLength = segmentEnd - segmentStart
	local currCount = math.floor(currMeasure - segmentStart) + 1

	local text = ""
	if Measures[streamIndex].isBreak then
		if mods.HideRestCounts == false then
			if not isLookAhead then
				local remainingRest = currStreamLength - currCount + 1

				-- Ensure that the rest count is in range of the total length.
				text = "(" .. remainingRest .. ")"
			else
				text = "(" .. currStreamLength .. ")"
			end
		end
	else
		if not isLookAhead then
			text = tostring(currCount .. "/" .. currStreamLength)		
		else
			text = tostring(currStreamLength)
		end	
	end
	return text
end

local Update = function(self, delta)
	-- Check to make sure we even have any streams populated to display.
	if not streams.Measures or #streams.Measures == 0 then return end

	-- Things to look into:
	-- Does PlayerState:GetSongPosition() take split timing into consideration?  Do we need to?
	-- This assumes each measure is comprised of exactly 4 beats.  Is it safe to assume this?
	local currMeasure = (math.floor(PlayerState:GetSongPosition():GetSongBeatVisible()))/4

	-- If a new measure has occurred
	if currMeasure > prevMeasure then
		prevMeasure = currMeasure

		-- If we've reached the end of the stream, we want to get values for the next stream.
		if IsEndOfStream(currMeasure, streams.Measures, streamIndex) then
			streamIndex = streamIndex + 1
		end

		for i=1,lookAhead+1 do
			-- Only the first one is the main counter, the other ones are lookaheads.
			local isLookAhead = i ~= 1
			-- We're looping forwards, but the BMTs are indexed in the opposite direction.
			-- Adjust indices accordingly.
			local adjustedIndex = lookAhead+2-i
			local text = GetTextForMeasure(currMeasure, streams.Measures, streamIndex + i - 1, isLookAhead)
			bmt[adjustedIndex]:settext(text)
			-- We can hit nil when we've run out of streams/breaks for the song. Just hide these BMTs.
			if streams.Measures[streamIndex + i - 1] == nil then
				bmt[adjustedIndex]:visible(false)
			elseif streams.Measures[streamIndex + i - 1].isBreak then
				-- Make the lookaheads be lighter than their main counterparts.
				if not isLookAhead then
					bmt[adjustedIndex]:diffuse(0.5, 0.5, 0.5 ,1)
				else
					bmt[adjustedIndex]:diffuse(0.3, 0.3, 0.3 ,1)
				end
			else
				-- Make the lookaheads be lighter than their main counterparts.
				if not isLookAhead then
					bmt[adjustedIndex]:diffuse(1, 1, 1, 1)
				else
					bmt[adjustedIndex]:diffuse(0.8, 0.8, 0.8 ,1)
				end
			end
		end
	end
end

-- I'm not crazy about special-casing Wendy to use
-- _wendy small for the Measure/Rest counter, but
-- I'm hesitant to visually alter a feature that
-- so many players have become so reliant on...
local font = mods.ComboFont
if font == "Wendy" or font == "Wendy (Cursed)" then
	font = "Wendy/_wendy small"
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

-- We iterate backwards since we want the lookaheads to be drawn first in the case the
-- main measure counter expands into them.
for i=lookAhead+1,1,-1 do
	af[#af+1] = LoadFont(font)..{
		InitCommand=function(self)
			-- Add to the collection of BMTs so our AF's update function can easily access them.
			bmt[#bmt+1] = self

			local width = GetNotefieldWidth()
			local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
			local columnWidth = width/NumColumns

			-- Have descending zoom sizes for each new BMT we add.
			self:zoom(0.35 - 0.05 * (i-1)):shadowlength(1):horizalign(center)
			self:xy(GetNotefieldX(player) + columnWidth * (0.7 * (i-1)), _screen.cy)

			if mods.MeasureCounterLeft then
				self:addx(-columnWidth)
			end

			if mods.MeasureCounterUp then
				self:addy(-55)
			end
		end
	}
end

return af