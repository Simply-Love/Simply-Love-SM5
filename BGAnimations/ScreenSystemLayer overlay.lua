local function UpdateVisible(self)
	local screen = SCREENMAN:GetTopScreen();
	local bShow = true;
	if screen then
		local sClass = screen:GetName();
		bShow = THEME:GetMetric( sClass, "ShowCoinsAndCredits" );
	end

	self:visible( bShow );
end

local function CreditsText( pn )
	function update(self)
		local str = ScreenSystemLayerHelpers.GetCreditsMessage(pn);
		local screen = SCREENMAN:GetTopScreen();
		
		if screen then
			bAttract = screen:GetScreenType() == "ScreenType_Attract";
		end
		
		if not GAMESTATE:IsSideJoined(pn) and not bAttract and GAMESTATE:EnoughCreditsToJoin() then
			str = THEME:GetString("ScreenSystemLayer", "CreditsPressStart");
		end
			
		if MEMCARDMAN:GetCardState(pn) ~= "MemoryCardState_none" then
			if pn == PLAYER_1 then
				self:x(56);
			elseif pn == PLAYER_2 then
				self:x(-56);
			end
		end
			
		self:settext(str);
	end

	local text = LoadFont(Var "LoadingScreen","credits") .. {
		InitCommand=cmd(diffuse,color("#FFFFFF"););
		RefreshCreditTextMessageCommand=update;
		CoinInsertedMessageCommand=update;
		PlayerJoinedMessageCommand=update;
		ScreenChangedMessageCommand=function(self)
			local screen = SCREENMAN:GetTopScreen();
			local bShow = true;
			
			if screen then
				local sName = screen:GetName();
				bShow = THEME:GetMetric( sName, "ShowCoinsAndCredits" );
			end
			
			self:visible(bShow);
		end
	};
	return text;
end



local t = Def.ActorFrame {
	Def.ActorFrame{
		Def.Quad{
			InitCommand=cmd(x,THEME:GetMetric(Var "LoadingScreen","MessageFrameX");y,THEME:GetMetric(Var "LoadingScreen","MessageFrameY");zoomto,SCREEN_WIDTH,SCREEN_HEIGHT/8; diffuse,Color.Black; diffusealpha,0);
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
};


t[#t+1] = CreditsText( PLAYER_1 ) .. {
	InitCommand=cmd(x,THEME:GetMetric(Var "LoadingScreen","CreditsP1X");
					y,THEME:GetMetric(Var "LoadingScreen","CreditsP1Y");
					horizalign,left;shadowlength,0;strokecolor,color("0,0,0,0.5"););
};

t[#t+1] = CreditsText( PLAYER_2 ) .. {
	InitCommand=cmd(x,THEME:GetMetric(Var "LoadingScreen","CreditsP2X");
					y,THEME:GetMetric(Var "LoadingScreen","CreditsP2Y");
					horizalign,right;shadowlength,0;strokecolor,color("0,0,0,0.5"));
};



t[#t+1] = LoadFont("_wendy small")..{
	InitCommand=cmd(x,SCREEN_CENTER_X;
					y,THEME:GetMetric(Var "LoadingScreen","CreditsP2Y");
					zoom,0.5;horizalign,center;
	);
	OnCommand=cmd(queuecommand,"Refresh");
	ScreenChangedMessageCommand=function(self)
		UpdateVisible(self);
		self:queuecommand("Refresh");
	end;
	CoinModeChangedMessageCommand=cmd(playcommand,"Refresh");
	CoinsChangedMessageCommand=cmd(playcommand,"Refresh");
	RefreshCommand=function(self)
		if GAMESTATE:IsEventMode() then
			self:settext('EVENT MODE');
		elseif GAMESTATE:GetCoinMode()== "CoinMode_Free" then
			self:settext('FREE PLAY');
		elseif GAMESTATE:GetCoinMode()== "CoinMode_Home" then
			self:settext('');
		elseif GAMESTATE:GetCoinMode()== "CoinMode_Pay" then
			local coins=GAMESTATE:GetCoins();
			local coinsPerCredit=PREFSMAN:GetPreference('CoinsPerCredit');
			local credits=math.floor(coins/coinsPerCredit);
			local remainder=math.mod(coins,coinsPerCredit);
			local text ='CREDIT(S)  ';
		
			if credits > 0 then
				 text = text..credits..'  ';
			end
		
			text = text .. remainder .. '/' .. coinsPerCredit;
			self:settext(text)
		end
	end;
};

return t;
