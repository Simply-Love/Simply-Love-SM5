if SL.Global.GameMode ~= "Casual" then
	local player = ...

	return Def.ActorFrame{

		-- Draw a semitransparent Quad behind the GraphDisplay (lifebar graph)
		-- if RainbowMode is on.  This makes it easier to see with the wacky background.
		Def.Quad{
			InitCommand=function(self)
				if ThemePrefs.Get("RainbowMode") then
					self:y( _screen.cy + 151):zoomto(300, 54)
						:diffuse(color("#00000088"))
				else
					self:visible(false)
				end
			end
		},

		Def.GraphDisplay{
			Name="GraphDisplay",
			InitCommand=function(self)
				self:y( _screen.cy + 151 )

				local ColorIndex = player == PLAYER_1 and ((SL.Global.ActiveColorIndex-1) % #SL.Colors)+1 or ((SL.Global.ActiveColorIndex+1) % #SL.Colors)+1
				self:Load("GraphDisplay" .. ColorIndex )

				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
				local stageStats = STATSMAN:GetCurStageStats()
				self:Set(stageStats, playerStageStats)

				-- hide the GraphDisplay's stroke ("line")
				self:GetChild("Line"):visible(false)
			end
		},

		Def.Quad{
			Name="LifeBarGraph_MidwayQuad",
			InitCommand=function(self)
				if SL.Global.GameMode ~= "StomperZ" and SL.Global.GameMode ~= "ECFA" then
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
				self:y( _screen.cy+182.5 )
			end,
			OnCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
				local stageStats = STATSMAN:GetCurStageStats()
				self:Set(stageStats, playerStageStats)
			end
		}
	}

end