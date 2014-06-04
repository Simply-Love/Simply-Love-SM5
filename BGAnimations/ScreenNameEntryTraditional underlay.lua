local Players = GAMESTATE:GetHumanPlayers();
local Entering = {P1 = false, P2 = false};

local t = Def.ActorFrame{
	InitCommand=cmd(queuecommand, "Detect");
	DetectCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen();
		if topscreen then
		
			for pn in ivalues(Players) do
				if topscreen:GetEnteringName(pn) then
					Entering[ToEnumShortString(pn)] = true;
				end
			end
			
			setenv("PlayersEnteringHighScoreNames", Entering);
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen");
		else
			self:queuecommand("Detect");
		end
	end;
};

return t;