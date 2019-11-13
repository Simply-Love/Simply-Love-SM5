local player = ...

local af = Def.ActorFrame{
	Name="Pane1",
}	

af[#af+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane1"), player)

af[#af+1] = LoadActor("./ExperimentJudgmentNumbers.lua", player)

return af