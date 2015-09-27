local numStages = SL.Global.Stages.PlayedThisGame

local amountAbleToMoveDown = numStages - 5
local amountAbleToMoveUp = 0

local t = Def.ActorFrame{
	CodeMessageCommand=function(self, param)
		if param.Name == "Screenshot" then

			-- organize Screenshots take using Simply Love into directories, like...
			-- ./Screenshots/Simply_Love/2015/06-June/2015-06-05_121708.png
			local prefix = "Simply_Love/" .. Year() .. "/"
			prefix = prefix .. string.format("%02d", tostring(MonthOfYear()+1)) .. "-" .. THEME:GetString("Months", "Month"..MonthOfYear()+1) .. "/"

			SaveScreenshot(param.PlayerNumber, false, true, prefix)
		end

		if param.Name == "MenuLeft" or param.Name == "MenuUp" then
			if amountAbleToMoveUp > 0 then
				self:linear(0.1)
				self:addy( _screen.h/5.25 )
				amountAbleToMoveUp = amountAbleToMoveUp - 1
				amountAbleToMoveDown = amountAbleToMoveDown + 1

			end
		end

		if param.Name == "MenuRight" or param.Name == "MenuDown" then
			if amountAbleToMoveDown > 0 then
				self:linear(0.1)
				self:addy( -_screen.h/5.25 )
				amountAbleToMoveDown = amountAbleToMoveDown - 1
				amountAbleToMoveUp = amountAbleToMoveUp + 1
			end
		end
	end;
};

-- i will increment so that we progress down the screen from top to bottom
-- first song of the round at the top, most recently played song at the bottom
for i=1,numStages do

	t[#t+1] = LoadActor("stageStats", i)..{
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
			end
		}
	end
end

return t