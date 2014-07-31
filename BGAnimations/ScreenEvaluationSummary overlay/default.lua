local numStages = STATSMAN:GetStagesPlayed()
local currentStageNum = numStages

local amountAbleToMoveDown = numStages - 5
local amountAbleToMoveUp = 0


local t = Def.ActorFrame{
	CodeMessageCommand=function(self, param)
		-- if param.Name == "Screenshot" then
		-- 	SaveScreenshot(param.PlayerNumber, false, true)
		-- end
		
		if param.Name == "Left" or param.Name == "MenuLeft" or param.Name == "Up" or param.Name == "MenuUp" then
			if amountAbleToMoveUp > 0 then
				self:linear(0.1)
				self:addy( _screen.h/5.25 )
				amountAbleToMoveUp = amountAbleToMoveUp - 1
				amountAbleToMoveDown = amountAbleToMoveDown + 1

			end
		end

		if param.Name == "Right" or param.Name == "MenuRight" or param.Name == "Down" or param.Name == "MenuDown" then
			if amountAbleToMoveDown > 0 then
				self:linear(0.1)
				self:addy( -_screen.h/5.25 )
				amountAbleToMoveDown = amountAbleToMoveDown - 1
				amountAbleToMoveUp = amountAbleToMoveUp + 1
			end
		end
	end;
};

-- currentStageNum will decrement so that we go from the first song we played to the song most recently played
-- i will increment so that we progress down the screen from top to bottom
-- first song of the round at the top, most recently played song at the bottom
for i=1,numStages do
	
	-- bundle both the stagestats object and the number representing which stage number it was into a table
	local stageStats = { STATSMAN:GetPlayedStageStats(currentStageNum), i }
	
	if stageStats then
		
		-- and pass that table off to stageStats.lua
		t[#t+1] = LoadActor("stageStats", stageStats)..{
			Name="Stage"..i.."Stats",
			InitCommand=cmd(diffusealpha,0),
			OnCommand=function(self)
				self:x(_screen.cx)
				self:y( (_screen.h/5.25) * (i-0.35) )
				self:sleep(i*0.1)
				self:linear(0.25)
				self:diffusealpha(1)
			end
		}
		
		
		-- we want a long, thin white quad to separate each set of song data
		-- but don't want one drawn after the last song that will appear on this page
		if i ~= numStages then
			t[#t+1] = Def.Quad{
				InitCommand=cmd(zoomto,_screen.w*0.8,1;faderight,0.1;fadeleft,0.1;diffusealpha,0),
				OnCommand=function(self)
					self:x(_screen.cx)
					self:y( (_screen.h/5.25) * (i-0.5) + 54)
					self:sleep(i*0.1)
					self:linear(0.25)
					self:diffusealpha(0.5)
				end;
			};
		end
	end
	
	currentStageNum = currentStageNum-1
end


return t