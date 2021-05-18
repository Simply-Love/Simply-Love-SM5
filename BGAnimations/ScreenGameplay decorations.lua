if GAMESTATE:IsCourseMode() then
	local course = GAMESTATE:GetCurrentCourse()
	if GAMESTATE:GetCourseSongIndex() + 1 < course:GetNumCourseEntries() then
		fail = true
	end
	
	if fail then
		-- Let's fail the bots as well.
		for player in ivalues( GAMESTATE:GetEnabledPlayers() ) do
			local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
			pss:FailPlayer()
		end
	end

end


if not GAMESTATE:IsCourseMode() then
	local sTable = GAMESTATE:GetCurrentSong():GetStepsByStepsType( "StepsType_Dance_Single" );
	local nsj = GAMESTATE:GetNumSidesJoined()
	
	IsFinished = false
	Player1MinesAvoided = 0
	Player2MinesAvoided = 0
	
	for playerIndex=0,1 do
		if GAMESTATE:IsPlayerEnabled(playerIndex) then
			local difficulty = GAMESTATE:GetCurrentSteps(playerIndex):GetDifficulty()
		end
	end

		-- Update stats
		local song = GAMESTATE:GetCurrentSong()
		local PlayerOneChart = GAMESTATE:GetCurrentSteps(0)
		local PlayerTwoChart = GAMESTATE:GetCurrentSteps(1)
		local TotalMinesP1
		local TotalMinesP2
		if GAMESTATE:IsPlayerEnabled(0) then
			TotalMinesP1 = PlayerOneChart:GetRadarValues(playerIndex):GetValue('RadarCategory_Mines')
		elseif GAMESTATE:IsPlayerEnabled(1) then
			TotalMinesP2 = PlayerTwoChart:GetRadarValues(playerIndex):GetValue('RadarCategory_Mines')
		end
		
		
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			DDStats.SetStat(PLAYER_1, 'LastSong', song:GetSongDir())
			DDStats.SetStat(PLAYER_1, 'LastDifficulty', PlayerOneChart:GetDifficulty())
			DDStats.Save(PLAYER_1)
		end

		if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
			DDStats.SetStat(PLAYER_2, 'LastSong', song:GetSongDir())
			DDStats.SetStat(PLAYER_2, 'LastDifficulty', PlayerTwoChart:GetDifficulty())
			DDStats.Save(PLAYER_2)
		end

	local t = Def.ActorFrame {
			OnCommand=function(self)
				self:sleep(999)
			end,
			Def.ActorFrame {
				OnCommand=function(self)
					self:sleep(0.1):queuecommand('CheckEnd')
				end,
				CheckEndCommand=function(self)
					local numberOfPlayersWhoAreNotDone = 0
					
					for playerIndex=1,2 do
						if GAMESTATE:IsPlayerEnabled(playerIndex-1) then
							local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats("P"..playerIndex)
							local curMaxPoints = stats:GetCurrentPossibleDancePoints()
							local totalPoints = stats:GetPossibleDancePoints()
							
							--- this is stupid but #stepmania-moment
							local statsP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats("P1")
							local statsP2 = STATSMAN:GetCurStageStats():GetPlayerStageStats("P2")
							local MinesHitP1 = statsP1:GetTapNoteScores('TapNoteScore_HitMine')
							local MinesHitP2 = statsP2:GetTapNoteScores('TapNoteScore_HitMine')
							local MinesPassedByP1 = MinesHitP1 + Player1MinesAvoided
							local MinesPassedByP2 = MinesHitP2 + Player2MinesAvoided
							
							--- TODO: On Versus it will not exit early. Why????????
							if nsj == 2 then
								if curMaxPoints ~= totalPoints then
									numberOfPlayersWhoAreNotDone = numberOfPlayersWhoAreNotDone + 1
								end
								if MinesPassedByP1 ~= TotalMinesP1 then
									numberOfPlayersWhoAreNotDone = numberOfPlayersWhoAreNotDone + 1
								end
								if MinesPassedByP2 ~= TotalMinesP2 then
									numberOfPlayersWhoAreNotDone = numberOfPlayersWhoAreNotDone + 1
								end
							elseif GAMESTATE:IsPlayerEnabled(0) then
								if curMaxPoints ~= totalPoints then
									numberOfPlayersWhoAreNotDone = numberOfPlayersWhoAreNotDone + 1
								end
								if MinesPassedByP1 ~= TotalMinesP1 then
									numberOfPlayersWhoAreNotDone = numberOfPlayersWhoAreNotDone + 1
								end
							elseif GAMESTATE:IsPlayerEnabled(1) then
								if curMaxPoints ~= totalPoints then
									numberOfPlayersWhoAreNotDone = numberOfPlayersWhoAreNotDone + 1
								end
								if MinesPassedByP2 ~= TotalMinesP2 then
									numberOfPlayersWhoAreNotDone = numberOfPlayersWhoAreNotDone + 1
								end
							end
						end
					end
					
					isDone = numberOfPlayersWhoAreNotDone == 0
					
					if isDone then
						IsFinished = true
						self:queuecommand('Finished')
					else
						self:sleep(0.1):queuecommand('CheckEnd')
					end
				end,
				FinishedCommand=function(self)
					SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_DoNextScreen")
				end,
				OffCommand=function(self)
					self:sleep(0.6):queuecommand("Fail")
				end,
				FailCommand=function(self)
					if not IsFinished then
						-- Let's fail the bots as well.
						for player in ivalues( GAMESTATE:GetEnabledPlayers() ) do
							local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
							pss:FailPlayer()
						end
					end
				end,
			}
		}
	return t
else
	return Def.ActorFrame {}
end