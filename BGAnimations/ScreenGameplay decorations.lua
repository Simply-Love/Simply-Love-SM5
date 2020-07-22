local sTable = GAMESTATE:GetCurrentSong():GetStepsByStepsType( "StepsType_Dance_Single" );

for playerIndex=0,1 do
	if GAMESTATE:IsPlayerEnabled(playerIndex) then
		local difficulty = GAMESTATE:GetCurrentSteps(playerIndex):GetDifficulty()
	end
end

local t = Def.ActorFrame {
		OnCommand=function(self)
			self:sleep(999)
		end,
		Def.ActorFrame {
			OnCommand=function(self)
				self:sleep(1):queuecommand('CheckEnd')
			end,
			CheckEndCommand=function(self)
				local numberOfPlayersWhoAreNotDone = 0
				
				for playerIndex=1,2 do
					if GAMESTATE:IsPlayerEnabled(playerIndex-1) then
						local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats("P"..playerIndex)
						local curMaxPoints = stats:GetCurrentPossibleDancePoints()
						local totalPoints = stats:GetPossibleDancePoints()
						
						if curMaxPoints ~= totalPoints then
							numberOfPlayersWhoAreNotDone = numberOfPlayersWhoAreNotDone + 1
						end
					end
				end
				
				isDone = numberOfPlayersWhoAreNotDone == 0
				
				if isDone then
					self:sleep(1):queuecommand('Finished')
				else
					self:sleep(1):queuecommand('CheckEnd')
				end
			end,
			FinishedCommand=function(self)
				SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_DoNextScreen")
			end
		}
	}
return t
