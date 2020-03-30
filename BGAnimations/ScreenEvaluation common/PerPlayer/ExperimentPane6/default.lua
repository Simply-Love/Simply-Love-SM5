--This pane is only for doubles

local args = ...
local player = args.player

local pane = Def.ActorFrame{
	Name="Pane6",
	InitCommand=function(self)
		self:visible(false)
	end
}

pane[#pane+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane5"), player)..{
	InitCommand=function(self) self:visible(true):x(_screen.cx-WideScale(270,378)) end
	}

return pane