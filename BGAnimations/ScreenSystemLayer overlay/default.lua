local function CreditsText( pn )
	function update(self)
		local str = ScreenSystemLayerHelpers.GetCreditsMessage(pn);
		self:settext(str);
	end

	function UpdateVisible(self)
		local screen = SCREENMAN:GetTopScreen();
		local bShow = true;
		if screen then
			local sClass = screen:GetName();
			bShow = THEME:GetMetric( sClass, "ShowCoinsAndCredits" );
		end

		self:visible( bShow );
	end

	local text = LoadFont(Var "LoadingScreen","credits") .. {
		-- it won't stick in the metrics
		InitCommand=cmd(zoom,0.65;shadowlength,0;diffuse,color("#000000");diffusetopedge,0.6,0.6,0.6,1);
		RefreshCreditTextMessageCommand=update;
		CoinInsertedMessageCommand=update;
		PlayerJoinedMessageCommand=update;
		ScreenChangedMessageCommand=UpdateVisible;
	};
	return text;
end

local t = Def.ActorFrame {
	Def.ActorFrame{
		Def.Quad{
			InitCommand=cmd(x,THEME:GetMetric(Var "LoadingScreen","MessageFrameX");y,THEME:GetMetric(Var "LoadingScreen","MessageFrameY");zoomto,SCREEN_WIDTH,SCREEN_HEIGHT/8;diffuse,color("0,0,0,0.8");diffusealpha,0);
			OnCommand=cmd(draworder,-1);
			SystemMessageMessageCommand=function(self,params)
				self:finishtweening();
				self:linear(0.5);
				self:diffusealpha(0.5);
				self:sleep(2.75);
				self:linear(0.25);
				self:diffusealpha(0);
			end;
			HideSystemMessageMessageCommand=cmd(finishtweening);
		};

		LoadFont("_misoreg hires") .. {
			InitCommand=cmd(
				maxwidth,750;
				horizalign,left;
				vertalign,top;
				zoom,0.8;
				shadowlength,1;
				y,SCREEN_TOP+20;
				diffusealpha,0;
				strokecolor,color("0,0,0,0.25");
			);

			SystemMessageMessageCommand = function(self, params)
				self:settext( params.Message );
				local f = cmd(finishtweening;x,SCREEN_LEFT+20;diffusealpha,1); f(self);
				self:playcommand( "On" );
				if params.NoAnimate then
					self:finishtweening();
				end
				f = cmd(sleep,3;linear,0.25;diffusealpha,0); f(self);
				self:playcommand( "Off" );
			end;
			HideSystemMessageMessageCommand = cmd(finishtweening);
		};
	};

	Def.ActorFrame{
		CreditsText( PLAYER_1 ) .. {
			InitCommand=cmd(x,THEME:GetMetric(Var "LoadingScreen","CreditsP1X");y,THEME:GetMetric(Var "LoadingScreen","CreditsP1Y");horizalign,left;diffuse,PlayerColor(PLAYER_1);shadowlength,0;strokecolor,color("0,0,0,0.5"););
		};
	};

	Def.ActorFrame{
		CreditsText( PLAYER_2 ) .. {
			InitCommand=cmd(x,THEME:GetMetric(Var "LoadingScreen","CreditsP2X");y,THEME:GetMetric(Var "LoadingScreen","CreditsP2Y");horizalign,right;diffuse,PlayerColor(PLAYER_2);shadowlength,0;strokecolor,color("0,0,0,0.5"));
		};
	};
};

return t;
