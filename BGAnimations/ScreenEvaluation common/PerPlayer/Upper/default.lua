-- per-player upper half of ScreenEvaluation

local player = ...

return Def.ActorFrame{
	Name=ToEnumShortString(player).."_AF_Upper",
	OnCommand=function(self)
		if player == PLAYER_1 then
			self:x(_screen.cx - 155)
		elseif player == PLAYER_2 then
			self:x(_screen.cx + 155)
		end
	end,

	-- letter grade
	LoadActor("./LetterGrade.lua", player),

	-- nice
	LoadActor("./nice.lua", player),

	-- stream info
	LoadActor("./StreamInfo.lua", player),
	
	-- stepartist
	LoadActor("./StepArtist.lua", player),

	-- difficulty text and meter
	LoadActor("./Difficulty.lua", player),

	-- Record Texts (Machine and/or Personal)
	LoadActor("./RecordTexts.lua", player),

	-- Event specific (ITL/RPG) progress box 
	LoadActor("./EventProgress.lua", player)

}