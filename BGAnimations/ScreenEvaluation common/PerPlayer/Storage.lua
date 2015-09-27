local pn = ...

local TNSTypes = {
	'TapNoteScore_W1',
	'TapNoteScore_W2',
	'TapNoteScore_W3',
	'TapNoteScore_W4',
	'TapNoteScore_W5',
	'TapNoteScore_Miss'
}

return Def.Actor{
	OnCommand=function(self)

		local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

		SL[ToEnumShortString(pn)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1] = {
			grade = stats:GetGrade(),
			score = stats:GetPercentDancePoints(),
			judgments = {
				W1 = stats:GetTapNoteScores(TNSTypes[1]),
				W2 = stats:GetTapNoteScores(TNSTypes[2]),
				W3 = stats:GetTapNoteScores(TNSTypes[3]),
				W4 = stats:GetTapNoteScores(TNSTypes[4]),
				W5 = stats:GetTapNoteScores(TNSTypes[5]),
				Miss = stats:GetTapNoteScores(TNSTypes[6])
			},
			difficulty = stats:GetPlayedSteps()[1]:GetDifficulty(),
			difficultyMeter = stats:GetPlayedSteps()[1]:GetMeter(),
			stepartist = stats:GetPlayedSteps()[1]:GetAuthorCredit(),
			steps = GAMESTATE:GetCurrentSteps(pn)
		}
	end
}