local t = Def.ActorFrame{

	LoadActor("colored_banners/banner"..SimplyLoveColor()..".png")..{
		Name="FallbackBanner";
		OnCommand=function(self)
			self:xy((SCREEN_CENTER_X - SCREEN_WIDTH/WideScale(4, 4.75) ), 112);
			self:zoom(WideScale(0.725,0.8));
		end;
		OffCommand=cmd(diffusealpha,0);
		-- CurrentSongChangedMessageCommand=function(self)
		-- 	
		-- 	local song = GAMESTATE:GetCurrentSong();
		-- 	if song then
		-- 		local banner = song:HasBanner();
		-- 	
		-- 		if banner then
		-- 			self:diffusealapha(0);
		-- 		else
		-- 			self:diffusealapha(1);
		-- 		end
		-- 	end
		-- end;
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