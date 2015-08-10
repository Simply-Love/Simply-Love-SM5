return Def.ActorFrame{
	OffCommand=cmd(queuecommand, "Style"; sleep, 0.8),
	StyleCommand=function(self)
		SL.Global.Gamestate.Style = GAMESTATE:GetCurrentStyle():GetName()
	end
}