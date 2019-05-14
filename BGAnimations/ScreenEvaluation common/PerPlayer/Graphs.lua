if SL.Global.GameMode ~= "Casual" then
	local player = ...

    local GraphWidth = THEME:GetMetric("GraphDisplay", "BodyWidth")
    local GraphHeight = THEME:GetMetric("GraphDisplay", "BodyHeight")

	return Def.ActorFrame{

		-- Draw a Quad behind the GraphDisplay (lifebar graph) and Judgment ScatterPlot
		Def.Quad{
			InitCommand=function(self)
				self:y(_screen.cy + 151):zoomto(GraphWidth, GraphHeight)
					:diffuse(color("#101519"))
			end
		},

        LoadActor("./ScatterPlot.lua", {player=player, GraphWidth=GraphWidth, GraphHeight=GraphHeight} ),

		Def.GraphDisplay{
			Name="GraphDisplay",
			InitCommand=function(self)
				self:y( _screen.cy + 151 )

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

		Def.Quad{
			Name="LifeBarGraph_MidwayQuad",
			InitCommand=function(self)
				if SL.Global.GameMode ~= "StomperZ" then
					self:visible(false)
					return
				end
				self:xy( 0, _screen.cy+165 ):diffuse(0,0,0,0.33)
					:zoomto( THEME:GetMetric("GraphDisplay","BodyWidth"), THEME:GetMetric("GraphDisplay","BodyHeight")/2 )
			end
		},

		Def.ComboGraph{
			InitCommand=function(self)
				self:Load("ComboGraph" .. ToEnumShortString(player))
				self:y( _screen.cy+183 )
			end,
			OnCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
				local stageStats = STATSMAN:GetCurStageStats()
				self:Set(stageStats, playerStageStats)
			end
		}
	}

end