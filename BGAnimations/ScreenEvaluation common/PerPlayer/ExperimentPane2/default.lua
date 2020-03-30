local args = ...
local player = args.player

local af = Def.ActorFrame{
	Name="Pane2",
	InitCommand=function(self) self:visible(false) end
}

af[#af+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane1"), player)

af[#af+1] = LoadActor("./ExperimentPercents.lua", player)..{InitCommand=function(self) self:x(WideScale(115,0)) end}
		

return af