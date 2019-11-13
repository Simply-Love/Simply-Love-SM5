local player = ...

local pane = Def.ActorFrame{
	Name="Pane3",
	InitCommand=function(self)
		self:visible(false)
		self:y(_screen.cy - 62):zoom(0.8)
	end
}

local args = { Player=player, NumHighScores=10, RoundsAgo=1 }

pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)

return pane