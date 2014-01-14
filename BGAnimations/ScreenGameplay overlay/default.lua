-- Gameplay overlay.


-- SongNumber(pn)
-- Returns a text actor with the current song number.
local function SongNumber(pn)
	return LoadFont("_misoreg hires")..{
		InitCommand=cmd(shadowlength,1;NoStroke);
		BeginCommand=function(self)
			self:horizalign( pn == PLAYER_1 and right or left );

			-- [d1 v1.4] make the number a different color in endless
			local pm = GAMESTATE:GetPlayMode();
			if pm == "PlayMode_Endless" then
				self:diffuse( color("1,0.796,0.398,1") );	-- gold
			else
				self:diffuse( color("1,1,1,1") );			-- white
			end;

			self:visible( GAMESTATE:IsSideJoined(pn) or GAMESTATE:IsPlayerEnabled(pn) );
			self:playcommand("Update");
		end;

		UpdateCommand=function(self)
			if not GAMESTATE:IsCourseMode() then return; end;
			local proxy = SCREENMAN:GetTopScreen():GetChild('SongNumber'..pname(pn));
			if proxy then self:settext( proxy:GetText() ); end;
		end;

		CurrentSongChangedMessageCommand=cmd(playcommand,"Update");

		PlayerFailedMessageCommand=function(self,params)
			if params.PlayerNumber == pn then
				self:accelerate(1);
				self:diffuse( color("1,0,0,1") );
			end;
		end;
	};
end;

