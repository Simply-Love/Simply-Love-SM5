local player = ...
local pn = ToEnumShortString(player)

-- table of offet values obtained during this song's playthrough
-- obtained via ./BGAnimations/ScreenGameplay overlay/JudgmentOffsetTracking.lua
local offsets = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].timing_offsets
local pane_width, pane_height = 300, 180

-- ---------------------------------------------

local colors = {
	Competitive = {
		color("#21CCE8"),	-- blue
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#5b2b8e"),	-- purple
		color("#c9855e"),	-- peach?
		color("#ff0000")	-- red
	},
	ECFA = {
		color("#21CCE8"),	-- blue
		color("#ffffff"),	-- white
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#5b2b8e"),	-- purple
		color("#ff0000")	-- red
	},
	StomperZ = {
		color("#FFFFFF"),	-- white
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#21CCE8"),	-- blue
		color("#000000"),	-- black
		color("#ff0000")	-- red
	}
}

local abbreviations = {
	Competitive = { "Fan", "Ex", "Gr", "Dec", "WO" },
	ECFA = { "Fan", "Fan", "Ex", "Gr", "Dec" },
	StomperZ = { "Perf", "Perf", "Gr", "Good", "" }
}

-- ---------------------------------------------
-- helper function used to detmerine which timing_window a particular offset belongs to
local DetermineTimingWindow = function(offset)
	for i=1,5 do
		if math.abs(offset) < SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..i] then
			return i
		end
	end
	return 5
end
-- ---------------------------------------------
-- if players have disabled W4 or W4+W5, there will be a smaller pool
-- of judgments that could have possibly been earned
local num_judgments_available = (SL.Global.ActiveModifiers.DecentsWayOffs=="Decents Only" and 4) or (SL.Global.ActiveModifiers.DecentsWayOffs=="Off" and 3) or 5
local worst_window = SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..num_judgments_available]

-- ---------------------------------------------
-- first, smooth the offset distribution and store values in a new table, smooth_offsets
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


-- find the mode of the collected judgment offsets for this player
-- and save how many times that particular offset occurred
local highest_offset_count = 0
local mode_offset = 0

for k,v in pairs(smooth_offsets) do
	if v > highest_offset_count then
		highest_offset_count = v
		mode_offset = k
	end
end
-- ---------------------------------------------

-- ---------------------------------------------
-- Calculate vertices for Histogram AMV

local verts = {}

-- total_width of the histogram
-- take the number of milliseconds in worst_window
-- multiply by 2 (to encompass both negative and positive judgment offsets)
-- and multiply by 1000 to get an integer
-- + 1 for the offset of 0.000
local total_width = worst_window * 2 * 1000 + 1
local w = pane_width/total_width
local x, c

local i=1
for offset=-worst_window, worst_window, 0.001 do
	offset = round(offset,3)
	x = i * w
	y = smooth_offsets[offset] or 0

	y = -1 * scale(y, 0, highest_offset_count, 0, pane_height*0.75)
	c = colors[SL.Global.GameMode][DetermineTimingWindow(offset)]

	verts[#verts+1] = {{x, 0, 0}, c, {1,1}}
	verts[#verts+1] = {{x, y, 0}, c, {0,0}}

	i = i+1
end


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
		self:addx(50):addy(-146)
			:zoom(0.4)
	end,
}

-- "Late" text
pane[#pane+1] = Def.BitmapText{
	Font="_wendy small",
	Text=ScreenString("Late"),
	InitCommand=function(self)
		self:addx(250):addy(-146)
			:zoom(0.4)
	end,
}

-- centered text for W1
pane[#pane+1] = Def.BitmapText{
	Font="_miso",
	Text=abbreviations[SL.Global.GameMode][1],
	InitCommand=function(self)
		local x = scale(0, -worst_window, worst_window, 0, pane_width )

		self:diffuse( colors[SL.Global.GameMode][1] )
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

			self:diffuse( colors[SL.Global.GameMode][i] )
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

			self:diffuse( colors[SL.Global.GameMode][i] )
				:addx(x_avg):addy(7)
				:zoom(0.65)
		end,
	}

end

-- the line dropping down from the mode_offset text
pane[#pane+1] = Def.Quad{
	InitCommand=function(self)
		local x = scale(mode_offset, -worst_window, worst_window, 0, pane_width )

		self:zoomto(1, pane_height/2)
			:vertalign(bottom)
			:addx(x):addy(-pane_height/2 + 42)
			:diffuseshift():effectperiod(1.5):effectcolor1(Color.White):effectcolor2(Color.Black)
	end,
}

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
-- THINGS DRAWN OVER THE HISTOGRAM BELOW THIS COMMENT

-- the line in the middle indicating where truly flawless timing (0ms offset) is
pane[#pane+1] = Def.Quad{
	InitCommand=function(self)
		local x = scale(0, -worst_window, worst_window, 0, pane_width )

		self:zoomto(1, pane_height - 14 )
			:addx(x):y(-83)

		if SL.Global.GameMode == "StomperZ" then
			self:diffuse(Color.Black)
		end
	end,
}

-- mode_offset text
pane[#pane+1] = Def.BitmapText{
	Font="_miso",
	Text=(mode_offset*1000).."ms",
	InitCommand=function(self)
		local x = scale(mode_offset, -worst_window, worst_window, 0, pane_width )

		self:horizalign(center)
			:addx(x):addy(-pane_height+36)
			:zoom(0.75)
			:diffuseshift():effectperiod(1.5):effectcolor1(Color.White):effectcolor2(Color.Black)
	end,
}


return pane