local args = ...
local offsets, worst_window = args[1], args[2]
local pane_width, pane_height = args[3], args[4]

-- determine which offset was furthest from flawless prior to smoothing
local worst_offset = 0
for offset, count in pairs(offsets) do
	if math.abs(offset) > worst_offset then worst_offset = math.abs(offset) end
end

-- ---------------------------------------------
-- FIXME: Smoothing the histogram is good overall, but high-level tech players have noted that their
-- Quad Star histograms are wider than they should be.
--
-- Although this feature was designed to help new players establish a sense of timing more quickly
-- (i.e., it was not for high-level players consistently earning Quad Stars), this is a valid observation.
--
-- For now, I'm keeping the smoothing procedure in place, because the graphs new players tend to generate
-- are typically very jagged, causing the intent of the graph (to help) to become lost in the noise.
--
-- Maybe some heuristic can be used to perform the smoothing less naively?
-- For now, consult the dedication in House of Leaves.

-- ---------------------------------------------
-- smooth the offset distribution and store values in a new table, smooth_offsets
local smooth_offsets = {}

-- gaussian distribution for smoothing the histogram's jagged peaks and troughs
local ScaleFactor = { 0.045, 0.090, 0.180, 0.370, 0.180, 0.090, 0.045 }

local y, index
for offset=-worst_window, worst_window, 0.001 do
	offset = round(offset,3)
	y = 0

	-- smooth like butter
	for j=-3,3 do
		index = clamp( offset+(j*0.001), -worst_window, worst_window )
		index = round(index,3)
		if offsets[index] then
			y = y + offsets[index] * ScaleFactor[j+4]
		end
	end

	smooth_offsets[offset] = y
end

-- ---------------------------------------------
-- MEDIAN, MODE, and AVG TIMING ERROR VARIABLES
-- initialize all to zero

-- mode_offset is the offset that occured the most commonly
-- for example, if a player hit notes with an offset of -0.010
-- more commonly than any other offset, that would be the mode
local mode_offset = 0

-- median_offset is the offset in the middle of an ordered list of all offsets
-- 2 is the median in a set of { 1, 1, 2, 3, 4 } because it is in the middle
local median_offset = 0

-- highest_offset_count is how many times the mode_offset occurred
-- we'll use it to scale the histrogram to be an appropriate height
local highest_offset_count = 0

local sum_timing_error = 0
local avg_timing_error = 0

-- ---------------------------------------------
-- OKAY, TIME TO CALCULATE MEDIAN, MODE, and AVG TIMING ERROR

-- find the mode of the collected judgment offsets for this player
-- loop through ALL offsets
for k,v in pairs(offsets) do

	-- compare this particular offset to the current highest_offset
	-- if higher, it's the new mode
	if v > highest_offset_count then
		highest_offset_count = v
		mode_offset = round(k,3)
	end
end

-- transform a key=value table in the format of offset_value=count
-- into an ordered list of offset values
-- this will make calculating the median very straightforward
local list = {}
for offset=-worst_window, worst_window, 0.001 do
	offset = round(offset,3)

	if offsets[offset] then
		for i=1,offsets[offset] do
			list[#list+1] = offset
		end
	end
end

if #list > 0 then

	-- calculate median offset
	if #list % 2 == 1 then
		median_offset = list[math.ceil(#list/2)]
	else
		median_offset = (list[#list/2] + list[#list/2+1])/2
	end

	-- loop throguh all offsets collected
	-- take the absolute value (because this offset could be negative)
	-- and add it to the running measure of total timing error
	for i=1,#list do
		sum_timing_error = sum_timing_error + math.abs(list[i])
	end

	-- calculate the avg timing error, rounded to 3 decimals
	avg_timing_error = round(sum_timing_error/#list,3)
end
-- ---------------------------------------------

-- ---------------------------------------------
-- Calculate vertices for Histogram AMV

local verts = {}

-- total_width of the histogram in offset units
-- take the number of milliseconds in worst_window
-- multiply by 2 (to encompass both negative and positive judgment offsets)
-- multiply by 1000 to get an integer
-- + 1 for the offset of 0.000
local total_width = worst_window * 2 * 1000 + 1

-- w is a ratio of how wide the pane is in pixels
-- to how wide the total TimingWindow interval is in ms
-- so, pixels per ms
local w = pane_width/total_width

-- x and c are variables that will be reused in the loop below
-- x is the x position of this particular histogram bar
-- c is the color of this particular histogram bar
local x, c

local i=1
for offset=-worst_window, worst_window, 0.001 do
	offset = round(offset,3)
	x = i * w
	y = smooth_offsets[offset] or 0

	-- don't bother adding vert data for offsets that were smoothed
	-- beyond whatever the worst_offset actually earned by the player was
	if math.abs(offset) <= worst_offset then
		-- scale the highest point on the histogram to be 0.75 times as high as the pane
		y = -1 * scale(y, 0, highest_offset_count, 0, pane_height*0.75)
		c = SL.JudgmentColors[SL.Global.GameMode][DetermineTimingWindow(offset)]

		-- the ActorMultiVertex is in "QuadStrip" drawmode, like a series of quads placed next to one another
		-- each vertex is a table of two tables:
		-- {x, y, z}, {r, g, b, a}
		verts[#verts+1] = {{x, 0, 0}, c }
		verts[#verts+1] = {{x, y, 0}, c }
	end

	i = i+1
end


-- --------------------------------------------------------
local af = Def.ActorFrame{}

-- --------------------------------------------------------
-- LOOK AT THIS GRAPH

-- the histogram AMV
af[#af+1] = Def.ActorMultiVertex{
	Name="ModeJudgmentOffset_AMV",
	OnCommand=function(self)
		self:SetDrawState{Mode="DrawMode_QuadStrip"}
			:SetVertices(verts)
	end
}

-- --------------------------------------------------------
-- avg_timing_error value
af[#af+1] = Def.BitmapText{
	Font="_miso",
	Text=(avg_timing_error*1000).."ms",
	InitCommand=function(self)
		self:x(40):y(-pane_height+32)
			:zoom(0.8)
	end,
}

-- median_offset value
af[#af+1] = Def.BitmapText{
	Font="_miso",
	Text=(median_offset*1000).."ms",
	InitCommand=function(self)
		self:x(pane_width/2):y(-pane_height+32)
			:zoom(0.8)
	end,
}

-- mode_offset value
af[#af+1] = Def.BitmapText{
	Font="_miso",
	Text=(mode_offset*1000).."ms",
	InitCommand=function(self)
		self:x(pane_width-40):y(-pane_height+32)
			:zoom(0.8)
	end,
}

return af