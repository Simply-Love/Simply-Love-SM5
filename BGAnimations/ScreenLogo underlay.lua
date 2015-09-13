local t = Def.ActorFrame{}

local game = GAMESTATE:GetCurrentGame():GetName()
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

t[#t+1] = LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy-16):zoom( game=="pump" and 0.2 or 0.205 ):cropright(1)
	end,
	OnCommand=function(self)
		self:linear(0.33):cropright(0)
	end
}

t[#t+1] = LoadActor(THEME:GetPathB("ScreenTitleMenu","underlay/SimplyLove (doubleres).png"))..{
	InitCommand=cmd(x, _screen.cx+2; y, _screen.cy; diffusealpha, 0; zoom, 0.7),
	OnCommand=cmd(linear,0.5; diffusealpha, 1)
}

local af = Def.ActorFrame{
	OnCommand=cmd(queuecommand,"Refresh"),
	CoinModeChangedMessageCommand=cmd(queuecommand,"Refresh"),
	RefreshCommand=function(self)
		self:visible(true)
		self:diffuseshift()
		self:effectperiod(1)
		self:effectcolor1(1,1,1,0)
		self:effectcolor2(1,1,1,1)
	end,
	OffCommand=cmd(visible,false),


	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenLogo", "EnterCreditsToPlay"),
		InitCommand=cmd(xy,_screen.cx,SCREEN_BOTTOM-100; zoom,0.525; visible,false),
		RefreshCommand=function(self)
			local credits = GetCredits()
			self:visible( GAMESTATE:GetCoinMode() == "CoinMode_Pay" and credits.Credits <= 0 )
		end
	},

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenTitleJoin", "Press Start"),
		InitCommand=cmd(xy,_screen.cx, _screen.h-80; zoom,0.715; visible,false),
		RefreshCommand=function(self)
			local credits = GetCredits()
			self:visible( (GAMESTATE:GetCoinMode() == "CoinMode_Pay" and credits.Credits > 0) or GAMESTATE:GetCoinMode() == "CoinMode_Free")
		end
	},

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenSelectMusic","Start Button"),
		InitCommand=cmd(x,_screen.cx - 12; y,_screen.h - 125; zoom,1.1; visible,false),
		RefreshCommand=function(self)
			local credits = GetCredits()
			self:visible( (GAMESTATE:GetCoinMode() == "CoinMode_Pay" and credits.Credits > 0) or GAMESTATE:GetCoinMode() == "CoinMode_Free")
		end
	}
}

t[#t+1] =  af

return t