local pn, offsets, worst_window, pane_width, pane_height, colors,
		sum_timing_error, avg_timing_error,
		sum_timing_offset, avg_offset, std_dev, max_error = unpack(...)
local mods = SL[pn].ActiveModifiers

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

-- highest_offset_count is how many times the mode_offset occurred
-- we'll use it to scale the histogram to be an appropriate height
local highest_offset_count = 0

-- ---------------------------------------------
-- OKAY, TIME TO CALCULATE MEDIAN, MODE, and AVG TIMING ERROR

-- find the mode of the collected judgment offsets for this player
-- loop through ALL offsets
for k,v in pairs(offsets) do

	-- compare this particular offset to the current highest_offset
	-- if higher, it's the new mode
	if v > highest_offset_count then
		highest_offset_count = v
	end
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

		c = colors[DetermineTimingWindow(offset)]

		if mods.ShowFaPlusPane then
			abs_offset = math.abs(offset)
			if abs_offset > GetTimingWindow(1, "FA+") and abs_offset <= GetTimingWindow(2, "FA+") then
				c = SL.JudgmentColors["FA+"][2]
			end
		end

		-- the ActorMultiVertex is in "QuadStrip" drawmode, like a series of quads placed next to one another
		-- each vertex is a table of two tables:
		-- {x, y, z}, {r, g, b, a}
		verts[#verts+1] = {{x, 0, 0}, c }
		verts[#verts+1] = {{x, y, 0}, c }
	end

	i = i+1
end


-- ---------------------------------------------
local af = Def.ActorFrame{}

-- ---------------------------------------------
-- LOOK AT THIS GRAPH

-- the histogram AMV
af[#af+1] = Def.ActorMultiVertex{
	Name="ModeJudgmentOffset_AMV",
	OnCommand=function(self)
		self:SetDrawState{Mode="DrawMode_QuadStrip"}
			:SetVertices(verts)
	end
}

-- ---------------------------------------------
-- BitmapText actors for text
local bmts = Def.ActorFrame{}
bmts.InitCommand=function(self) self:y(-pane_height+32) end
local pad = 40

-- avg_timing_error value with "ms" label
bmts[#bmts+1] = Def.BitmapText{
	Font="Common Normal",
	Text=("%.1fms"):format(avg_timing_error),
	InitCommand=function(self)
		self:x(pad):zoom(0.8)
	end,
}

-- avg_offset value with "ms" label
bmts[#bmts+1] = Def.BitmapText{
	Font="Common Normal",
	Text=("%.1fms"):format(avg_offset),
	InitCommand=function(self)
		self:x(pad + (pane_width-2*pad)/3):zoom(0.8)
	end,
}

-- std_dev value with "ms" label
bmts[#bmts+1] = Def.BitmapText{
	Font="Common Normal",
	Text=("%.1fms"):format(std_dev * 3),
	InitCommand=function(self)
		self:x(pad + (pane_width-2*pad)/3 * 2):zoom(0.8)
	end,
}

-- max_error value with "ms" label
bmts[#bmts+1] = Def.BitmapText{
	Font="Common Normal",
	Text=("%.1fms"):format(max_error),
	InitCommand=function(self)
		self:x(pane_width-pad):zoom(0.8)
	end,
}

-- add bmts ActorFrame to overall ActorFrame
af[#af+1] = bmts

-- ---------------------------------------------

-- return overall ActorFrame
return af
