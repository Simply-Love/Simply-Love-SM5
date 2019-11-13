local player = ...

local pane = Def.ActorFrame{
	Name="Pane4",
	InitCommand=function(self)
		self:visible(false)
	end
}

pane[#pane+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane3"), player)..{InitCommand=function(self) self:visible(true) end}
	
pane[#pane+1] = LoadFont("_wendy small")..{
	InitCommand=function(self)
		self:zoom(.5):xy(_screen.cx - 115, 250)
		self:settext("Put something here")
	end,
}

return pane