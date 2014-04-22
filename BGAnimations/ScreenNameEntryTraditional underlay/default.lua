local Players = GAMESTATE:GetHumanPlayers();

-- get the number of stages that were played
local numStages = STATSMAN:GetStagesPlayed();
local durationPerSong = 3;


local t = Def.ActorFrame {};

t[#t+1] = Def.ActorFrame {
	
	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/banner"..SimplyLoveColor()..".png"))..{
		OnCommand=cmd(xy, SCREEN_CENTER_X, 121.5; zoom, 0.7);
	};
	
	Def.Quad{
		Name="LeftMask";
		InitCommand=cmd(halign,0);
		OnCommand=function(self)
			self:xy(0,SCREEN_CENTER_Y);
			self:zoomto(SCREEN_CENTER_X-272, SCREEN_HEIGHT);
			self:MaskSource();
		end;
	};
	
	Def.Quad{
		Name="CenterMask";
		OnCommand=function(self)
			self:Center();
			self:zoomto(110, SCREEN_HEIGHT);
			self:MaskSource();
		end;
	};
	
	Def.Quad{
		Name="RightMask";
		InitCommand=cmd(halign,1);
		OnCommand=function(self)
			self:xy(SCREEN_WIDTH,SCREEN_CENTER_Y);
			self:zoomto(SCREEN_CENTER_X-272, SCREEN_HEIGHT);
			self:MaskSource();
		end;
	};

};


if GAMESTATE:IsCourseMode() then
	
	t[#t+1] = Def.Sprite{
		Name="CourseBanner";
		InitCommand=cmd(xy, SCREEN_CENTER_X, 121.5; );
		OnCommand=function(self)
			local course, banner;
			course = GAMESTATE:GetCurrentCourse();
						
			if course then
				 bannerpath = course:GetBannerPath();
			end;			
			
			if bannerpath then
				self:LoadBanner(bannerpath);			
				self:setsize(418,164);
				self:zoom(0.7);
			end;
		end;
	};
	
else

	for i=numStages,1,-1 do
	
		local stageStats = STATSMAN:GetPlayedStageStats(i);
	
		if stageStats then
		
			local song = stageStats:GetPlayedSongs()[1];
		
			t[#t+1] = Def.Sprite{
				Name="Banner"..i;
				InitCommand=cmd(xy, SCREEN_CENTER_X, 121.5; diffusealpha, 0; );
				OnCommand=function(self)
		
					if song then
						 bannerpath = song:GetBannerPath();
					end;			
		
					if bannerpath then
						self:LoadBanner(bannerpath);			
						self:setsize(418,164);
						self:zoom(0.7);
					end;
				
					self:sleep(durationPerSong * (math.abs(i-numStages)) );
					self:queuecommand("Display");
				end;
				DisplayCommand=function(self)				
					self:diffusealpha(1);
					self:sleep(durationPerSong);
					self:diffusealpha(0);
					self:queuecommand("Wait");
				end;
				WaitCommand=function(self)
					self:sleep(durationPerSong * (numStages-1))
					self:queuecommand("Display")
				end;
			};
		
		end
	end

end




t[#t+1] = Def.Actor {
	MenuTimerExpiredMessageCommand=function(self, param)
		for pn in ivalues(Players) do
			SCREENMAN:GetTopScreen():Finish(pn);
		end
	end;
	CodeMessageCommand=function(self,param)
		if param.Name == "Enter" then
			
			--if no one even has a high score, Finish() any available players
			if not SCREENMAN:GetTopScreen():GetAnyEntering() then
				for pn in ivalues(Players) do
					SCREENMAN:GetTopScreen():Finish(pn);
				end
				
			-- else, at least one player IS entering a name
			-- but maybe not both!
			-- if either player should NOT be entering a name,
			-- apply the Finish() command as needed now
			else
				for pn in ivalues(Players) do
					if not SCREENMAN:GetTopScreen():GetEnteringName(pn) then
						SCREENMAN:GetTopScreen():Finish(pn);
					end
				end
			end
			
		end
	end;
};


for pn in ivalues(Players) do
	t[#t+1] = LoadActor("alphabet", pn);
	t[#t+1] = LoadActor("highScores", pn);
end 

--
return t