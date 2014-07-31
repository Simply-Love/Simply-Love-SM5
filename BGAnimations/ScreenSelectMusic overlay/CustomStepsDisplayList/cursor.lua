local pn = ...;

-- bouncing cursor
local cursor = Def.ActorFrame {
	
	LoadActor("arrow.png")..{
		
		InitCommand=function(self)
			self:player(pn)
			self:zoom(0.6)
			if pn == PLAYER_1 then
				if IsUsingWideScreen() then
					self:x(-152)
				else
					self:x(-142)
				end
			elseif pn == PLAYER_2 then
				self:rotationz(180)
				if IsUsingWideScreen() then
					self:x(148)
				else
					self:x(142)
				end
			end
		end,
		OnCommand=function(self)
			self:linear(0.4)
			self:diffusealpha(1)
			self:bounce()
			if pn == PLAYER_1 then
				self:effectmagnitude(-3,0,0)
			elseif pn == PLAYER_2 then
				self:effectmagnitude(3,0,0)
			end
			self:effectperiod(1.0)
			self:effectoffset(0.2)
			self:effectclock("beat")
		end,	
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:visible(true)
			end
		end,

		ResetCommand=function(self)
			
			if GAMESTATE:IsHumanPlayer(pn) then
				local SongOrCourse, StepsOrTrails, CurrentStepsOrTrails
				
				if GAMESTATE:IsCourseMode() then
					SongOrCourse = GAMESTATE:GetCurrentCourse()
				else
					SongOrCourse = GAMESTATE:GetCurrentSong()
				end

				if SongOrCourse then
					if GAMESTATE:IsCourseMode() then
						StepsOrTrails = SongOrCourse:GetAllTrails()
						CurrentStepsOrTrails = GAMESTATE:GetCurrentTrail(pn)
					else
						StepsOrTrails = SongUtil.GetPlayableSteps( SongOrCourse )
						CurrentStepsOrTrails = GAMESTATE:GetCurrentSteps(pn)
					end
					
					if CurrentStepsOrTrails then
						local stepstodisplay = GetStepsToDisplay(StepsOrTrails)
						local offset = 0
						for k,chart in pairs(stepstodisplay) do
							if GAMESTATE:IsCourseMode() then
								if chart:GetDifficulty()==CurrentStepsOrTrails:GetDifficulty() then
									offset = tonumber(k)
								end
							else
								if chart:IsAnEdit() then
									if chart:GetChartName()==CurrentStepsOrTrails:GetChartName() then
										offset = tonumber(k)
									end
								else
									if chart:GetDifficulty()==CurrentStepsOrTrails:GetDifficulty() then
										offset = tonumber(k)
									end
								end
							end
						end
						self:y((offset-3) * 18)
					end
				end
			end
		end
	}
}

return cursor