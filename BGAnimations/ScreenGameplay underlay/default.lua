local t = Def.ActorFrame{
	
	----------------------------------------------------------------------
	--PLAYER 1 DANGER
	Def.ActorFrame{
		Name="DangerP1";
		Def.ActorFrame{
			Name="Single";
			BeginCommand=function(self)
				local style = GAMESTATE:GetCurrentStyle()
				local styleType = style:GetStyleType()
				local bDoubles = (styleType == 'StyleType_OnePlayerTwoSides' or styleType == 'StyleType_TwoPlayersSharedSides')
				self:visible(not bDoubles)
			end;
			HealthStateChangedMessageCommand=function(self, param)
				if param.PlayerNumber == PLAYER_1 then
					if param.HealthState == "HealthState_Danger" then
						self:RunCommandsOnChildren(cmd(playcommand,"Show"))
					else
						self:RunCommandsOnChildren(cmd(playcommand,"Hide"))
					end
				end
			end;
			Def.Quad{
				InitCommand=cmd(faderight,0.1; stretchto,SCREEN_LEFT,SCREEN_TOP,SCREEN_CENTER_X,SCREEN_BOTTOM;diffusealpha,0;);
				ShowCommand=cmd(linear,0.3;diffusealpha,0.7;diffuseshift;effectcolor1,color("1,0,0.24,0.3");effectcolor2,color("1,0,0,0.8"));
				HideCommand=cmd(stopeffect;stoptweening;linear,.5;diffusealpha,0);
			};
		};
	};
	
	
	----------------------------------------------------------------------
	--PLAYER 2 DANGER
	Def.ActorFrame{
		Name="DangerP2";
		Def.ActorFrame{
			Name="Single";
			BeginCommand=function(self)
				local style = GAMESTATE:GetCurrentStyle()
				local styleType = style:GetStyleType()
				local bDoubles = (styleType == 'StyleType_OnePlayerTwoSides' or styleType == 'StyleType_TwoPlayersSharedSides')
				self:visible(not bDoubles)
			end;
			HealthStateChangedMessageCommand=function(self, param)
				if param.PlayerNumber == PLAYER_2 then
					if param.HealthState == "HealthState_Danger" then
						self:RunCommandsOnChildren(cmd(playcommand,"Show"))
					else
						self:RunCommandsOnChildren(cmd(playcommand,"Hide"))
					end
				end
			end;
			Def.Quad{
				InitCommand=cmd(fadeleft,0.1; stretchto,SCREEN_CENTER_X,SCREEN_TOP,SCREEN_RIGHT,SCREEN_BOTTOM;diffusealpha,0;);
				ShowCommand=cmd(linear,0.3;diffusealpha,0.7;diffuseshift;effectcolor1,color("1,0,0.24,0.3");effectcolor2,color("1,0,0,0.8"));
				HideCommand=cmd(stopeffect;stoptweening;linear,.5;diffusealpha,0);
			};
		};
	};
	
	----------------------------------------------------------------------
	-- semi-transparent quad at the top of ScreenGameplay
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.85");zoomto,SCREEN_WIDTH,SCREEN_HEIGHT/5;);
		OnCommand=cmd(xy, SCREEN_WIDTH/2, SCREEN_HEIGHT/12 - 10 );
	};
};

-- Screen Filter
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	t[#t+1] = LoadActor("Filter", pn);
end;

return t;