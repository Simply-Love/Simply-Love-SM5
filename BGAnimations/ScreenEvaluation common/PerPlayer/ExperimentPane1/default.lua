local args = ...
local player = args.player
local hash = args.hash

local af = Def.ActorFrame{
	Name="Pane1",
}	

af[#af+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane1"), player)

af[#af+1] = LoadActor("./ExperimentJudgmentNumbers.lua", args)

return af