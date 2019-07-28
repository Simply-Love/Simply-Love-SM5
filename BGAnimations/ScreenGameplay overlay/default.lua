local start_time

local t = Def.ActorFrame{
	OnCommand=function(self)
		start_time = GetTimeSinceStart()
	end,
	OffCommand=function(self)

		-- We want to be able to display the duration spent playing the entire set
		-- for ScreenGameover.  We could call GAMESTATE:GetCurrentSong():MusicLengthSeconds(),
		-- store those, and sum them, but that wouldn't take rate mods and quitting/backing out
		-- of songs into consideration.
		--
		-- What we do here, instead, is calculate the time actually spent on ScreenGameplay
		-- when its OffCommand is called.
		local duration_played = GetTimeSinceStart() - start_time

		for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
			local p = ToEnumShortString(player)
			SL[p].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].duration = duration_played
		end
	end
}

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
	SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1] = {}

	t[#t+1] = LoadActor("./PerColumnJudgmentTracking.lua", player)
	t[#t+1] = LoadActor("./ReceptorArrowsPosition.lua", player)
	t[#t+1] = LoadActor("./JudgmentOffsetTracking.lua", player)
end

return t
