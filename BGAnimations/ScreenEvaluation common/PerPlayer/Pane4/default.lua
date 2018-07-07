local player = ...
local pn = ToEnumShortString(player)

-- table of offet values obtained during this song's playthrough
-- obtained via ./BGAnimations/ScreenGameplay overlay/JudgmentOffsetTracking.lua
local sequential_offsets = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].sequential_offsets
local pane_width, pane_height = 300, 180

-- ---------------------------------------------

local abbreviations = {
	Competitive = { "Fan", "Ex", "Gr", "Dec", "WO" },
	ECFA = { "Fan", "Fan", "Ex", "Gr", "Dec" },
	StomperZ = { "Perf", "Gr", "Good", "Hit", "" }
}

-- ---------------------------------------------
-- if players have disabled W4 or W4+W5, there will be a smaller pool
-- of judgments that could have possibly been earned
local num_judgments_available = (SL.Global.ActiveModifiers.DecentsWayOffs=="Decents Only" and 4) or (SL.Global.ActiveModifiers.DecentsWayOffs=="Off" and 3) or 5
local worst_window = SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..num_judgments_available]

-- ---------------------------------------------
-- sequential_offsets is a table of all timing offsets in the order they were earned.
-- The sequence is important for the Scatter Plot, but irrelevant here; we are only really
-- interested in how many +0.001 offsets were earned, how many -0.001, how many +0.002, etc.
-- So, we loop through sequential_offsets, and tally offset counts into a new offsets table.
local offsets = {}
local val

for t in ivalues(sequential_offsets) do
	-- the first value in t is CurrentMusicSeconds when the offset occurred, which we don't need here
	-- the second value in t is the offset value or the string "Miss"
	val = t[2]

	if val ~= "Miss" then
		val = (math.floor(val*1000))/1000

		if not offsets[val] then
			offsets[val] = 1
		else
			offsets[val] = offsets[val] + 1
		end
	end
end

-- ---------------------------------------------
-- next, smooth the offset distribution and store values in a new table, smooth_offsets
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

	-- scale the highst point on the histogram to be 0.75 times as high as the pane
	y = -1 * scale(y, 0, highest_offset_count, 0, pane_height*0.75)
	c = SL.JudgmentColors[SL.Global.GameMode][DetermineTimingWindow(offset)]

	-- the ActorMultiVertex is in "QuadStrip" drawmode, like a series of quads places next to one another
	-- each vertex is a table of two tables:
	-- {x, y, z}, {r, g, b, a}
	verts[#verts+1] = {{x, 0, 0}, c }
	verts[#verts+1] = {{x, y, 0}, c }

	i = i+1
end
-- ---------------------------------------------

-- ---------------------------------------------
-- Actors

local pane = Def.ActorFrame{
	Name="Pane4",
	InitCommand=function(self)
		self:visible(false)
			:xy(-pane_width*0.5, pane_height*1.95)
	end
}

-- "Early" text
pane[#pane+1] = Def.BitmapText{
	Font="_wendy small",
	Text=ScreenString("Early"),
	InitCommand=function(self)
		self:addx(10):addy(-125)
			:zoom(0.3)
			:horizalign(left)
	end,
}

-- "Late" text
pane[#pane+1] = Def.BitmapText{
	Font="_wendy small",
	Text=ScreenString("Late"),
	InitCommand=function(self)
		self:addx(pane_width-10):addy(-125)
			:zoom(0.3)
			:horizalign(right)
	end,
}


-- darkened quad behind bottom judment labels
pane[#pane+1] = Def.Quad{
	InitCommand=function(self)
		self:vertalign(top)
			:zoomto(pane_width, 13 )
			:xy(pane_width/2, 0)
			:diffuse(color("#101519"))
	end,
}


-- centered text for W1
pane[#pane+1] = Def.BitmapText{
	Font="_miso",
	Text=abbreviations[SL.Global.GameMode][1],
	InitCommand=function(self)
		local x = pane_width/2

		self:diffuse( SL.JudgmentColors[SL.Global.GameMode][1] )
			:addx(x):addy(7)
			:zoom(0.65)
	end,
}

-- loop from W2 to the worst_window and add judgment text
-- underneath that portion of the histogram
for i=2,num_judgments_available do

	-- early (left) judgment text
	pane[#pane+1] = Def.BitmapText{
		Font="_miso",
		Text=abbreviations[SL.Global.GameMode][i],
		InitCommand=function(self)
			local window = -1 * SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..i]
			local better_window = -1 * SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..i-1]

			local x = scale(window, -worst_window, worst_window, 0, pane_width )
			local x_better = scale(better_window, -worst_window, worst_window, 0, pane_width)
			local x_avg = (x+x_better)/2

			self:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
				:addx(x_avg):addy(7)
				:zoom(0.65)
		end,
	}

	-- late (right) judgment text
	pane[#pane+1] = Def.BitmapText{
		Font="_miso",
		Text=abbreviations[SL.Global.GameMode][i],
		InitCommand=function(self)
			local window = SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..i]
			local better_window = SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..i-1]

			local x = scale(window, -worst_window, worst_window, 0, pane_width )
			local x_better = scale(better_window, -worst_window, worst_window, 0, pane_width)
			local x_avg = (x+x_better)/2

			self:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
				:addx(x_avg):addy(7)
				:zoom(0.65)
		end,
	}

