return Def.ActorFrame{
	OffCommand=cmd(queuecommand, "Style", sleep, 0.8;),
	StyleCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local index = topscreen:GetSelectionIndex(GAMESTATE:GetMasterPlayerNumber())
		local metric = THEME:GetMetric(topscreen:GetName(), "Choice"..(index+1))
		local choice = metric:match("style,(%w+);")
		SL.Global.Gamestate.Style = choice
	end
}