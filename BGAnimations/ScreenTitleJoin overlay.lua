return LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
	InitCommand=function(self)
		self:xy(_screen.cx,_screen.h-80):zoom(0.7):shadowlength(0.75)
		self:visible(false):queuecommand("Refresh")
	end,
	OnCommand=function(self)
		self:diffuseshift():effectperiod(1.333)
		self:effectcolor1(1,1,1,0):effectcolor2(1,1,1,1)
	end,
	OffCommand=function(self) self:visible(false) end,

	CoinsChangedMessageCommand=function(self) self:queuecommand("Refresh") end,
	CoinModeChangedMessageCommand=function(self) self:queuecommand("Refresh") end,

	RefreshCommand=function(self)
		self:visible( not IsHome() )

		if GAMESTATE:GetCoinMode() == "CoinMode_Free" then
		 	self:settext( THEME:GetString("ScreenTitleJoin", "Press Start") )
			return
		end

		if GetCredits().Credits <= 0 then
			self:settext( THEME:GetString("ScreenLogo", "EnterCreditsToPlay") )
		else
		 	self:settext( THEME:GetString("ScreenTitleJoin", "Press Start") )
		end
	end
}