return Def.Actor{
	OnCommand=function(self)
		SL.Global.Stages.Stats[SL.Global.Stages.PlayedThisGame + 1] = {
			song = GAMESTATE:GetCurrentSong(),
			DecentsWayOffs = SL.Global.ActiveModifiers.DecentsWayOffs,
			MusicRate = SL.Global.ActiveModifiers.MusicRate
		}
	end
}