local sStage = "";
local iSongsPerPlay = PREFSMAN:GetPreference("SongsPerPlay")
local iAdditionalSongs = 0;

local t = Def.ActorFrame{
	InitCommand=cmd(queuecommand,"FigureStuffOut");
	FigureStuffOutCommand=function(self)
	
		if not PREFSMAN:GetPreference("EventMode") then
		
			sStage = THEME:GetString("Stage", "Stage") .. " " .. tostring(iSongsPerPlay - SL_SongsRemaining + 1);
			local topscreen = SCREENMAN:GetTopScreen();
			
			if topscreen then
				if topscreen:GetName() == "ScreenEvaluationStage" then
					local song = GAMESTATE:GetCurrentSong();
					if song then
						if song:IsLong() then iAdditionalSongs = 1 end
						if song:IsMarathon() then iAdditionalSongs = 2 end
					end
				end
			end
			
			if SL_SongsRemaining - iAdditionalSongs <= 1 then
				sStage = THEME:GetString("Stage", "Final");
			end
		else
			sStage = THEME:GetString("Stage", "Event");
		end
		
		self:GetChild("Stage Number"):playcommand("Text");
	end;

	
	Def.Quad{
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_TOP;zoomto,SCREEN_WIDTH,40; diffuse,color("0.65,0.65,0.65,1"));
	};
	
	LoadFont("_wendy small") .. {
		Name="HeaderText";
		InitCommand=cmd(zoom,WideScale(0.5, 0.6); x,16; horizalign,left; diffusealpha,0; settext,ScreenString("HeaderText"););
		OnCommand=cmd(decelerate,0.5; diffusealpha,1);
		OffCommand=cmd(accelerate,0.5;diffusealpha,0);
	};
	
	LoadFont("_wendy small")..{
		Name="Stage Number";
		InitCommand=cmd(diffusealpha,0; zoom,WideScale(0.5,0.6); xy,SCREEN_CENTER_X, SCREEN_TOP);
		TextCommand=cmd(settext, sStage);
		OnCommand=cmd(decelerate,0.5; diffusealpha,1);
		OffCommand=cmd(accelerate,0.5;diffusealpha,0);
	};
};

return t;