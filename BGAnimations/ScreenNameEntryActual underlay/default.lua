-- Why bother having two distinct name entry screens?  Well, sit down, and I'll tell you a story...

-- ScreenNameEntryTraditional has certain very helpful methods that are only available to it.
-- GetEnteringName() is only available to ScreenNameEntryTraditional and is used to determine
-- which players, if any, are entering highscore names.

-- One thing that ScreenNameEntryTraditional lacks, however, is the ability to listen for message commands
-- like MenuRightP1MessageCommand and MenuLeftP2MessageCommand. Those are very helpful when you want a player
-- to be able to hold down a menu button to contine scrolling through letters.
-- I did try, briefly, to set codes in Metrics for "held" and "released" menubuttons to recreate this functionality,
-- but the results were less than satisfactory.

-- So, use ScreenNameEntryTraditional to determine which players are entering highscore names, set an env value,
-- and proceed to ScreenNameEntryActual.  On ScreenNameEntryActual, have players enter their names if necessary,
-- and eventually save those names using GAMESTATE:StoreRankingName()


local Players = GAMESTATE:GetHumanPlayers();

-- This env value is a table containing a boolean value for keys {P1, P2}
-- that was set on ScreenNameEntryTraditional underlay.lua
local Entering = getenv("PlayersEnteringHighScoreNames");

-- get the number of stages that were played
local numStages = STATSMAN:GetStagesPlayed();

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
	
		-- set this back to nil now
		setenv("PlayersEnteringHighScoreNames", nil);
	end;
};


for pn in ivalues(Players) do
	t[#t+1] = LoadActor("alphabet", {pn, Entering[ToEnumShortString(pn)]} );
	t[#t+1] = LoadActor("highScores", pn);
end 

--
return t