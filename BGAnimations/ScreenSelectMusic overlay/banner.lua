local t = Def.ActorFrame{

	LoadActor("colored_banners/banner"..SimplyLoveColor()..".png")..{
		Name="FallbackBanner";
		OnCommand=function(self)
			self:xy((SCREEN_CENTER_X - SCREEN_WIDTH/WideScale(4, 4.75) ), 112);
			self:setsize(418,164);
			self:zoom(WideScale(0.725,0.8));
		end;
		HideCommand=cmd(visible,false);
		ShowCommand=cmd(visible,true);
	};
	

	Def.ActorProxy{
		Name="BannerProxy";
		OnCommand=function(self)
			self:xy((SCREEN_CENTER_X - SCREEN_WIDTH/WideScale(4, 4.75) ), 112);
			self:zoom(WideScale(0.725,0.8));
		end;
		BeginCommand=function(self)
			local banner = SCREENMAN:GetTopScreen():GetChild('Banner');
			self:SetTarget(banner);
		end;
	};
};


return t;