-- Pane5 displays an aggregate histogram of judgment offsets
-- as well as the mean timing error, median, and mode of those offsets.

local player, _, ComputedData = unpack(...)
local pn = ToEnumShortString(player)

-- table of offset values obtained during this song's playthrough
-- obtained via ./BGAnimations/ScreenGameplay overlay/JudgmentOffsetTracking.lua
local sequential_offsets = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].sequential_offsets
local pane_width, pane_height = 300, 180
local topbar_height = 26
local bottombar_height = 13

-- Determine timing windows that need to be covered in the histogram based on worst judgment hit during gameplay
local num_judgments_available = math.max(3, GetWorstJudgment(sequential_offsets))
local worst_window = GetTimingWindow(num_judgments_available)

-- ---------------------------------------------

local abbreviations = {
	ITG = { "Fan", "Ex", "Gr", "Dec", "WO" },
	["FA+"] = { "Fan", "Fan", "Ex", "Gr", "Dec" },
}

local colors = {}
for w=num_judgments_available,1,-1 do
	if SL[pn].ActiveModifiers.TimingWindows[w]==true then
		colors[w] = DeepCopy(SL.JudgmentColors[SL.Global.GameMode][w])
	else
		abbreviations[SL.Global.GameMode][w] = abbreviations[SL.Global.GameMode][w+1]
		colors[w] = DeepCopy(colors[w+1] or SL.JudgmentColors[SL.Global.GameMode][w+1])
	end
end

-- ---------------------------------------------
-- sequential_offsets is a table of all timing offsets in the order they were earned.
-- The sequence is important for the Scatter Plot, but irrelevant here; we are only really
-- interested in how many +0.001 offsets were earned, how many -0.001, how many +0.002, etc.
-- So, we loop through sequential_offsets, and tally offset counts into a new offsets table.
local offsets = {}
local sum_timing_error = 0
local avg_timing_error = 0
local sum_timing_offset = 0
local avg_offset = 0
local std_dev = 0
local max_error = 0
local count = 0

local max_error = 0 -- Temporary fix for non rounded max error until mainline SL fixes it

for t in ivalues(sequential_offsets) do
	-- the first value in t is CurrentMusicSeconds when the offset occurred, which we don't need here
	-- the second value in t is the offset value or the string "Miss"
	local val = t[2]

	if val ~= "Miss" then
		count = count + 1

		-- check if this is the highest error amount
		-- if higher, it's the new max
		if math.abs(val) > max_error then
			max_error = math.abs(val)
		end

		sum_timing_offset = sum_timing_offset + val
		sum_timing_error = sum_timing_error + math.abs(val)

		val = (math.floor(val*1000))/1000

		if not offsets[val] then
			offsets[val] = 1
		else
			offsets[val] = offsets[val] + 1
		end
	end
end

if count > 0 then
	avg_timing_error = sum_timing_error / count
	avg_offset = sum_timing_offset / count
	-- standard deviation needs at least two values otherwise we'd divide by 0
	if count > 1 then
		local sum_diff_squared = 0
		for t in ivalues(sequential_offsets) do
			local val = t[2]
			if val ~= "Miss" then
				sum_diff_squared = sum_diff_squared + math.pow((val - avg_offset), 2)
			end
		end
		std_dev = math.sqrt(sum_diff_squared / (count - 1))
	end

	-- convert seconds to ms
	avg_timing_error = avg_timing_error * 1000
	avg_offset = avg_offset * 1000
	std_dev = std_dev * 1000
	max_error = max_error * 1000
end

-- ---------------------------------------------
-- Actors

local pane = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(-pane_width*0.5, pane_height*1.95)
	end
}

-- the line in the middle indicating where truly flawless timing (0ms offset) is
pane[#pane+1] = Def.Quad{
	InitCommand=function(self)
		local x = pane_width/2

		self:vertalign(top)
			:zoomto(1, pane_height - (topbar_height+bottombar_height) )
			:vertalign(bottom):xy(x, 0)
			:diffuse(1,1,1,0.666)
	end,
}

-- "Early" text
pane[#pane+1] = Def.BitmapText{
	Font=ThemePrefs.Get("ThemeFont") .. " Bold",
	Text=ScreenString("Early"),
	InitCommand=function(self)
		self:addx(10):addy(-125)
			:zoom(0.3)
			:horizalign(left)
		if ThemePrefs.Get("VisualStyle") == "Technique" then
			self:diffusealpha(0.5)
		end
	end,
}

-- "Late" text
pane[#pane+1] = Def.BitmapText{
	Font=ThemePrefs.Get("ThemeFont") .. " Bold",
	Text=ScreenString("Late"),
	InitCommand=function(self)
		self:addx(pane_width-10):addy(-125)
			:zoom(0.3)
			:horizalign(right)
	end,
}

-- --------------------------------------------------------

-- darkened quad behind bottom judgment labels
pane[#pane+1] = Def.Quad{
	InitCommand=function(self)
		self:vertalign(top)
			:zoomto(pane_width, bottombar_height )
			:xy(pane_width/2, 0)
			:diffuse(color("#101519"))
		if ThemePrefs.Get("VisualStyle") == "Technique" then
			self:diffusealpha(0.5)
		end
	end,
}

-- centered text for W1
pane[#pane+1] = Def.BitmapText{
	Font=ThemePrefs.Get("ThemeFont") .. " Normal",
	Text=abbreviations[SL.Global.GameMode][1],
	InitCommand=function(self)
		local x = pane_width/2

		self:diffuse( colors[1] )
			:addx(x):addy(7)
			:zoom(0.65)
	end,
}