local t = Def.ActorFrame{
	
	InitCommand=cmd(addy,-10);
	
	
	-- thanks shake
	Def.ActorFrame{
		Name="SongMeter";
		InitCommand=cmd(x,SCREEN_CENTER_X; y,SCREEN_TOP+30; draworder,95; diffusealpha,0);
		OnCommand=cmd(decelerate,0.2; diffusealpha,1);

		Def.SongMeterDisplay {
			StreamWidth=SCREEN_WIDTH/2.1;
			Stream=Def.Quad{ InitCommand=cmd(zoomy,20;diffuse,DifficultyIndexColor(2) ); };
		};
		
		Border(SCREEN_WIDTH/2.1, 24, 2);
	};






	-- song info
	Def.ActorFrame{
		Name="SongInfoFrame";
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+30;draworder,95;);

		LoadFont("_misoreg hires")..{
			Name="SongName";
			InitCommand=cmd(zoom,0.8; shadowlength,1; maxwidth,SCREEN_WIDTH/2.5 - 10; NoStroke);
			OffCommand=cmd(linear,0.2;diffusealpha,0);
			CurrentSongChangedMessageCommand=cmd(playcommand,"Update");
			UpdateCommand=function(self)
				local title;
				local song = GAMESTATE:GetCurrentSong();

				if song then
					if GAMESTATE:IsCourseMode() then
						title = GAMESTATE:GetCurrentCourse():GetDisplayFullTitle();
					else
						title = song:GetDisplayFullTitle();
					end;
				end;

				-- DVNO
				-- is four capital letters
				-- printed in gold.
				if title == "DVNO" then
					local attribDVNO = {
						Length = 4;
						Diffuse = color("1,0.8,0,1");
					};
					self:AddAttribute(0,attribDVNO);
				end;

				self:settext(title);				
			end;
		};
	};





	--[[ begin p1 ]]
	-- p1 life
	LoadActor("lifemeter",PLAYER_1)..{
		InitCommand=cmd(x,SCREEN_CENTER_X*0.25;y,SCREEN_TOP+30;draworder,98);
	};
	

	-- colored background for player 1's chart's difficulty meter
	Def.Quad{
		InitCommand=cmd(zoomto, 30, 30; xy, 30, 66 );
		OnCommand=function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(PLAYER_1));
						
			if GAMESTATE:IsHumanPlayer(PLAYER_1) then
				local currentSteps = GAMESTATE:GetCurrentSteps(PLAYER_1);
				if currentSteps then
					local currentDifficulty = currentSteps:GetDifficulty();
					self:diffuse(DifficultyColor(currentDifficulty));
				end
			end
		end;
	};								

	-- player 1's chart's difficulty meter
	LoadFont("_wendy small")..{
		InitCommand=cmd(diffuse, color("#000000"); xy, 30, 66 zoom, 0.45 );
		OnCommand=function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(PLAYER_1));	
		end;
		BeginCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
			local meter = steps:GetMeter();
		
			if meter then	
				self:settext(meter)
			end
		end;
	};


	-- p1 song number
	SongNumber(PLAYER_1)..{
		Name="P1SongNum";
		InitCommand=cmd(x,SCREEN_CENTER_X-12;y,SCREEN_TOP+26;draworder,99);
		OffCommand=cmd(linear,0.2;diffusealpha,0);
	};
	LoadFont("_wendy fixedWidth")..{
		Name="P1Score";
		Text="0.00";
		InitCommand=cmd(x,SCREEN_CENTER_X * 0.65; y,SCREEN_TOP+66; halign,1; zoom,0.6);
		OnCommand=function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(PLAYER_1))
		end;
		JudgmentMessageCommand=function(self, param)
			if GAMESTATE:IsPlayerEnabled(PLAYER_1) then	
				local percent = FormatPercentScore(STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetPercentDancePoints());
				percent = string.sub(percent,1,-2);
				self:settext(percent);
				
				if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
					local dpP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetPercentDancePoints();
					local dpP2 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2):GetPercentDancePoints();
					
					if dpP1 > dpP2 then
						self:diffusealpha(1);
						self:GetParent():GetChild("P2Score"):diffusealpha(0.65);
					elseif dpP2 > dpP1 then
						self:diffusealpha(0.65);
						self:GetParent():GetChild("P2Score"):diffusealpha(1);
					end
				end
			end
		end;
	};

	
	--[[ end p1 ]]
	
	
	
	
	
	
	

	--[[ begin p2 ]]
	-- p2 life
	LoadActor("lifemeter",PLAYER_2)..{
		InitCommand=cmd(x,SCREEN_CENTER_X*1.75;y,SCREEN_TOP+30;draworder,98);
	};
	
	-- colored background for player 2's chart's difficulty meter
	Def.Quad{
		InitCommand=cmd(zoomto, 30, 30; xy, SCREEN_WIDTH-30, 66 );
		OnCommand=function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(PLAYER_2));
			
			if GAMESTATE:IsHumanPlayer(PLAYER_2) then
				local currentSteps = GAMESTATE:GetCurrentSteps(PLAYER_2);
				if currentSteps then
					local currentDifficulty = currentSteps:GetDifficulty();
					self:diffuse(DifficultyColor(currentDifficulty));
				end
			end
		end;
	};								

	-- player 2's chart's difficulty meter
	LoadFont("_wendy small")..{
		InitCommand=cmd(diffuse, color("#000000"); xy, SCREEN_WIDTH-30, 66 zoom, 0.45 );
		OnCommand=function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(PLAYER_2));
		end;
		BeginCommand=function(self)			
			local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
			if steps then
				local meter = steps:GetMeter();
		
				if meter then	
					self:settext(meter)
				end
			end
		end;
	};
		
	
	-- p2 song number
	SongNumber(PLAYER_2)..{
		Name="P2SongNum";
		InitCommand=cmd(x,SCREEN_CENTER_X+12;y,SCREEN_TOP+26;draworder,99);
		OffCommand=cmd(linear,0.2;diffusealpha,0);
	};
	LoadFont("_wendy fixedWidth")..{
		Name="P2Score";
		Text="0.00";
		InitCommand=cmd(x,SCREEN_CENTER_X * 1.65; y,SCREEN_TOP+66; halign,1; zoom,0.6);
		OnCommand=function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(PLAYER_2))
		end;
		JudgmentMessageCommand=function(self, param)
			if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
				local percent = FormatPercentScore(STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2):GetPercentDancePoints());
				percent = string.sub(percent,1,-2);
				self:settext(percent);
			end
		end;
	};
	--[[ end p2 ]]
};



t[#t+1] = LoadActor("BPMDisplay");


return t;