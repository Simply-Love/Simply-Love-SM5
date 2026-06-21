local af = LoadActor(THEME:GetPathB("ScreenProfileSave", "decorations"))

af[#af+1] = Def.Actor{
	OnCommand=function(self)
		PROFILEMAN:SaveMachineProfile()
		self:queuecommand("Load")
	end,
	LoadCommand=function()
		SCREENMAN:GetTopScreen():Continue()
	end
}

return af