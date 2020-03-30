local args = ...
local player = args.player

local pane = Def.ActorFrame{
	Name="Pane5",
	InitCommand=function(self)
		self:visible(false)
	end
}

pane[#pane+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane4"), player)..{InitCommand=function(self) self:visible(true) end}
pane[#pane+1] = LoadActor("QR.lua", args)..{InitCommand=function(self) self:visible(true):x(_screen.cx - WideScale(10,120)) end}

return pane