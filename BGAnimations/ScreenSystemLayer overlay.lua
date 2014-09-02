-- This is mostly copy/pasted directly from SM5's _fallback theme with
-- very minor modifications.

local function CreditsText( pn )
	local text = LoadFont("_misoreg hires") .. {
		InitCommand=function(self)
			self:visible(false);
			self:name("Credits" .. PlayerNumberToString(pn))
			ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen");
		end;
		UpdateTextCommand=function(self)
			local str = ScreenSystemLayerHelpers.GetCreditsMessage(pn);
			self:settext(str);
		end;
		UpdateVisibleCommand=function(self)
			local screen = SCREENMAN:GetTopScreen();
			local bShow = true;
			if screen then
				local sClass = screen:GetName();
				bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" );
			end

			self:visible( bShow );
		end
	};
	return text;
end;



local t = Def.ActorFrame {}


-- Aux
t[#t+1] = LoadActor(THEME:GetPathB("ScreenSystemLayer","aux"));


-- Credits
t[#t+1] = Def.ActorFrame {
 	CreditsText( PLAYER_1 );
	CreditsText( PLAYER_2 );
};


-- SystemMessage Text
t[#t+1] = Def.ActorFrame {
	Def.Quad {
		InitCommand=cmd(zoomtowidth,_screen.w;zoomtoheight,30;horizalign,left;vertalign,top;y,SCREEN_TOP;diffuse,color("0,0,0,0"));
		OnCommand=cmd(finishtweening;diffusealpha,0.85;);
		OffCommand=cmd(sleep,3;linear,0.5;diffusealpha,0;);
	};
	LoadFont("_misoreg hires") .. {
		Name="Text";
		InitCommand=cmd(maxwidth,750; horizalign,left; vertalign,top; xy,SCREEN_LEFT+10, 10; diffusealpha,0;);
		OnCommand=cmd(finishtweening;diffusealpha,1;zoom,0.8);
		OffCommand=cmd(sleep,3;linear,0.5;diffusealpha,0;);
	};
	SystemMessageMessageCommand = function(self, params)
		self:GetChild("Text"):settext( params.Message );
		self:playcommand( "On" );
		if params.NoAnimate then
			self:finishtweening();
		end
		self:playcommand( "Off" );
	end;
	HideSystemMessageMessageCommand = cmd(finishtweening);
};

-- Centered Credit Text
t[#t+1] = LoadFont("_wendy small")..{
	InitCommand=cmd(x,_screen.cx;
					y,SCREEN_BOTTOM-16;
					zoom,0.5;horizalign,center;
	);
	OnCommand=cmd(playcommand,"Refresh");
	ScreenChangedMessageCommand=function(self)
		self:playcommand("Refresh");
	end;
	CoinModeChangedMessageCommand=cmd(playcommand,"Refresh");
	CoinsChangedMessageCommand=cmd(playcommand,"Refresh");
	RefreshCommand=function(self)

		local screen = SCREENMAN:GetTopScreen()
		local bShow = true
		if screen then
			local sClass = screen:GetName()
			bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" )

			-- hide this centered credit text for certain screens,
			-- where it would more likely just be distracting and superfluous
			if sClass == "ScreenPlayerOptions"
				or sClass == "ScreenPlayerOptions2"
				or sClass == "ScreenEvaluationStage"
				or sClass == "ScreenEvaluationCourse"
				or sClass == "ScreenEvaluationSummary"
				or sClass == "ScreenNameEntryActual"
				or sClass == "ScreenNameEntryTraditional"
				or sClass == "ScreenGameOver" then
				bShow = false
			end
		end

		self:visible( bShow )

		if PREFSMAN:GetPreference("EventMode") then
			self:settext('EVENT MODE')

		elseif GAMESTATE:GetCoinMode() == "CoinMode_Pay" then
			local credits = GetCredits()
			local text ='CREDIT(S)  '

			if credits.Credits > 0 then
				 text = text..credits.Credits..'  '
			end

			text = text .. credits.Remainder .. '/' .. credits.CoinsPerCredit
			self:settext(text)

		elseif GAMESTATE:GetCoinMode() == "CoinMode_Free" then
			self:settext('FREE PLAY')

		elseif GAMESTATE:GetCoinMode() == "CoinMode_Home" then
			self:settext('')
		end
	end
}

return t