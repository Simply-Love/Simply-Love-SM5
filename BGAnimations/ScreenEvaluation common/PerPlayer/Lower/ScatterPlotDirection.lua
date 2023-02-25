-- if we're in CourseMode, bail now
-- the normal LifeMeter graph (Def.GraphDisplay) will be drawn
if GAMESTATE:IsCourseMode() then return end

-- arguments passed in from Graphs.lua
local args = ...
local player = args.player
local GraphWidth = args.GraphWidth
local GraphHeight = args.GraphHeight
local ArrowColors = { Color.Red, Color.Blue, Color.Green, Color.Yellow }

local pn = ToEnumShortString(player)

-- sequential_offsets gathered in ./BGAnimations/ScreenGameplay overlay/JudgmentOffsetTracking.lua
local sequential_offsets = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].sequential_offsets
local death_second = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].DeathSecond

-- a table to store the AMV's vertices
local verts= {}
local Steps = GAMESTATE:GetCurrentSteps(player)
local TimingData = Steps:GetTimingData()
-- FirstSecond and LastSecond are used in scaling the x-coordinates of the AMV's vertices
local FirstSecond = math.min(TimingData:GetElapsedTimeFromBeat(0), 0)
local LastSecond = GAMESTATE:GetCurrentSong():GetLastSecond()

-- variables that will be used and re-used in the loop while calculating the AMV's vertices
local Offset, CurrentSecond, TimingWindow, x, y, c, r, g, b

-- ---------------------------------------------
-- if players have disabled W4 or W4+W5, there will be a smaller pool
-- of judgments that could have possibly been earned
local worst_window = GetTimingWindow(SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].worst_window)
-- local windows = SL[pn].ActiveModifiers.TimingWindows
-- for i=NumJudgmentsAvailable(),1,-1 do
-- 	if windows[i] then
--		worst_window = GetTimingWindow(i)
--		break
--	end
-- end

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

for t in ivalues(sequential_offsets) do
	CurrentSecond = t[1]
	Offset = t[2]
	Direction = t[3]

	if Offset ~= "Miss" then
		CurrentSecond = CurrentSecond - Offset
	else
		CurrentSecond = CurrentSecond - worst_window
	end

	-- pad the right end because the time measured seems to lag a little...
	x = scale(CurrentSecond, FirstSecond, LastSecond + 0.05, 0, GraphWidth)
	
	-- get the appropriate color from the global SL table
	if Direction > 0 and Direction < 5 then
		c = ArrowColors[Direction]
	else
		c = Color.White
	end

	-- get the red, green, and blue values from that color
	r = c[1]
	g = c[2]
	b = c[3]

	if Offset ~= "Miss" then
		-- DetermineTimingWindow() is defined in ./Scripts/SL-Helpers.lua
		TimingWindow = DetermineTimingWindow(Offset)
		y = scale(Offset, worst_window, -worst_window, 0, GraphHeight)

		-- insert four datapoints into the verts tables, effectively generating a single quadrilateral
		-- top left,  top right,  bottom right,  bottom left
		if death_second ~= nil and CurrentSecond > death_second then
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
		if death_second ~= nil and CurrentSecond > death_second then
			table.insert( verts, {{x, 0, 0}, {r,g,b,0.111}} )
			table.insert( verts, {{x+1, 0, 0}, {r,g,b,0.111}} )
			table.insert( verts, {{x+1, GraphHeight, 0}, {r,g,b,0.111}} )
			table.insert( verts, {{x, GraphHeight, 0}, {r,g,b,0.111}} )
		else
			table.insert( verts, {{x, 0, 0}, {r,g,b,0.333}} )
			table.insert( verts, {{x+1, 0, 0}, {r,g,b,0.333}} )
			table.insert( verts, {{x+1, GraphHeight, 0}, {r,g,b,0.333}} )
			table.insert( verts, {{x, GraphHeight, 0}, {r,g,b,0.333}} )
		end
	end
end

-- the scatter plot will use an ActorMultiVertex in "Quads" mode
-- this is more efficient than drawing n Def.Quads (one for each judgment)
-- because the entire AMV will be a single Actor rather than n Actors with n unique Draw() calls.
local amv = Def.ActorMultiVertex{
	Name="ArrowPlot",
	InitCommand=function(self) self:x(-GraphWidth/2) end,
	OnCommand=function(self)
		self:SetDrawState({Mode="DrawMode_Quads"})
			:SetVertices(verts)
	end,
}

return amv
