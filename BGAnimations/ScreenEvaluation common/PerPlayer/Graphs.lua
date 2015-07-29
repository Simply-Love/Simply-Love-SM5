local player = ...

return Def.ActorFrame{

	Def.GraphDisplay{
		Name="GraphDisplay",
		InitCommand=function(self)
			self:y( _screen.cy + 151 )

			local ColorIndex = player == PLAYER_1 and (SL.Global.ActiveColorIndex-1)%12+1 or (SL.Global.ActiveColorIndex+1)%12+1
			self:Load("GraphDisplay" .. ColorIndex )

			local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
			local stageStats = STATSMAN:GetCurStageStats()
			self:Set(stageStats, playerStageStats)

			-- hide the GraphDisplay's stroke ("line")
			self:GetChild("Line"):diffusealpha(0)
		end
	},


	Def.ComboGraph{
		InitCommand=function(self)
			if player == PLAYER_1 then
				self:Load("ComboGraphP1")
			else
				self:Load("ComboGraphP2")
			end
			self:y( _screen.cy+182.5 )
		end,
		OnCommand=function(self)
			local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
			local stageStats = STATSMAN:GetCurStageStats()
			self:Set(stageStats, playerStageStats)
		end
	}
}