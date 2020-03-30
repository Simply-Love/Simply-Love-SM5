local args = ...
local player = args.player

local af = Def.ActorFrame{
	Name="Pane1",
}	

af[#af+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane1"), player)

af[#af+1] = LoadActor("./ExperimentJudgmentNumbers.lua", args)..{InitCommand=function(self) self:x(WideScale(115,0)) end}

return af