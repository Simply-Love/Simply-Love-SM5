local player, ssY, layout = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local so = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")

-- don't allow MeasureCounter to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual"
or not mods.MeasureCounter
or not mods.RunTimer
or mods.MeasureCounter == "None" then
	return
end

-- -----------------------------------------------------------------------

local PlayerState = GAMESTATE:GetPlayerState(player)
local streams, prevMeasure, streamIndex
-- Collection of the BitmapText actors used for the measure counters.
local bmt = {}

-- How many streams to "look ahead"
local lookAhead = 0
-- If you want to see more than 2 counts in advance, change the 2 to a larger value.
-- Making the value very large will likely impact fps. -quietly


-- We'll want to reset each of these values for each new song in the case of CourseMode
local InitializeMeasureCounter = function()
	-- SL[pn].Streams is initially set (and updated in CourseMode)
	-- in ./ScreenGameplay in/MeasureCounterAndModsLevel.lua
	streams = SL[pn].Streams
	streamIndex = 1
	prevMeasure = -1

	for actor in ivalues(bmt) do
		actor:visible(true)
	end
end

-- Returns whether or not we've reached the end of this stream segment.
local IsEndOfStream = function(currMeasure, Measures, streamIndex)
	if Measures[streamIndex] == nil then return false end

	-- a "segment" can be either stream or rest
	local segmentStart = Measures[streamIndex].streamStart
	local segmentEnd   = Measures[streamIndex].streamEnd

	local currStreamLength = segmentEnd - segmentStart
	local currCount = math.ceil(currMeasure - segmentStart)

	return currCount > currStreamLength
end

local GetTimeRemaining = function(currBeat, Measures, streamIndex)
	if Measures[streamIndex] == nil then return "" end

	MusicRate = so:MusicRate()

	-- a "segment" can be either stream or rest
	local measureSeconds = 4 / (PlayerState:GetSongPosition():GetCurBPS() * MusicRate)
	local segmentStart = Measures[streamIndex].streamStart 
	local segmentEnd   = Measures[streamIndex].streamEnd
	
	if mods.TimerMode == "Time" then
		local currTime = currBeat / (PlayerState:GetSongPosition():GetCurBPS() * MusicRate)

		local currStreamLength = math.ceil((segmentEnd - segmentStart) * measureSeconds)
		local showTotal = "0." .. currStreamLength
		if currStreamLength < 10 then
			showTotal = "0.0" .. currStreamLength
		elseif currStreamLength > 60 then
			local minutes = math.floor(currStreamLength / 60)
			local seconds = currStreamLength % 60
			if seconds < 10 then
				seconds = "0" .. seconds
			end
			showTotal = minutes .. "." .. seconds
		end
		local currRemaining = math.max(math.ceil(segmentEnd * measureSeconds - currTime), 0)
		local showRemaining = "0." .. currRemaining
		if currRemaining < 10 then
			showRemaining = "0.0" .. currRemaining
		elseif currRemaining > 59 then
			local minutes = math.floor(currRemaining / 60)
			local seconds = currRemaining % 60
			if seconds < 10 then
				seconds = "0" .. seconds
			end
			showRemaining = minutes .. "." .. seconds
		end

		if currRemaining > currStreamLength then
			return showTotal
		elseif currRemaining < 1 then
			return "0.00 "
		end
		
		return (showRemaining) .. " "
	elseif mods.TimerMode == "Measures" then
		local currStreamLength = math.ceil(segmentEnd - segmentStart)
		local currRemaining = math.max(math.ceil(segmentEnd - currBeat / 4), 0)
		
		if currRemaining > currStreamLength then
			return currStreamLength
		elseif currRemaining < 1 then
			return 0 .. " "
		end
		return currRemaining .. " "
	end
	
end

local Update = function(self, delta)
	-- Check to make sure we even have any streams populated to display.
	if not streams.Measures or #streams.Measures == 0 then return end

	-- Things to look into:
	-- 1. Does PlayerState:GetSongPosition() take split timing into consideration?  Do we need to?
	-- 2. This assumes each measure is comprised of exactly 4 beats.  Is it safe to assume this?
	local currMeasure = (math.floor(PlayerState:GetSongPosition():GetSongBeatVisible()))/4
	local currBeat = PlayerState:GetSongPosition():GetSongBeat()
	

	-- If a new measure has occurred
	if currMeasure > prevMeasure then
		prevMeasure = currMeasure

		-- If we've reached the end of the stream, we want to get values for the next stream.
		if IsEndOfStream(currMeasure, streams.Measures, streamIndex) then
			streamIndex = streamIndex + 1
		end

		for i=1,lookAhead+1 do
			local remaining = GetTimeRemaining(currBeat, streams.Measures, streamIndex)
			-- Only the first one is the main counter, the other ones are lookaheads.
			local isLookAhead = i ~= 1
			-- We're looping forwards, but the BMTs are indexed in the opposite direction.
			-- Adjust indices accordingly.
			local adjustedIndex = lookAhead+2-i
			local text = remaining and remaining or ""
			bmt[adjustedIndex]:settext(text)
			
			-- We can hit nil when we've run out of streams/breaks for the song. Just hide these BMTs.
			if streams.Measures[streamIndex + i - 1] == nil then
				bmt[adjustedIndex]:visible(false)

			-- rest count
			elseif streams.Measures[streamIndex + i - 1].isBreak then
				-- Make rest lookaheads be lighter than active rests.
				if not isLookAhead then
					bmt[adjustedIndex]:diffuse(0.5, 0.5, 0.5 ,0)
				else
					bmt[adjustedIndex]:diffuse(0.4, 0.4, 0.4 ,0)
				end

			-- stream count
			else
				-- Make stream lookaheads be lighter than active streams.
				if not isLookAhead then
					if string.find(text, " ") then
						bmt[adjustedIndex]:diffuse(1, 1, 1, 1)
					else
						-- If this is a mini-break, make it lighter.
						bmt[adjustedIndex]:diffuse(0.5, 0.5, 0.5 ,1)
					end
				else
					bmt[adjustedIndex]:diffuse(0.45, 0.45, 0.45 , 1)
				end
			end
		end
	end
end

-- I'm not crazy about special-casing "Wendy" to use
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
	InitCommand=function(self)
		self:xy(GetNotefieldX(player), ssY)
		self:queuecommand("SetUpdate")
	end,
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
			if mods.MeasureCounterLeft then
				columnWidth = columnWidth*4/3
			end

			-- Have descending zoom sizes for each new BMT we add.
			self:zoom(0.35 - 0.05 * (i-1)):shadowlength(1):horizalign(center)
			self:x(columnWidth/mods.MeasureCounterLookahead*2 * (i-1))

			if mods.MeasureCounterLeft then
				self:addx(-columnWidth)
			end
		end
	}
end

return af
