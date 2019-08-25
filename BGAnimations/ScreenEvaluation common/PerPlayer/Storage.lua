local player = ...
local pn = ToEnumShortString(player)

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
		-- this SL[pn].Stages.Stats subtable was initialized in ./BGAnimations/ScreenGameplay overlay/default.lua
		-- One new table like this gets appended to SL[pn].Stages.Stats, indexed by stage number, to store
		-- lots of information (like below) so that it can persist between screens.
		--
		-- Here, we are storing things like letter grade, percent score, judgment counts, stepchart difficulty, etc.
		-- so that we can more easily display it on ScreenEvaluationSummary when this game cycle ends.
		local storage = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]

		-- a PLayerStageStats object from the engine
		-- see: http://dguzek.github.io/Lua-For-SM5/LuaAPI#Actors-PlayerStageStats
		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

		storage.grade = pss:GetGrade()
		storage.score = pss:GetPercentDancePoints()
		storage.judgments = {
			W1 = pss:GetTapNoteScores(TNSTypes[1]),
			W2 = pss:GetTapNoteScores(TNSTypes[2]),
			W3 = pss:GetTapNoteScores(TNSTypes[3]),
			W4 = pss:GetTapNoteScores(TNSTypes[4]),
			W5 = pss:GetTapNoteScores(TNSTypes[5]),
			Miss = pss:GetTapNoteScores(TNSTypes[6])
		}
		storage.difficulty = pss:GetPlayedSteps()[1]:GetDifficulty()
		storage.difficultyMeter = pss:GetPlayedSteps()[1]:GetMeter()
		storage.stepartist = pss:GetPlayedSteps()[1]:GetAuthorCredit()
		storage.steps = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
	end
}