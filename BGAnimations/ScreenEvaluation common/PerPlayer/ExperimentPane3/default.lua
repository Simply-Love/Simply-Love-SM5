local args = ...
local player = args.player

local af = Def.ActorFrame{
	Name="Pane3",
	InitCommand=function(self) self:visible(false) end
}

af[#af+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane2"), player)..{InitCommand=function(self) self:visible(true):x(0) end}

if GAMESTATE:GetCurrentStyle():GetStyleType() ~= "StyleType_OnePlayerTwoSides" then
	af[#af+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane5"), player)..{InitCommand=function(self) self:visible(true):x(_screen.cx - WideScale(10,115)) end} 
end
return af