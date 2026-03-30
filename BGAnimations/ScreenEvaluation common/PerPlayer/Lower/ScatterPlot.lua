-- if we're in CourseMode, then we'll have to collect steps per chart
local iscourse = GAMESTATE:IsCourseMode()

-- arguments passed in from Graphs.lua
local args = ...
local player = args.player
local pn = ToEnumShortString(player)
local GraphWidth = args.GraphWidth
local GraphHeight = args.GraphHeight
local mods = SL[pn].ActiveModifiers

local tenms = mods.SmallerWhite
local SplitWhites = mods.SplitWhites
local magenta = color("#E928FF")

-- sequential_offsets gathered in ./BGAnimations/ScreenGameplay overlay/JudgmentOffsetTracking.lua
local sequential_offsets = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].sequential_offsets
local death_second = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].DeathSecond
local MusicRate = SL.Global.ActiveModifiers.MusicRate

-- a table to store the AMV's vertices
-- this will be a table of tables, to get around ActorMultiVertex limitations on D3D renderer
local vertsTable= {}

local Steps = GAMESTATE:GetCurrentSteps(player)
local TimingData = Steps:GetTimingData()
-- FirstSecond and LastSecond are used in scaling the x-coordinates of the AMV's vertices
local FirstSecond = math.min(TimingData:GetElapsedTimeFromBeat(0), 0)
local LastSecond = (not iscourse) and GAMESTATE:GetCurrentSong():GetLastSecond() or TotalCourseLength(player) * SL.Global.ActiveModifiers.MusicRate

-- variables that will be used and re-used in the loop while calculating the AMV's vertices
local Offset, CurrentSecond, TimingWindow, x, y, c, r, g, b

-- ---------------------------------------------
-- scale worst_window to the worst judgment hit in the song
-- start at Excellent window as the worst window since most quads are
-- hard to make sense of visually
local worst_window = GetTimingWindow(math.max(2, GetWorstJudgment(sequential_offsets)))

-- cap worst_window to Great if selected by the player
if mods.ScaleGraph then
	worst_window = math.min(worst_window, SL.Global.GameMode == "FA+" and GetTimingWindow(4) or GetTimingWindow(3))
end

-- ---------------------------------------------

local colors = {}
for w=NumJudgmentsAvailable(),1,-1 do
	if SL[pn].ActiveModifiers.TimingWindows[w]==true then
		colors[w] = DeepCopy(SL.JudgmentColors[SL.Global.GameMode][w])
	else
		colors[w] = DeepCopy(colors[w+1] or SL.JudgmentColors[SL.Global.GameMode][w+1])
	end
end

-- ---------------------------------------------

