local player = ...
local game = GAMESTATE:GetCurrentGame():GetName()

local af = Def.ActorFrame{
	Name="Pane3",
	InitCommand=function(self) self:visible(false) end
}

af[#af+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane2"), player)..{InitCommand=function(self) self:visible(true) end} 
af[#af+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane5"), player)..{InitCommand=function(self) self:visible(true):x(_screen.cx - 115) end} 

return af