local args = ...
local player = args.player
local hash = args.hash
local game = GAMESTATE:GetCurrentGame():GetName()

local af = Def.ActorFrame{
	Name="Pane2",
	InitCommand=function(self) self:visible(false) end
}

af[#af+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane1"), player)

af[#af+1] = LoadActor("./ExperimentPercents.lua", player)
		

return af