-- loop from W2 to the worst_window and add judgment text
-- underneath that portion of the histogram
for i=2,num_judgments_available do

	-- early (left) judgment text
	pane[#pane+1] = Def.BitmapText{
		Font=ThemePrefs.Get("ThemeFont") .. " Normal",
		Text=abbreviations[SL.Global.GameMode][i],
		InitCommand=function(self)
			local window = -1 * GetTimingWindow(i)
			local better_window = -1 * GetTimingWindow(i - 1)

			local x = scale(window, -worst_window, worst_window, 0, pane_width )
			local x_better = scale(better_window, -worst_window, worst_window, 0, pane_width)
			local x_avg = (x+x_better)/2

			self:diffuse( colors[i] )
				:addx(x_avg):addy(7)
				:zoom(0.65)
			-- Hide the text if it's the same as the previous window.
			if abbreviations[SL.Global.GameMode][i] == abbreviations[SL.Global.GameMode][i-1] then
				self:visible(false)
			end
		end,
	}

	-- late (right) judgment text
	pane[#pane+1] = Def.BitmapText{
		Font=ThemePrefs.Get("ThemeFont") .. " Normal",
		Text=abbreviations[SL.Global.GameMode][i],
		InitCommand=function(self)
			local window = GetTimingWindow(i)
			local better_window = GetTimingWindow(i - 1)

			local x = scale(window, -worst_window, worst_window, 0, pane_width )
			local x_better = scale(better_window, -worst_window, worst_window, 0, pane_width)
			local x_avg = (x+x_better)/2

			self:diffuse( colors[i] )
				:addx(x_avg):addy(7)
				:zoom(0.65)
			-- Hide the text if it's the same as the previous window.
			if abbreviations[SL.Global.GameMode][i] == abbreviations[SL.Global.GameMode][i-1] then
				self:visible(false)
			end
		end,
	}

end

-- --------------------------------------------------------
-- TOPBAR feat. mean timing error, median, mode, and Ryu☆

-- topbar background quad
pane[#pane+1] = Def.Quad{
	InitCommand=function(self)
		self:vertalign(top)
			:zoomto(pane_width, topbar_height )
			:xy(pane_width/2, -pane_height + topbar_height/2)
			:diffuse(color("#101519"))
		if ThemePrefs.Get("VisualStyle") == "Technique" then
			self:diffusealpha(0.5)
		end
	end,
}

-- only bother crunching the numbers and adding extra BitmapText actors if there are
-- valid offset values to analyze; (MISS has no numerical offset and can't be analyzed)
if next(offsets) ~= nil then

	local histogram
	-- don't re-run the calculations if only one player is joined
	-- and we've already run them for a previous pane
	if ComputedData and ComputedData.Histogram then
		histogram = ComputedData.Histogram
	else
		histogram = LoadActor(
				"./Calculations.lua",
				{
					pn,
					offsets,
					worst_window,
					pane_width,
					pane_height,
					colors,
					sum_timing_error,
					avg_timing_error,
					sum_timing_offset,
					avg_offset,
					std_dev,
					max_error
				})
		if ComputedData then ComputedData.Histogram = histogram end
	end

	pane[#pane+1] = histogram
end

local label = {}
label.y = -pane_height+20
label.zoom = 0.575
label.padding = 3

-- Cleanly positioning the labels for "mean timing error", "median", and "mode"
-- can be tricky because some languages use very few characters to express these ideas
-- while other languages use many.  This max_width calculation works for now.
label.max_width = ((pane_width/3)/label.zoom) - ((label.padding/label.zoom)*3)

-- avg_timing_error label
pane[#pane+1] = Def.BitmapText{
	Font=ThemePrefs.Get("ThemeFont") .. " Normal",
	Text=ScreenString("MeanTimingError"),
	InitCommand=function(self)
		self:x(40):y(label.y)
			:zoom(label.zoom):maxwidth(label.max_width)

		if self:GetWidth() > label.max_width then
			self:horizalign(left):x(label.padding)
		end
	end,
}

-- avg_timing_error label
pane[#pane+1] = Def.BitmapText{
	Font=ThemePrefs.Get("ThemeFont") .. " Normal",
	Text=ScreenString("MeanOffset"),
	InitCommand=function(self)
		self:x(40 + (pane_width-80)/3):y(label.y)
			:zoom(label.zoom):maxwidth(label.max_width)

		if self:GetWidth() > label.max_width then
			self:horizalign(left):x(label.padding)
		end
	end,
}

-- std_dev label
pane[#pane+1] = Def.BitmapText{
	Font=ThemePrefs.Get("ThemeFont") .. " Normal",
	Text=ScreenString("StdDev"),
	InitCommand=function(self)
		self:x(40 + (pane_width-80)/3 * 2):y(label.y)
			:zoom(label.zoom):maxwidth(label.max_width)
	end,
}

-- max_error label
pane[#pane+1] = Def.BitmapText{
	Font=ThemePrefs.Get("ThemeFont") .. " Normal",
	Text=ScreenString("MaxError"),
	InitCommand=function(self)
		self:x(pane_width-40):y(label.y)
			:zoom(label.zoom):maxwidth(label.max_width)

		if self:GetWidth() > label.max_width then
			self:horizalign(right):x(pane_width - label.padding)
		end
	end,
}

return pane