end

-- --------------------------------------------------------
-- LOOK AT THIS GRAPH

-- the histogram AMV
pane[#pane+1] = Def.ActorMultiVertex{
	Name="ModeJudgmentOffset_AMV",
	OnCommand=function(self)
		self:SetDrawState{Mode="DrawMode_QuadStrip"}
			:SetVertices(verts)
	end
}
-- --------------------------------------------------------

-- the line in the middle indicating where truly flawless timing (0ms offset) is
pane[#pane+1] = Def.Quad{
	InitCommand=function(self)
		local x = pane_width/2

		self:vertalign(top)
			:zoomto(1, pane_height - 40 )
			:xy(x, -140)
			:diffuse(1,1,1,0.666)

		if SL.Global.GameMode == "StomperZ" then
			self:diffuse(0,0,0,0.666)
		end
	end,
}

-- --------------------------------------------------------
-- TOPBAR WITH STATISTICS

-- topbar background quad
pane[#pane+1] = Def.Quad{
	InitCommand=function(self)
		self:vertalign(top)
			:zoomto(pane_width, 26 )
			:xy(pane_width/2, -pane_height+13)
			:diffuse(color("#101519"))
	end,
}

-- avg_timing_error label
pane[#pane+1] = Def.BitmapText{
	Font="_miso",
	Text=ScreenString("MeanTimingError"),
	InitCommand=function(self)
		self:x(40):y(-pane_height+20)
			:zoom(0.575)
	end,
}

-- avg_timing_error value
pane[#pane+1] = Def.BitmapText{
	Font="_miso",
	Text=(avg_timing_error*1000).."ms",
	InitCommand=function(self)
		self:x(40):y(-pane_height+32)
			:zoom(0.8)
	end,
}


-- median_offset label
pane[#pane+1] = Def.BitmapText{
	Font="_miso",
	Text=ScreenString("Median"),
	InitCommand=function(self)
		self:x(pane_width/2):y(-pane_height+20)
			:zoom(0.575)
	end,
}

-- median_offset value
pane[#pane+1] = Def.BitmapText{
	Font="_miso",
	Text=(median_offset*1000).."ms",
	InitCommand=function(self)
		self:x(pane_width/2):y(-pane_height+32)
			:zoom(0.8)
	end,
}

-- mode_offset label
pane[#pane+1] = Def.BitmapText{
	Font="_miso",
	Text=ScreenString("Mode"),
	InitCommand=function(self)
		self:x(pane_width-40):y(-pane_height+20)
			:zoom(0.575)
	end,
}

-- mode_offset value
pane[#pane+1] = Def.BitmapText{
	Font="_miso",
	Text=(mode_offset*1000).."ms",
	InitCommand=function(self)
		self:x(pane_width-40):y(-pane_height+32)
			:zoom(0.8)
	end,
}


return pane