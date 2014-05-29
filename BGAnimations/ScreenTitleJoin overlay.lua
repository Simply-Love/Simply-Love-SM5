return Def.ActorFrame{
	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenTitleJoin", "Press Start");
		InitCommand=cmd(queuecommand,"Refresh");
		OnCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_BOTTOM-100; zoom,0.95; diffuseblink; effectperiod,0.5; effectcolor1,1,1,1,0; effectcolor2,1,1,1,1);
		CoinsChangedMessageCommand=cmd(playcommand,"Refresh");
		RefreshCommand=function(self)
			local Credits = GetCredits();
			if Credits["Credits"] < 1 then
				self:visible(false);
			else
				self:visible(true);
			end		
		end
	};
};