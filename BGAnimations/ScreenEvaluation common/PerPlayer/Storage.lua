local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

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

		-- a PlayerStageStats object from the engine
		-- see: http://quietly-turning.github.io/Lua-For-SM5/LuaAPI#Actors-PlayerStageStats
		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

		if PROFILEMAN:IsPersistentProfile(pn) then
			storage.profile = PROFILEMAN:GetProfile(player):GetDisplayName()
		else
			storage.profile = '[GUEST]'
		end

		storage.grade = pss:GetGrade()
		storage.score = pss:GetPercentDancePoints()
		storage.exscore = CalculateExScore(player, GetExJudgmentCounts(player))
		storage.judgments = {
			W1 = pss:GetTapNoteScores(TNSTypes[1]),
			W2 = pss:GetTapNoteScores(TNSTypes[2]),
			W3 = pss:GetTapNoteScores(TNSTypes[3]),
			W4 = pss:GetTapNoteScores(TNSTypes[4]),
			W5 = pss:GetTapNoteScores(TNSTypes[5]),
			Miss = pss:GetTapNoteScores(TNSTypes[6])
		}
		
		if mods.ShowFaPlusWindow and mods.ShowFaPlusPane then
			local counts = GetExJudgmentCounts(player)
			storage.judgments.W0 = counts.W0
			storage.judgments.W1 = counts.W1
			storage.faplus = true
		else
			storage.faplus = false
		end

		if GAMESTATE:IsCourseMode() then
			storage.steps      = GAMESTATE:GetCurrentTrail(player)
			storage.difficulty = storage.steps:GetDifficulty()
			storage.meter      = storage.steps:GetMeter()
			storage.stepartist = GAMESTATE:GetCurrentCourse(player):GetScripter()
		else
			storage.steps      = GAMESTATE:GetCurrentSteps(player)
			storage.difficulty = pss:GetPlayedSteps()[1]:GetDifficulty()
			storage.meter      = pss:GetPlayedSteps()[1]:GetMeter()
			storage.stepartist = pss:GetPlayedSteps()[1]:GetAuthorCredit()
		end

		storage.timingwindows = SL[pn].ActiveModifiers.TimingWindows
	end
}
