local Player = ...;
local style = GAMESTATE:GetCurrentStyle()
local styleType = style:GetStyleType()
local bDoubles = (styleType == 'StyleType_OnePlayerTwoSides' or styleType == 'StyleType_TwoPlayersSharedSides')

local t = Def.ActorFrame{
	Name="Danger" .. ToEnumShortString(Player);
	HealthStateChangedMessageCommand=function(self, param)
		if param.PlayerNumber == Player then
			if param.HealthState == "HealthState_Danger" then
				self:RunCommandsOnChildren(cmd(playcommand,"Show"))
			else
				self:RunCommandsOnChildren(cmd(playcommand,"Hide"))
			end
		end
	end;
};


t[#t+1] = Def.Quad{
	InitCommand=function(self)
		if bDoubles then
			self:stretchto(SCREEN_LEFT,SCREEN_TOP,SCREEN_RIGHT,SCREEN_BOTTOM); self:diffusealpha(0);
		elseif not bDoubles and Player == PLAYER_1 then
			self:faderight(0.1); self:stretchto(SCREEN_LEFT,SCREEN_TOP,SCREEN_CENTER_X,SCREEN_BOTTOM); self:diffusealpha(0);
		elseif not bDoubles and Player == PLAYER_2 then
			self:fadeleft(0.1); self:stretchto(SCREEN_CENTER_X,SCREEN_TOP,SCREEN_RIGHT,SCREEN_BOTTOM); self:diffusealpha(0);
		end
	end;
	ShowCommand=cmd(linear,0.3;diffusealpha,0.7;diffuseshift;effectcolor1,color("1,0,0.24,0.3");effectcolor2,color("1,0,0,0.8"));
	HideCommand=cmd(stopeffect;stoptweening;linear,.5;diffusealpha,0);
};

return t;