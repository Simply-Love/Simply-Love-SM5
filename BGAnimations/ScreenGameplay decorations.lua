local sTable = GAMESTATE:GetCurrentSong():GetStepsByStepsType( "StepsType_Dance_Single" );
local DDStats = LoadActor('./ScreenSelectMusicDD overlay/DDStats.lua')

for playerIndex=0,1 do
	if GAMESTATE:IsPlayerEnabled(playerIndex) then
		local difficulty = GAMESTATE:GetCurrentSteps(playerIndex):GetDifficulty()
	end
end

-- Update stats
local song = GAMESTATE:GetCurrentSong()
local PlayerOneChart = GAMESTATE:GetCurrentSteps(0)
local PlayerTwoChart = GAMESTATE:GetCurrentSteps(1)
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