-- Initialize vertices table of tables and start the stepcount
vertsTable[#vertsTable+1] = {}
local stepCount = 0
for t in ivalues(sequential_offsets) do
	stepCount = stepCount + 1
	-- If the step-count exceeds the threshold, start a new table within the table.
	if stepCount >= 8192 then
		stepCount = 0
		vertsTable[#vertsTable+1] = {}
	end
	local verts = vertsTable[#vertsTable]

	CurrentSecond = t[1]
	Offset = t[2]
	
	EarlyHit = t[6]
	EarlyOffset = t[7]
	HeldMiss = t[8]

	if Offset ~= "Miss" then
		CurrentSecond = CurrentSecond - Offset
	else
		CurrentSecond = CurrentSecond - worst_window
	end

	-- pad the right end because the time measured seems to lag a little...
	x = scale(CurrentSecond, FirstSecond, LastSecond + 0.05, 0, GraphWidth)

	if Offset ~= "Miss" and (math.abs(Offset) <= worst_window or not mods.ScaleGraph) then
		-- DetermineTimingWindow() is defined in ./Scripts/SL-Helpers.lua
		TimingWindow = DetermineTimingWindow(Offset)
		y = scale(Offset, worst_window, -worst_window, 0, GraphHeight)

		-- get the appropriate color from the global SL table
		c = colors[TimingWindow]

		if mods.ShowFaPlusWindow and mods.ShowFaPlusPane then
			abs_offset = math.abs(Offset)
			if tenms and SplitWhites then
				if abs_offset < GetTimingWindow(1, "FA+",tenms) then
					c = magenta
				elseif abs_offset > GetTimingWindow(1, "FA+",tens) and abs_offset <= GetTimingWindow(1, "FA+") then
					c = SL.JudgmentColors["FA+"][1]
				elseif abs_offset > GetTimingWindow(1, "FA+") and abs_offset <= GetTimingWindow(2, "FA+") then
					c = SL.JudgmentColors["FA+"][2]
				end
			elseif abs_offset > GetTimingWindow(1, "FA+") and abs_offset <= GetTimingWindow(2, "FA+") then
				c = SL.JudgmentColors["FA+"][2]
			end
		end

		-- get the red, green, and blue values from that color
		r = c[1]
		g = c[2]
		b = c[3]

		-- insert four datapoints into the verts tables, effectively generating a single quadrilateral
		-- top left,  top right,  bottom right,  bottom left
		if death_second ~= nil and CurrentSecond / MusicRate > death_second then
			table.insert( verts, {{x,y,0}, {r,g,b,0.333}} )
			table.insert( verts, {{x+1.5,y,0}, {r,g,b,0.333}} )
			table.insert( verts, {{x+1.5,y+1.5,0}, {r,g,b,0.333}} )
			table.insert( verts, {{x,y+1.5,0}, {r,g,b,0.333}} )
		else
			table.insert( verts, {{x,y,0}, {r,g,b,0.666}} )
			table.insert( verts, {{x+1.5,y,0}, {r,g,b,0.666}} )
			table.insert( verts, {{x+1.5,y+1.5,0}, {r,g,b,0.666}} )
			table.insert( verts, {{x,y+1.5,0}, {r,g,b,0.666}} )
		end
		
		-- Plot early hits if they are being tracked, at lower opacity
		if EarlyHit then
			-- DetermineTimingWindow() is defined in ./Scripts/SL-Helpers.lua
			TimingWindow = DetermineTimingWindow(EarlyOffset)
			y = scale(EarlyOffset, worst_window, -worst_window, 0, GraphHeight)

			-- get the appropriate color from the global SL table
			c = colors[TimingWindow]

			if mods.ShowFaPlusWindow and mods.ShowFaPlusPane then
				abs_offset = math.abs(EarlyOffset)
				if mods.SmallerWhite and abs_offset > GetTimingWindow(1, "FA+", true) and abs_offset <= GetTimingWindow(1, "FA+", false) then
					c = BlendColors(SL.JudgmentColors["FA+"][2], colors[1])
				elseif abs_offset > GetTimingWindow(1, "FA+") and abs_offset <= GetTimingWindow(2, "FA+") then
					c = SL.JudgmentColors["FA+"][2]
				end
			end

			-- get the red, green, and blue values from that color
			r = c[1]
			g = c[2]
			b = c[3]

			-- insert four datapoints into the verts tables, effectively generating a single quadrilateral
			-- top left,  top right,  bottom right,  bottom left
			if death_second ~= nil and CurrentSecond / MusicRate > death_second then
				table.insert( verts, {{x,y,0}, {r,g,b,0.15}} )
				table.insert( verts, {{x+1.5,y,0}, {r,g,b,0.15}} )
				table.insert( verts, {{x+1.5,y+1.5,0}, {r,g,b,0.15}} )
				table.insert( verts, {{x,y+1.5,0}, {r,g,b,0.15}} )
			else
				table.insert( verts, {{x,y,0}, {r,g,b,0.3}} )
				table.insert( verts, {{x+1.5,y,0}, {r,g,b,0.3}} )
				table.insert( verts, {{x+1.5,y+1.5,0}, {r,g,b,0.3}} )
				table.insert( verts, {{x,y+1.5,0}, {r,g,b,0.3}} )
			end
		end
	else
		local col = color("#ff000077")
		if Offset ~= "Miss" and mods.ScaleGraph then
			TimingWindow = DetermineTimingWindow(Offset)
			y = scale(Offset, worst_window, -worst_window, 0, GraphHeight)
			
			-- get the appropriate color from the global SL table
			c = colors[TimingWindow]

			if mods.ShowFaPlusWindow and mods.ShowFaPlusPane then
				abs_offset = math.abs(Offset)
				if abs_offset > GetTimingWindow(1, "FA+") and abs_offset <= GetTimingWindow(2, "FA+") then
					c = SL.JudgmentColors["FA+"][2]
				end
			end

			-- get the red, green, and blue values from that color
			r = c[1]
			g = c[2]
			b = c[3]
		else
			r = 1
			g = 0
			b = 0
		end
		-- else, a miss should be a quadrilateral that is the height of half of the graph and red
		-- if the miss is held, fill the upper half. otherwise, fill the lower half
		-- if the graph is capped to Greats, use these too
		local h1 = HeldMiss and GraphHeight/2 or 0
		local h2 = HeldMiss and GraphHeight or GraphHeight/2
		if Offset ~= "Miss" then
			h1 = Offset>0 and 0 or GraphHeight/2
			h2 = Offset>0 and GraphHeight/2 or GraphHeight
		end
		if death_second ~= nil and CurrentSecond / MusicRate > death_second then
			col = {r,g,b,0.08}
			table.insert( verts, {{x, h1, h1}, col} )
			table.insert( verts, {{x+1, h1, h1}, col} )
			table.insert( verts, {{x+1, h2, h2}, col} )
			table.insert( verts, {{x, h2, h2}, col} )
		else
			col = {r,g,b,0.3}
			table.insert( verts, {{x, h1, h1}, col} )
			table.insert( verts, {{x+1, h1, h1}, col} )
			table.insert( verts, {{x+1, h2, h2}, col} )
			table.insert( verts, {{x, h2, h2}, col} )
		end
	end
end

-- the scatter plot will use an ActorMultiVertex in "Quads" mode
-- this is more efficient than drawing n Def.Quads (one for each judgment)
-- because the entire AMV will be a single Actor rather than n Actors with n unique Draw() calls.
-- Since we've now split the table into multiples, create an ActorMultiVertex for each table and store them into one ActorFrame.
local af = Def.ActorFrame{}

-- if this is the score screen for a course, then iterate through each chart and plot them
if iscourse then
	local trailEntries = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()
	local curSecs = 0
	
	for i=1,#trailEntries do
		local endSec = trailEntries[i]:GetSong():GetLastSecond()
		local startX = (-GraphWidth/2) + (curSecs / LastSecond) * GraphWidth
		local endX = (endSec / LastSecond) * GraphWidth
		af[#af+1] = Def.Quad{
			InitCommand=function(self)
				self:x(startX):zoomto(endX, GraphHeight):diffuse(LightenColor(LightenColor(color("#101519")))):diffusealpha(0.5):vertalign(top):horizalign(left)
				if i%2 == 0 then self:visible(false) end
				if ThemePrefs.Get("VisualStyle") == "Technique" then
					self:diffusealpha(0.6)
				end
			end
		}
		curSecs = curSecs + endSec
	end
end

for verts in ivalues(vertsTable) do
	local amv = Def.ActorMultiVertex{
		InitCommand=function(self) self:x(-GraphWidth/2) end,
		OnCommand=function(self)
			self:SetDrawState({Mode="DrawMode_Quads"})
				:SetVertices(verts)
		end,
	}
	af[#af+1] = amv
end

return af
