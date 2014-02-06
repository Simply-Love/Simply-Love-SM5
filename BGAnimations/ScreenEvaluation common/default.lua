local t = Def.ActorFrame{
	
	
	-- quad behind the song/course title text
	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282F"); xy,SCREEN_CENTER_X, 54; zoomto, 292.5,20; );
	};

	-- song/course title text
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(CenterX; y,54; NoStroke;shadowlength,1;);
		OnCommand=function(self)	
			local songtitle = GAMESTATE:GetCurrentSong():GetDisplayFullTitle();
			if songtitle then
				self:settext(songtitle);
			end
		end;
	};
		
	
	
	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/banner"..SimplyLoveColor()..".png"))..{
		OnCommand=cmd(xy, SCREEN_CENTER_X, 121.5; zoom, 0.7);
	};
	
	--songs's banner, if it has one
	Def.Sprite{
		Name="Banner";
		InitCommand=cmd(xy, SCREEN_CENTER_X, 121.5);
		OnCommand=function(self)
			--these need to be declared as empty variables here
			--otherwise, the banner from round1 can persist into round2...
			local song, bannerpath;
			song = GAMESTATE:GetCurrentSong();
			
			if song then
				 bannerpath = song:GetBannerPath();
			end;			
			
			if bannerpath then
				self:LoadBanner(bannerpath);			
				self:setsize(418,164);
				self:zoom(0.7);
			end;
		end;
	};
	
	--quad behind the ratemod, if there is one
	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282F"); xy,SCREEN_CENTER_X, 170; zoomto, 292.5,20; );
		OnCommand=function(self)
			local songoptions = GAMESTATE:GetSongOptionsString();
			local ratemod = string.match(songoptions, "%d.%d");
			if not ratemod then
				self:visible(false);
			end
		end
	};
	
	--the ratemod, if there is on
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(xy,SCREEN_CENTER_X, 170; NoStroke;shadowlength,1;);
		OnCommand=function(self)	
			local songoptions = GAMESTATE:GetSongOptionsString();
			local ratemod = string.match(songoptions, "%d.%d");
			
			if ratemod then
				self:settext(ratemod .. "x Music Rate");
			else
				self:settext("");
			end
		end;
	};

	




	-- Player 1!
	Def.ActorFrame{
		Name="P1Results";
		BeginCommand=function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(PLAYER_1))
		end;
		OnCommand=function(self)
			if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
				self:addx(155)
			end
		end;


		--P1 has specitic elements "below the fold" that are centered when style is "double"
		--those are already handled, but not ALL of P1's elements should be centered...
		--here, we are wrapping those elements that we want to ALWAYS keep to the left of the screen
		--in an ActorFrame and applying addx(-155)
		Def.ActorFrame{
			OnCommand=function(self)
				if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
					self:addx(-155);
				end
			end;
			
			
		
			--letter grade
			LoadActor("letterGrade", PLAYER_1)..{
				InitCommand=cmd(x, SCREEN_CENTER_X-225; y,SCREEN_CENTER_Y-134;);
				OnCommand=cmd(zoom, 0.4);
			};
		
		
			--stepartist for player 1's chart
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(xy, SCREEN_CENTER_X-270, SCREEN_CENTER_Y-66; zoom, 0.65; horizalign, left;);
				BeginCommand=function(self)
					local stepartist;
					local cs = GAMESTATE:GetCurrentSteps(PLAYER_1);
				
					if cs then
						stepartist = cs:GetAuthorCredit();
					end
					self:settext(stepartist)
				end;
			};
			
			-- Record Texts
			LoadActor("recordTexts", PLAYER_1)..{
				InitCommand=cmd(xy, SCREEN_CENTER_X-224, SCREEN_CENTER_Y-80; zoom, 0.42; horizalign, left;);
			};
		
			-- colored background for player 1's chart's difficulty meter
			Def.Quad{
				InitCommand=cmd(zoomto, 30, 30; xy, SCREEN_CENTER_X-289.5, SCREEN_CENTER_Y-71 );
				OnCommand=function(self)			
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
				InitCommand=cmd(diffuse, color("#000000"); xy, SCREEN_CENTER_X-289.5, SCREEN_CENTER_Y-71; zoom, 0.5 );
				BeginCommand=function(self)
					local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
					local meter = steps:GetMeter();
				
					if meter then	
						self:settext(meter)
					end
				end;
			};
		};
		
	
		
		
		-- background quad for player stats
		Def.Quad{
			InitCommand=cmd(diffuse,color("#1E282F"); x, SCREEN_CENTER_X -155; y,SCREEN_CENTER_Y+34; zoomto, 300,180; );
		};
	
			
		LoadActor("judgeLabels", PLAYER_1)..{
			InitCommand=cmd(x, SCREEN_CENTER_X - 100; y,SCREEN_CENTER_Y-24);
		};
		
		-- dark background quad behind player percent score
		Def.Quad{
			InitCommand=cmd(diffuse,color("#101519"); x, SCREEN_CENTER_X - 225; y,SCREEN_CENTER_Y-26; zoomto, 160,60; );
		};
		
		-- percentage
		LoadActor("percentage", PLAYER_1)..{
			InitCommand=cmd(xy,SCREEN_CENTER_X-150, SCREEN_CENTER_Y-26; zoom,0.65; horizalign,right);
			OnCommand=function(self)
				-- Format the Percentage string, removing the % symbol
				local text = self:GetText();
				text = string.gsub(text, "%%", "");
				self:settext(text);
			end;
		};

		-- stages survived (course mode)
		LoadActor("stagesSurvived", PLAYER_1)..{
			InitCommand=cmd(x,SCREEN_WIDTH*0.2;y,SCREEN_CENTER_Y-136);
		};

		-- numbers
		LoadActor("judgeNumbers", PLAYER_1)..{
			InitCommand=cmd(x,SCREEN_CENTER_X-64; y, SCREEN_CENTER_Y-24; zoom, 0.8);
		};
		
		LoadActor("playerOptions", PLAYER_1)..{
			InitCommand=cmd(xy, SCREEN_CENTER_X -155, SCREEN_CENTER_Y+208;);
		};
		
		Def.GraphDisplay{
			InitCommand=function(self)
				self:Load("GraphDisplay");
				self:xy(SCREEN_CENTER_X -155, SCREEN_CENTER_Y+153);
				self:zoomto(300,60);
			end;
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1);
				local stageStats = STATSMAN:GetCurStageStats();
				self:Set(stageStats, playerStageStats);
				self:GetChild("Line"):diffusealpha(0);			
			end
		};
		
		Def.Quad{
			InitCommand=cmd(xy, SCREEN_CENTER_X - 155, SCREEN_CENTER_Y+153; zoomto, 300,60; diffuse,PlayerColor(PLAYER_1); );
			OnCommand=cmd(blend,Blend.Modulate)
		};
		
		Def.ComboGraph{
			InitCommand=cmd(Load,"ComboGraph"; xy, SCREEN_CENTER_X -155, SCREEN_CENTER_Y+188;);
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1);
				local stageStats = STATSMAN:GetCurStageStats();
				self:Set(stageStats, playerStageStats);
			end;
		};
		
		
	};






	-- Player 2!
	Def.ActorFrame{
		Name="P2Results";
		BeginCommand=function(self)			
			self:visible(GAMESTATE:IsPlayerEnabled(PLAYER_2))
		end;
		OnCommand=function(self)
			if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
				self:addx(-155)
			end
		end;


		Def.ActorFrame{
			OnCommand=function(self)
				if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
					self:addx(155);
				end
			end;


			--letter grade
			LoadActor("letterGrade", PLAYER_2)..{
				InitCommand=cmd( x, SCREEN_CENTER_X + 225; y,SCREEN_CENTER_Y-134; );
				OnCommand=cmd(zoom,0.4);
			};
		
			--stepartist for player 2's chart
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(xy, SCREEN_CENTER_X+270, SCREEN_CENTER_Y-66; zoom, 0.65; horizalign, right;);
				BeginCommand=function(self)
					local stepartist;
					local cs = GAMESTATE:GetCurrentSteps(PLAYER_2);
				
					if cs then
						stepartist = cs:GetAuthorCredit();
					end
					self:settext(stepartist)
				end;
			};
			
			-- Record Texts
			LoadActor("recordTexts", PLAYER_2)..{
				InitCommand=cmd(xy, SCREEN_CENTER_X+224, SCREEN_CENTER_Y-80; zoom, 0.42; horizalign, right;);
			};

			-- colored background for player 2's chart's difficulty meter
			Def.Quad{
				InitCommand=cmd(zoomto, 30, 30; xy, SCREEN_CENTER_X+289.5, SCREEN_CENTER_Y-71 );
				OnCommand=function(self)			
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
				InitCommand=cmd(diffuse, color("#000000"); xy, SCREEN_CENTER_X + 289.5, SCREEN_CENTER_Y-71; zoom, 0.5 );
				BeginCommand=function(self)
					local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
					local meter = steps:GetMeter();
				
					if meter then	
						self:settext(meter)
					end
				end;
			};
		};


		-- background for player stats
		Def.Quad{
			InitCommand=cmd(diffuse,color("#1E282F"); x, SCREEN_CENTER_X + 155; y,SCREEN_CENTER_Y+34; zoomto, 300,180; );
		};
		
		-- labels
		LoadActor("judgeLabels", PLAYER_2)..{ 
			InitCommand=cmd(x, SCREEN_CENTER_X + 100; y,SCREEN_CENTER_Y-24);
		};
		
		-- dark background quad behind player percent score
		Def.Quad{
			InitCommand=cmd(diffuse,color("#101519"); x, SCREEN_CENTER_X + 225; y,SCREEN_CENTER_Y-26; zoomto, 160,60; );
		};
		
		
		-- percentage
		LoadActor("percentage", PLAYER_2)..{
			InitCommand=cmd(xy, SCREEN_CENTER_X+300, SCREEN_CENTER_Y-26;zoom, 0.65; horizalign, right;);
			OnCommand=function(self)	
				-- Format the Percentage string, removing the % symbol
				local text = self:GetText();
				text = string.gsub(text, "%%", "");
				self:settext(text);
			end;
		};

		
		
		-- stages survived (course mode)
		LoadActor("stagesSurvived", PLAYER_2)..{
			InitCommand=cmd(x,SCREEN_WIDTH*0.8;y,SCREEN_CENTER_Y-136);
		};

		-- numbers
		LoadActor("judgeNumbers", PLAYER_2)..{
			InitCommand=cmd(x,SCREEN_CENTER_X+64;y,SCREEN_CENTER_Y-24; zoom, 0.8);
		};

		-- player 2's options
		LoadActor("playerOptions", PLAYER_2)..{
			InitCommand=cmd(xy, SCREEN_CENTER_X +155, SCREEN_CENTER_Y+208;);
		};
		
		Def.GraphDisplay{
			InitCommand=cmd(Load,"GraphDisplay"; xy, SCREEN_CENTER_X + 155, SCREEN_CENTER_Y+153; zoomto, 300,60;);
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2);
				local stageStats = STATSMAN:GetCurStageStats();
				self:Set(stageStats, playerStageStats);
				self:GetChild("Line"):diffusealpha(0);
			end;
		};
		
		
		Def.Quad{
			InitCommand=cmd(xy, SCREEN_CENTER_X + 155, SCREEN_CENTER_Y+153; zoomto, 300,60; diffuse,PlayerColor(PLAYER_2); );
			OnCommand=cmd(blend,Blend.Modulate)
		};
		
			
		Def.ComboGraph{
			InitCommand=cmd(Load,"ComboGraph"; xy, SCREEN_CENTER_X + 155, SCREEN_CENTER_Y+188;);
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2);
				local stageStats = STATSMAN:GetCurStageStats();
				self:Set(stageStats, playerStageStats);
			end;
		};
		
	};
};

return t;