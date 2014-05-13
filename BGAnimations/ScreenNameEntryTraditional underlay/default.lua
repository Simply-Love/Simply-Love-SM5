local Players = GAMESTATE:GetHumanPlayers();
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