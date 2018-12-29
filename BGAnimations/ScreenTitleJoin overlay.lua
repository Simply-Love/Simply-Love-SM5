return Def.ActorFrame{
	InitCommand=cmd(playcommand,"Refresh"),
	OnCommand=cmd(diffuseblink; effectperiod,1; effectcolor1,1,1,1,0; effectcolor2,1,1,1,1),
	OffCommand=cmd(visible,false),
	CoinsChangedMessageCommand=cmd(playcommand,"Refresh"),
	RefreshCommand=function(self)
		if GAMESTATE:GetCoinMode() == "CoinMode_Pay" then
			local Credits = GetCredits()
			if Credits["Credits"] < 1 then
				self:visible(false)
			else
				self:visible(true)
			end
		end
	end,

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenTitleJoin", "Press Start"),
		InitCommand=cmd(xy, _screen.cx, _screen.h-80; shadowlength,1; valign,0.5;),
		OnCommand=cmd(zoom,0.7),
	}
}
