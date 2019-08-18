if SL.Global.GameMode == "Casual" then return end

local player = ...

local GraphWidth = THEME:GetMetric("GraphDisplay", "BodyWidth")
local GraphHeight = THEME:GetMetric("GraphDisplay", "BodyHeight")

return Def.ActorFrame{
	InitCommand=function(self) self:y(_screen.cy + 124) end,

	-- Draw a Quad behind the GraphDisplay (lifebar graph) and Judgment ScatterPlot
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(GraphWidth, GraphHeight):diffuse(color("#101519")):vertalign(top)
		end
	},

	Def.Quad{
		Name="LifeBarGraph_MidwayQuad",
		InitCommand=function(self)
			if SL.Global.GameMode ~= "StomperZ" then
				self:visible(false)
				return
			end
			self:diffuse(0,0,0,0.75):y(GraphHeight):vertalign(bottom)
				:zoomto( GraphWidth, GraphHeight/2 )
		end
	},

	LoadActor("./ScatterPlot.lua", {player=player, GraphWidth=GraphWidth, GraphHeight=GraphHeight} ),

	Def.GraphDisplay{
		Name="GraphDisplay",
		InitCommand=function(self)
			self:vertalign(top)

			local ColorIndex = player == PLAYER_1 and ((SL.Global.ActiveColorIndex-1) % #SL.Colors)+1 or ((SL.Global.ActiveColorIndex+1) % #SL.Colors)+1
			self:Load("GraphDisplay" .. ColorIndex )

			local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
			local stageStats = STATSMAN:GetCurStageStats()
			self:Set(stageStats, playerStageStats)

			if GAMESTATE:IsCourseMode() then
				-- hide the GraphDisplay's stroke ("line")
				self:GetChild("Line"):visible(false)
			else
			    -- hide the GraphDisplay's body
			    self:GetChild("")[2]:visible(false)
			end
		end
	},
}