-- if we're in CourseMode, bail now
-- the normal LifeMeter graph (Def.GraphDisplay) will be drawn
if GAMESTATE:IsCourseMode() then return end

-- arguments passed in from Graphs.lua
local args = ...
local player = args.player
local pn = ToEnumShortString(player)
local GraphWidth = args.GraphWidth
local GraphHeight = args.GraphHeight
local mods = SL[pn].ActiveModifiers

local pn = ToEnumShortString(player)

local pn = ToEnumShortString(player)

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
local LastSecond = GAMESTATE:GetCurrentSong():GetLastSecond()

-- variables that will be used and re-used in the loop while calculating the AMV's vertices
local Offset, CurrentSecond, TimingWindow, x, y, c, r, g, b

-- ---------------------------------------------
-- scale worst_window to the worst judgment hit in the song
-- start at Excellent window as the worst window since most quads are
-- hard to make sense of visually
local worst_window = GetTimingWindow(math.max(2, GetWorstJudgment(sequential_offsets)))

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

vertsTable[#vertsTable+1] = {}
local stepCount = 0
for t in ivalues(sequential_offsets) do
	stepCount = stepCount + 1
	if stepCount >= 16384 then
		stepCount = 0
		vertsTable[#vertsTable+1] = {}
	end
	local verts = vertsTable[#vertsTable]

	CurrentSecond = t[1]
	Offset = t[2]

	if Offset ~= "Miss" then
		CurrentSecond = CurrentSecond - Offset
	else
		CurrentSecond = CurrentSecond - worst_window
	end

	-- pad the right end because the time measured seems to lag a little...
	x = scale(CurrentSecond, FirstSecond, LastSecond + 0.05, 0, GraphWidth)

	if Offset ~= "Miss" then
		-- DetermineTimingWindow() is defined in ./Scripts/SL-Helpers.lua
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
	else
		-- else, a miss should be a quadrilateral that is the height of the entire graph and red
		if death_second ~= nil and CurrentSecond / MusicRate > death_second then
			table.insert( verts, {{x, 0, 0}, color("#ff000033")} )
			table.insert( verts, {{x+1, 0, 0}, color("#ff000033")} )
			table.insert( verts, {{x+1, GraphHeight, 0}, color("#ff000033")} )
			table.insert( verts, {{x, GraphHeight, 0}, color("#ff000033")} )
		else
			table.insert( verts, {{x, 0, 0}, color("#ff000077")} )
			table.insert( verts, {{x+1, 0, 0}, color("#ff000077")} )
			table.insert( verts, {{x+1, GraphHeight, 0}, color("#ff000077")} )
			table.insert( verts, {{x, GraphHeight, 0}, color("#ff000077")} )
		end
	end
end

-- the scatter plot will use an ActorMultiVertex in "Quads" mode
-- this is more efficient than drawing n Def.Quads (one for each judgment)
-- because the entire AMV will be a single Actor rather than n Actors with n unique Draw() calls.
local af = Def.ActorFrame{}

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
