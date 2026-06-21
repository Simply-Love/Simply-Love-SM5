-- per-player upper half of ScreenEvaluation

local player = ...

return Def.ActorFrame{
	Name=ToEnumShortString(player).."_AF_Upper",
	OnCommand=function(self)
		self:x(Positions.ScreenEvaluation.PaneOffset(player))
	end,

	-- letter grade
	LoadActor("./LetterGrade.lua", player),

	-- nice
	LoadActor("./nice.lua", player),

	-- stepartist
	LoadActor("./StepArtist.lua", player),

	-- stream breakdown
	LoadActor("./StreamBreakdown.lua", player),

	-- difficulty text and meter
	LoadActor("./Difficulty.lua", player),

	-- Record Texts (Machine and/or Personal)
	LoadActor("./RecordTexts.lua", player),

	-- Event Progress Box
	LoadActor("./EventProgress.lua", player)
}