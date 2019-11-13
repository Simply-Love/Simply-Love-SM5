local player = ...

local pane = Def.ActorFrame{
	Name="Pane3",
	InitCommand = function(self) self:visible(false) end,
	ShowPlayerOptionsPane3MessageCommand = function(self) self:visible(true) end,
	HidePlayerOptionsPane3MessageCommand = function(self) self:visible(false) end,
	SetOptionPanesMessageCommand=function(self)
		if #SL.Global.Stages.Stats == 0 then
			self:GetChild("NoSongs"):visible(true)
		else
			self:GetChild("NoSongs"):visible(false)
		end
	end
}

local LineGraph = LoadActor("./LineGraph.lua")
local initializeLineGraph = CreateLineGraph(200,150)..{
	OnCommand=function(self)

	end
}

pane[#pane+1] = LoadFont("_wendy small")..{
	Name="NoSongs",
	InitCommand=function(self)
		self:zoom(.5)
		self:settext("NO SONGS PLAYED")
	end,
}	


pane[#pane+1] = initializeLineGraph

return pane