if SL.Global.GameMode == "Casual" then return end

local player = ...
local NumPlayers = #GAMESTATE:GetHumanPlayers()

local GraphWidth  = THEME:GetMetric("GraphDisplay", "BodyWidth")
local GraphHeight = THEME:GetMetric("GraphDisplay", "BodyHeight")

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:y(_screen.cy + 124)
		if NumPlayers == 1 then
			-- not quite an even 0.25 because we need to accomodate the extra 10px
			-- that would normally be between the left and right panes
			self:addx(GraphWidth * 0.2541)
		end
	end,

	-- Draw a Quad behind the GraphDisplay (lifebar graph) and Judgment ScatterPlot
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(GraphWidth, GraphHeight):diffuse(color("#101519")):vertalign(top)
		end
	},
}

-- Only add the background histogram in normal gameplay.
-- Course mode needs to get all subsong density graphs and put them togetehr which we
-- don't currently support.
if not GAMESTATE:IsCourseMode() then
	af[#af+1] = NPS_Histogram(player, GraphWidth, GraphHeight, 0.5)..{
		Name="DensityGraph",
		OnCommand=function(self)
			self:addx(-GraphWidth/2):addy(GraphHeight)
			-- Lower the opacity otherwise some of the scatter plot points might become hard to see.
			self:diffusealpha(0.5)
			self:queuecommand("Redraw")
		end,
	}
end

af[#af+1] = LoadActor("./ScatterPlot.lua", {player=player, GraphWidth=GraphWidth, GraphHeight=GraphHeight} )

-- The GraphDisplay provided by the engine provides us a solid color histogram detailing
-- the player's lifemeter during gameplay capped by a white line.
-- in normal gameplay (non-CourseMode), we hide the solid color but leave the white line.
-- in CourseMode, we hide the white line (for aesthetic reasons) and leave the solid color
-- as ScatterPlot.lua does not yet support CourseMode.
af[#af+1] = Def.GraphDisplay{
	Name="GraphDisplay",
	InitCommand=function(self)
		self:vertalign(top)
		local ColorIndex = ((SL.Global.ActiveColorIndex + (player==PLAYER_1 and -1 or 1)) % #SL.Colors) + 1
		self:Load("GraphDisplay" .. ColorIndex )

		if not GAMESTATE:IsCourseMode() then
			local steps = GAMESTATE:GetCurrentSteps(player)
			local timingData = steps:GetTimingData()
			local firstSecond = math.min(timingData:GetElapsedTimeFromBeat(0), 0)
			local chartStartSecond = GAMESTATE:GetCurrentSong():GetFirstSecond()
			local lastSecond = GAMESTATE:GetCurrentSong():GetLastSecond()
			local duration = lastSecond - firstSecond

			-- GraphDisplay starts at chartStartSecond, but the NPS graph
			-- and the scatter plot start at firstSecond, so we have to
			-- move the lifebar to the correct offset to align it with the
			-- NPS graph.
			local offsetFactor = (chartStartSecond - firstSecond) / duration
			local offset = GraphWidth * offsetFactor
			self:addx(offset/2)
			self:SetWidth(GraphWidth - offset)
		end

		local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		local stageStats = STATSMAN:GetCurStageStats()
		self:Set(stageStats, playerStageStats)

		if GAMESTATE:IsCourseMode() then
			-- hide the GraphDisplay's stroke ("Line")
			self:GetChild("Line"):visible(false)
		else
			-- hide the GraphDisplay's body (2nd unnamed child)
			self:GetChild("")[2]:visible(false)
				self:GetChild("Line"):addy(1)
		end
	end
}

af[#af+1] = Def.Quad{
	Name="ZeroLine",
	InitCommand=function(self)
		self:zoomto(GraphWidth,1)
		self:y(GraphHeight/2)
		self:diffusealpha(0.1)
	end
}

return af
