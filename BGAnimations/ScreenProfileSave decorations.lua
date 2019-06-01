return Def.ActorFrame{
	Def.Actor{
		BeginCommand=function(self)
			if SCREENMAN:GetTopScreen():HaveProfileToSave() then
				for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
					PROFILEMAN:SaveProfile(player)
				end
			end
			self:queuecommand("Load")
		end,
		LoadCommand=function()
			SCREENMAN:GetTopScreen():Continue()
		end
	}
}