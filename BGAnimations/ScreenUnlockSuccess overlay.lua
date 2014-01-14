local path = getenv("NewlyUnlockedSong");
local song;

if path then
	song = SONGMAN:FindSong(path);
end



local t =  Def.ActorFrame{
	OnCommand=function(self)
		
		if song then
			self:GetChild("songUnlocked"):play();
		end
		
	end;
};


t[#t+1] = Def.Sprite{
	Name="Banner";
	InitCommand=cmd(xy, SCREEN_CENTER_X, SCREEN_CENTER_Y-55);
	OnCommand=function(self)
		
		if song then
			 bannerpath = song:GetBannerPath();
		end;			
		
		if bannerpath then
			self:LoadBanner(bannerpath);			
			self:setsize(418,164);
			self:zoom(0.6);
		end;
	end;
};
	
t[#t+1] = LoadFont("_misoreg hires")..{
	Name="RewardText";
	InitCommand=cmd(xy, SCREEN_CENTER_X, 110; zoom,1.25);
	OnCommand=function(self)
		if song then
			self:settext("You have unlocked: "..path)
		end
	end;
}


t[#t+1] = LoadActor( THEME:GetPathS("", "_unlock.ogg")	)..{ Name="songUnlocked"; };


return t;