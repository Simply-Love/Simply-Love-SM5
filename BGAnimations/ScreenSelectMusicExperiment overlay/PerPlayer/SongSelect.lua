local args = ...
local pn = args.player

-- Makes sure that when you're changing songs that the cursor automatically lands on a valid chart (in case of filters/difficulty sort/etc
-- For Difficulty/BPM order it just picks the next highest as determined by the sort/etc
-- Otherwise, first it tries to pick the same difficulty (expert, challenge, etc) and if that's non-existent or invalid then
-- the closest song favoring harder 
return Def.ActorFrame {
	-- broadcast by SongMT as part of a wheel transition. Also broadcast from somewhere not in the theme. SongMT adds a song to params
	-- while the other source doesn't so we can use that to check and only act on the one we want to (the SongMT one)
	CurrentSongChangedMessageCommand=function(self, params)
		if params.song then
			-- Here we determine which set of steps we should be on when the song changes. params_for_input.DifficultyIndex is used by the cursor
			-- to figure out where to display.
			
			--if order of songs is difficulty/bpm then we want to have the correct difficulty automatically selected
			if SL.Global.Order == "Difficulty/BPM" and params.index then
				for steps in ivalues(params.song:GetStepsByStepsType(GetStepsType())) do
					if steps:GetMeter() == DifficultyBPM[params.index].difficulty then
						GAMESTATE:SetCurrentSteps(pn,steps) --CHECK probably works for 2 players
						args.args['DifficultyIndex'..PlayerNumber:Reverse()[pn]] = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(pn):GetDifficulty()]
						break
					end
				end
			--if we're grouping by grade then we want to keep the chosen grade set for the next song. (only if at least one set of steps has a grade)
			--note that we set params_for_input.DifficultyIndex manually here because we might be forcing the cursor to a different difficulty
			elseif SL.Global.GroupType == "Grade" and SL.Global.GradeGroup ~= "No_Grade" then
				local currentGrade = SL.Global.GradeGroup
				for steps in ivalues(params.song:GetStepsByStepsType(GetStepsType())) do
					local highScore = PROFILEMAN:GetProfile(pn):GetHighScoreList(params.song,steps):GetHighScores()[1] --CHECK probably works for 2 players
					if highScore then 
						if highScore:GetGrade() == currentGrade then 
							GAMESTATE:SetCurrentSteps(pn,steps) --CHECK probably works for 2 players
							args.args['DifficultyIndex'..PlayerNumber:Reverse()[pn]] = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(pn):GetDifficulty()]
							break
						end
					end
				end
			--if we're grouping by difficulty then we want to keep the chosen difficulty when changing songs
			--note that we set params_for_input.DifficultyIndex manually here because we might be forcing the cursor to a different difficulty
			elseif SL.Global.GroupType == "Difficulty" then
				local currentDifficulty = SL.Global.DifficultyGroup
				for steps in ivalues(params.song:GetStepsByStepsType(GetStepsType())) do
					if steps:GetMeter() == tonumber(currentDifficulty) then
						GAMESTATE:SetCurrentSteps(pn,steps) --CHECK probably works for 2 players
						args.args['DifficultyIndex'..PlayerNumber:Reverse()[pn]] = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(pn):GetDifficulty()]
						break
					end
				end
			--otherwise try to choose the same difficulty if it exists(challenge, expert, basic, etc)
			elseif DifficultyExists(pn,true) then
				GAMESTATE:SetCurrentSteps(pn,params.song:GetOneSteps('StepsType_Dance_Single',args.args['DifficultyIndex'..PlayerNumber:Reverse()[pn]]))
			--otherwise default to next closest
			--note that we set params_for_input.DifficultyIndex manually here because we might be forcing the cursor to a different difficulty
			else
				--check if there's an easier chart
				local easier = NextEasiest(pn,true) and Difficulty:Reverse()[NextEasiest(pn,true):GetDifficulty()] or nil
				--check if there's a harder chart
				local harder = NextHardest(pn,true) and Difficulty:Reverse()[NextHardest(pn,true):GetDifficulty()] or nil
				--if the difference between harder and current difficulty is greater than the difference between easier and current
				--then we can throw away the harder steps as we know the easier is closer
				if harder and easier then 
					if harder - args.args['DifficultyIndex'..PlayerNumber:Reverse()[pn]] > args.args['DifficultyIndex'..PlayerNumber:Reverse()[pn]] - easier then harder = nil end
				end
				--if they're equally close then default to harder steps, otherwise, set to the closest difficulty
				GAMESTATE:SetCurrentSteps(pn,harder and NextHardest(pn,true) or easier and NextEasiest(pn,true))
				args.args['DifficultyIndex'..PlayerNumber:Reverse()[pn]] = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(pn):GetDifficulty()]
			end
		end
		MESSAGEMAN:Broadcast("StepsHaveChanged")
	end,
}