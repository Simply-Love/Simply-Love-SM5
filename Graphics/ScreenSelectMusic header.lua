local sStage = "";

local t = Def.ActorFrame{
	InitCommand=cmd(queuecommand,"FigureStuffOut");
	FigureStuffOutCommand=function(self)
	
		if not PREFSMAN:GetPreference("EventMode") then
	
			local Players = GAMESTATE:GetHumanPlayers();
			local iStagesLeft = math.huge;

			-- GAMESTATE:GetNumStagesLeft() asks for a playernumber because latejoin can
			-- cause discrepencies between players.  For Simply Love, we only care about
			-- which player has fewer stages remaining; we use that value for both.
			for pn in ivalues(Players) do
				local iPlayerStagesLeft = GAMESTATE:GetNumStagesLeft(pn)
	
				if iStagesLeft > iPlayerStagesLeft then
					iStagesLeft = iPlayerStagesLeft;
				end
			end

			local iSongsPerPlay = PREFSMAN:GetPreference("SongsPerPlay");
			local iStageNumber = (iSongsPerPlay - iStagesLeft);
	
			-- This file produces the header for ScreenSelectMusic and ScreenEvaluationStage.
			local topscreen = SCREENMAN:GetTopScreen();
			if topscreen then
				
				-- iStageNumber could be 0, which would read as "Stage 0"
				-- Add 1 here for display purposes.
				if topscreen:GetName() == "ScreenSelectMusic" then
					iStageNumber = iStageNumber + 1;
				end
				
				-- The internal StageNumber has already incremented 1 by ScreenEvalutionStage.
				-- Subtract the appropriate amount  (2, 1, or 0) from that StageNumber for display purposes.
				if topscreen:GetName() == "ScreenEvaluationStage" then
					local CurrentSong = GAMESTATE:GetCurrentSong();
					local bIsLong = CurrentSong:IsLong();
					local bIsMarathon = CurrentSong:IsMarathon();
					local iAdditionalStagesThisSongCountsFor = bIsLong and 1 or bIsMarathon and 2 or 0;
					
					iStageNumber = iStageNumber - iAdditionalStagesThisSongCountsFor;
				end
			end
	
			sStage = THEME:GetString("Stage", "Stage") .. " " .. tostring(iStageNumber);

			if iStageNumber >= iSongsPerPlay then
				sStage = THEME:GetString("Stage", "Final");
			end;
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