local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathB("ScreenProfileSave", "decorations"))

t[#t+1] = Def.Actor{
	OnCommand=function(self)
		PROFILEMAN:SaveMachineProfile()
		self:queuecommand("Load")
	end,
	LoadCommand=function()
		SCREENMAN:GetTopScreen():Continue()
	end
}

return t