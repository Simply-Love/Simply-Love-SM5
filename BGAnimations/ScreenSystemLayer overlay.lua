-- This is mostly copy/pasted directly from SM5's _fallback theme with
-- very minor modifications.

local function CreditsText( pn )
	local text = LoadFont("_miso") .. {
		InitCommand=function(self)
			self:visible(false)
			self:name("Credits" .. PlayerNumberToString(pn))
			ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen")
		end;
		UpdateTextCommand=function(self)
			local str = ScreenSystemLayerHelpers.GetCreditsMessage(pn)
			self:settext(str)
		end;
		UpdateVisibleCommand=function(self)
			local screen = SCREENMAN:GetTopScreen()
			local bShow = true
			if screen then
				local sClass = screen:GetName()
				bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" )
			end

			self:visible( bShow )
		end
	}
	return text
end


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
	SystemMessageMessageCommand=function(self, params)
		self:GetChild("Text"):settext( params.Message )
		self:playcommand( "On" )
		if params.NoAnimate then
			self:finishtweening()
		end
		self:playcommand( "Off" )
	end,
	HideSystemMessageMessageCommand=cmd(finishtweening),

	Def.Quad {
		InitCommand=cmd(zoomto,_screen.w, 30; horizalign,left; vertalign,top; diffuse, Color.Black; diffusealpha,0 ),
		OnCommand=cmd(finishtweening; diffusealpha,0.85 ),
		OffCommand=cmd(sleep,3; linear,0.5; diffusealpha,0 )
	},

	LoadFont("_miso")..{
		Name="Text",
		InitCommand=cmd(maxwidth,750; horizalign,left; vertalign,top; xy,SCREEN_LEFT+10, 10; diffusealpha,0),
		OnCommand=cmd(finishtweening; diffusealpha,1; zoom,0.8 ),
		OffCommand=cmd(sleep,3; linear,0.5; diffusealpha,0 )
	}
}

-- Centered Credit Text
t[#t+1] = LoadFont("_wendy small")..{
	InitCommand=cmd(xy, _screen.cx, _screen.h-16; zoom,0.5; horizalign,center ),

	OnCommand=cmd(playcommand,"Refresh"),
	ScreenChangedMessageCommand=cmd(playcommand,"Refresh"),
	CoinModeChangedMessageCommand=cmd(playcommand,"Refresh"),
	CoinsChangedMessageCommand=cmd(playcommand,"Refresh"),

	RefreshCommand=function(self)

		local screen = SCREENMAN:GetTopScreen()
		local bShow = true
		if screen then
			local sClass = screen:GetName()
			bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" )

			-- hide  just this centered credit text for certain screens,
			-- where it would more likely just be distracting and superfluous
			if sClass == "ScreenPlayerOptions"
				or sClass == "ScreenPlayerOptions2"
				or sClass == "ScreenEvaluationStage"
				or sClass == "ScreenEvaluationNonstop"
				or sClass == "ScreenEvaluationSummary"
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

			text = text..credits.Credits..'  '

			if credits.CoinsPerCredit > 1 then
				text = text .. credits.Remainder .. '/' .. credits.CoinsPerCredit
			end
			self:settext(text)

		elseif GAMESTATE:GetCoinMode() == "CoinMode_Free" then
			self:settext('FREE PLAY')

		elseif GAMESTATE:GetCoinMode() == "CoinMode_Home" then
			self:settext('')
		end
	end
}

--Bottom Bar Clock
t[#t+1] = LoadFont("_miso")..{
	InitCommand=cmd(x,_screen.cx;
					y,SCREEN_BOTTOM-16;
					zoom,1;horizalign,center;
	);
	OnCommand=cmd(playcommand,"Refresh");
	SelectMenuOpenedMessageCommand=cmd(accelerate,0.2;addy,-31);
	SelectMenuClosedMessageCommand=cmd(linear,0.3;addy,31);
	ScreenChangedMessageCommand=function(self)
		self:playcommand("Refresh");
	end;
	CoinModeChangedMessageCommand=cmd(playcommand,"Refresh");
	CoinsChangedMessageCommand=cmd(playcommand,"Refresh");
	PulseMessageCommand=cmd(playcommand,"Refresh");
	RefreshCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local bShow = true
		if screen then
			local sClass = screen:GetName()
			bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" )

			-- hide this centered credit text for certain screens,
			-- where it would more likely just be distracting and superfluous
			if sClass == "ScreenPlayerOptions"
				or sClass == "ScreenTitleMenu"
				or sClass == "ScreenEditMenu"
				or sClass == "ScreenEditOptions"
				or sClass == "ScreenMiniMenuMainMenu"
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

		--don't show the clock in Free Play or Coin mode, because these modes should have the free play/coins banner
		if GAMESTATE:GetCoinMode() == "CoinMode_Pay" or GAMESTATE:GetCoinMode() == "CoinMode_Free"
			then self:visible( false )
		end

		--as long as you're in event mode, the clock will be visible on the screens where it's not blacklisted
		if PREFSMAN:GetPreference("EventMode") or GAMESTATE:GetCoinMode() == "CoinMode_Home" then
			self:settext(string.format('%2ih %02im %02i %s %02i %04i', Hour(), Minute(), Second(), MonthToString(MonthOfYear()), DayOfMonth(), Year()))
			self:visible( bShow )
		end
	end;
}

--Pulse by second (used by the clock)
t[#t+1] = Def.ActorFrame {
	Def.Quad {
		PulseCommand=function(self) MESSAGEMAN:Broadcast("Pulse"); self:sleep(1); self:queuecommand("Pulse"); end;
		InitCommand=cmd(visible,false;playcommand,"Pulse");
	};
};

return t
