local Players = GAMESTATE:GetHumanPlayers();
local Entering = getenv("PlayersEnteringHighScoreNames");

-- get the number of stages that were played
local numStages = STATSMAN:GetStagesPlayed();


-- This loop determines which players, if any, are able to enter a high score name.
-- I chose NOT to use StageStats:PlayerHasHighScore(pn) to determine this
-- because it always caused an SM crash if either player had late-joined (no matter what I tried).
-- Instead, I use HighScore:IsFillInMarker()

-- for pn in ivalues(Players) do
-- 	
-- 	-- Attempt to get a player profile.
-- 	-- If there isn't one, use the machine profile for this player.
-- 	local profile = GetPlayerOrMachineProfile(pn);
-- 	
-- 	for i=numStages,1,-1 do
-- 		local stageStats = STATSMAN:GetPlayedStageStats(i);
-- 		
-- 		if stageStats then
-- 			local song = stageStats:GetPlayedSongs()[1];
-- 			
-- 			if stageStats then
-- 				local playerStageStats = stageStats:GetPlayerStageStats(pn);
-- 
-- 				if playerStageStats then
-- 					local steps = playerStageStats:GetPlayedSteps()[i];
-- 					if song and steps then
-- 						local highScoreList = profile:GetHighScoreList(song, steps):GetHighScores();
-- 		
-- 						Trace("\n\n")
-- 						Trace(ToEnumShortString(pn))
-- 						Trace("-------------------------------------------------")
-- 
-- 						for scoreNum=1,#highScoreList do
-- 							score = highScoreList[scoreNum];
-- 							
-- 							Trace(score:GetName() .. " " .. score:GetScore() .. " " .. tostring(score:IsFillInMarker()))
-- 							
-- 							if score then
-- 								if score:IsFillInMarker() then
-- 									Entering[ToEnumShortString(pn)] = true;
-- 								end
-- 							end
-- 						end
-- 						
-- 						Trace("-------------------------------------------------")
-- 						Trace("\n\n")
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end


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
	DoneEnteringNameP1MessageCommand=function(self)
		Entering.P1 = false;
		self:queuecommand("AttemptToFinish");
	end;
	DoneEnteringNameP2MessageCommand=function(self)
		Entering.P2 = false;
		self:queuecommand("AttemptToFinish");
	end;
	CodeMessageCommand=function(self, params)
		if params.Name == "Enter" then
			self:queuecommand("AttemptToFinish");
		end
	end;
	AttemptToFinishCommand=function(self)
		local AnyEntering = false;
		
		if Entering.P1 or Entering.P2 then
			AnyEntering = true
		end
		
		if not AnyEntering then
			self:playcommand("Finish");
		end
	end;
	MenuTimerExpiredMessageCommand=function(self, param)
		self:playcommand("Finish");
	end;
	FinishCommand=function(self)
		-- manually transition to the next screen (defined in Metrics)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen");
	end;
	OffCommand=function(self)
		for pn in ivalues(Players) do
			local playerName = getenv("HighScoreName" .. ToEnumShortString(pn));
			if playerName then
				
				-- actually store the HighScoreName
				GAMESTATE:StoreRankingName(pn, playerName);
				
				-- if the player is using a profile, set a LastUsedHighScoreName for him/her
				if PROFILEMAN:IsPersistentProfile(pn) then
					PROFILEMAN:GetProfile(pn):SetLastUsedHighScoreName(playerName);
				end
			end
		end
	
		-- set these back to nil now
		setenv("HighScoreNameP1", nil);
		setenv("HighScoreNameP2", nil);
		setenv("PlayersEnteringHighScoreNames", nil);
	end;
};


for pn in ivalues(Players) do
	t[#t+1] = LoadActor("alphabet", {pn, Entering[ToEnumShortString(pn)]} );
	t[#t+1] = LoadActor("highScores", pn);
end 

--
return t