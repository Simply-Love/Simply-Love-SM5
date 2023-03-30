local offsets, worst_window,
      pane_width, pane_height,
		colors, pn = unpack(...)

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

-- sum_timing_error will be used in a loop to sum the total timing error
-- (absolute value) accumulated over the entire stepchart during gameplay
local sum_timing_error = 0
-- we'll divide sum_timing_error by the number of judgments that occured
-- to get the mean timing error
local avg_timing_error = 0

-- sum_timing_offset will be used in a loop to sum the total timing offset
-- accumulated over the entire stepchart during gameplay
local sum_timing_offset = 0
-- the average that a player was shifted by the true 0
local avg_offset = 0
-- the standard deviation of the curve
local std_dev = 0

-- the max error that the a player encountered on any step.
local max_error = 0

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

	-- check if this is the highest error amount
	-- if higher, it's the new max
	if math.abs(k) > max_error then
		max_error = math.abs(k)
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

if #list > 0 then
	-- loop through all offsets collected
	-- take the absolute value (because this offset could be negative)
	-- and add it to the running measure of total timing error
	for i=1,#list do
		sum_timing_offset = sum_timing_offset + list[i]
		sum_timing_error = sum_timing_error + math.abs(list[i])
	end

	-- calculate the mean timing error
	avg_timing_error = sum_timing_error / #list

	-- calculate the mean timing offset
	avg_offset = sum_timing_offset / #list

	-- standard deviation needs at least two values otherwise we'd divide by 0
	if #list > 1 then
		local sum_diff_squared = 0
		for i=1,#list do
			sum_diff_squared = sum_diff_squared + math.pow((list[i] - avg_offset), 2)
		end
		std_dev = math.sqrt(sum_diff_squared / (#list - 1))
	end

	-- convert seconds to ms
	avg_timing_error = avg_timing_error * 1000
	avg_offset = avg_offset * 1000
	std_dev = std_dev * 1000
	max_error = max_error * 1000
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
		local TimingWindow = DetermineTimingWindow(offset)
		c = colors[TimingWindow]
		local prefs = SL.Preferences["FA+"]
		local scale = PREFSMAN:GetPreference("TimingWindowScale")
		local W0 = prefs["TimingWindowSecondsW1"] * scale + prefs["TimingWindowAdd"]
		if SL[pn].ActiveModifiers.SmallerWhite then
			W0 = 0.0085 * scale + prefs["TimingWindowAdd"]
		end
		
		if TimingWindow == 1 and (SL[pn].ActiveModifiers.ShowFaPlusWindow or SL[pn].ActiveModifiers.SmallerWhite) then
			if math.abs(offset) > W0 then
				c = DeepCopy(SL.JudgmentColors["FA+"][2])
			else
				c = DeepCopy(SL.JudgmentColors["FA+"][1])
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
	Text=("%.1fms"):format(std_dev),
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
