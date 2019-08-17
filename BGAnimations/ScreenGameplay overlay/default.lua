local t = Def.ActorFrame{}

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
	-- Use this opportunity to create an empty table for this player's gameplay stats for this stage.
	-- We'll store all kinds of data in this table that would normally only exist in ScreenGameplay so that
	-- it can persist into ScreenEvaluation to eventually be processed, visualized, and complained about.
	-- For example, per-column judgments, judgment offset data, highscore data, and so on.
	--
	-- Sadly, this Stages.Stats[stage_index] data structure is not documented anywhere. :(
	SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1] = {}

	t[#t+1] = LoadActor("./TrackTimeSpentInGameplay.lua", player)
	t[#t+1] = LoadActor("./PerColumnJudgmentTracking.lua", player)
	t[#t+1] = LoadActor("./ReceptorArrowsPosition.lua", player)
	t[#t+1] = LoadActor("./JudgmentOffsetTracking.lua", player)
end

return t
