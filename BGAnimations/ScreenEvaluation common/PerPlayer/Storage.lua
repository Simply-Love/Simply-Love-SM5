local player = ...
local p = ToEnumShortString(player)

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

		local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

		-- storage (the table) was initialized in Gameplay overlay's offcommand
		-- when we created it to store the duration of seconds spent playing the song
		local storage = SL[p].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]

		storage.grade = stats:GetGrade()
		storage.score = stats:GetPercentDancePoints()
		storage.judgments = {
			W1 = stats:GetTapNoteScores(TNSTypes[1]),
			W2 = stats:GetTapNoteScores(TNSTypes[2]),
			W3 = stats:GetTapNoteScores(TNSTypes[3]),
			W4 = stats:GetTapNoteScores(TNSTypes[4]),
			W5 = stats:GetTapNoteScores(TNSTypes[5]),
			Miss = stats:GetTapNoteScores(TNSTypes[6])
		}
		storage.difficulty = stats:GetPlayedSteps()[1]:GetDifficulty()
		storage.difficultyMeter = stats:GetPlayedSteps()[1]:GetMeter()
		storage.stepartist = stats:GetPlayedSteps()[1]:GetAuthorCredit()
		storage.steps = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
	end
}