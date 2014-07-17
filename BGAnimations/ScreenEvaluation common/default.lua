local t = Def.ActorFrame{

	-- I'll uncomment this when SaveScreenshot() is in the master branch.
	
	-- CodeMessageCommand=function(self, params)
	-- 	if params.Name == "Screenshot" then
	-- 		SaveScreenshot(params.PlayerNumber, false, true);
	-- 	end
	-- end;
	
	-- quad behind the song/course title text
	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282F"); xy,_screen.cx, 54.5; zoomto, 292.5,20; );
	};

	-- song/course title text
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(xy,_screen.cx,54; NoStroke; shadowlength,1; maxwidth, 294 );
		OnCommand=function(self)
			local songtitle = GAMESTATE:GetCurrentSong():GetDisplayFullTitle();
			if songtitle then
				self:settext(songtitle);
			end
		end;
	};
		
	
	
	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/banner" .. SimplyLoveColor() .. ".png"))..{
		OnCommand=cmd(xy, _screen.cx, 121.5; zoom, 0.7);
	};
	
	--songs's banner, if it has one
	Def.Sprite{
		Name="Banner";
		InitCommand=cmd(xy, _screen.cx, 121.5);
		OnCommand=function(self)
			-- these need to be declared as empty variables here
			-- otherwise, the banner from round1 can persist into round2
			-- if round2 doesn't have banner!
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
		InitCommand=cmd(diffuse,color("#1E282FCC"); xy,_screen.cx, 172; zoomto, 292.5,14; );
		OnCommand=function(self)
			local songoptions = GAMESTATE:GetSongOptionsObject("ModsLevel_Song");
			local ratemod = round(songoptions:MusicRate());
			if ratemod == 1 then
				self:visible(false);
			end
		end
	};
	
	--the ratemod, if there is one
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(xy,_screen.cx, 173; NoStroke;shadowlength,1; zoom, 0.7);
		OnCommand=function(self)	
			local songoptions = GAMESTATE:GetSongOptionsObject("ModsLevel_Song");
			local ratemod = round(songoptions:MusicRate());
			local bpm = GetDisplayBPMs();
			
			if ratemod ~= 1 then
				self:settext(string.format("%.1f", ratemod) .. " Music Rate");

				if bpm then

					--if there is a range of BPMs
					if string.match(bpm, "%-") then
						local bpms = {};
						for i in string.gmatch(bpm, "%d+") do
							bpms[#bpms+1] = round(tonumber(i) * ratemod);
						end
						if bpms[1] and bpms[2] then
							bpm = bpms[1] .. "-" .. bpms[2];
						end
					else
						bpm = tonumber(bpm) * ratemod;
					end
					
					self:settext(self:GetText() .. " (" .. bpm .. " BPM)" );
				end
			else
				-- else MusicRate was 1.0
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
				InitCommand=cmd(x, _screen.cx-225; y,_screen.cy-134;);
				OnCommand=cmd(zoom, 0.4);
			};
		
		
			--stepartist for player 1's chart
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(xy, _screen.cx-270, _screen.cy-80; zoom, 0.7; horizalign, left;);
				BeginCommand=function(self)
					local stepartist;
					local cs = GAMESTATE:GetCurrentSteps(PLAYER_1);
				
					if cs then
						stepartist = cs:GetAuthorCredit();
					end
					self:settext(stepartist)
				end;
			};
			
			--difficulty text for player 1
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(xy, _screen.cx-270, _screen.cy-64; zoom, 0.7; horizalign, left;);
				OnCommand=function(self)
					if GAMESTATE:IsHumanPlayer(PLAYER_1) then
						local currentSteps = GAMESTATE:GetCurrentSteps(PLAYER_1);
						if currentSteps then
							local difficulty = currentSteps:GetDifficulty();
							--GetDifficulty() returns a value from the Difficulty Enum
							--"Difficulty_Hard" for example.
							-- Strip the characters up to and including the underscore.
							difficulty = string.gsub(difficulty, "Difficulty_", "");
							self:settext(THEME:GetString("Difficulty", difficulty));
							
						end
					end
				end;
			};
			
			-- Record Texts
			LoadActor("recordTexts", PLAYER_1)..{
				InitCommand=cmd(xy, _screen.cx-224, 54; zoom, 0.42; horizalign, left;);
			};
		
			-- colored background for player 1's chart's difficulty meter
			Def.Quad{
				InitCommand=cmd(zoomto, 30, 30; xy, _screen.cx-289.5, _screen.cy-71 );
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
				InitCommand=cmd(diffuse, color("#000000"); xy, _screen.cx-289.5, _screen.cy-71; zoom, 0.4 );
				BeginCommand=function(self)
					local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
					if steps then
						local meter = steps:GetMeter();
				
						if meter then	
							self:settext(meter)
						end
					end
				end;
			};
		};
		
	
		
		
		-- background quad for player stats
		Def.Quad{
			InitCommand=cmd(diffuse,color("#1E282F"); x, _screen.cx -155; y,_screen.cy+34; zoomto, 300,180; );
		};
	
			
		LoadActor("judgeLabels", PLAYER_1)..{
			InitCommand=cmd(x, _screen.cx - 100; y,_screen.cy-24);
		};
		
		-- dark background quad behind player percent score
		Def.Quad{
			InitCommand=cmd(diffuse,color("#101519"); x, _screen.cx - 225.5; y,_screen.cy-26; zoomto, 158.5,60; );
		};
		
		-- percentage
		LoadActor("percentage", PLAYER_1)..{
			InitCommand=cmd(xy,_screen.cx-150, _screen.cy-26; zoom,0.65; horizalign,right);
			OnCommand=function(self)
				-- Format the Percentage string, removing the % symbol
				local text = self:GetText();
				text = string.gsub(text, "%%", "");
				self:settext(text);
			end;
		};

		-- numbers
		LoadActor("judgeNumbers", PLAYER_1)..{
			InitCommand=cmd(x,_screen.cx-64; y, _screen.cy-24; zoom, 0.8);
		};
		
		Def.GraphDisplay{
			InitCommand=cmd(Load,"GraphDisplay"..SimplyLoveColor(); xy, _screen.cx-155, _screen.cy+150.5);
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1);
				local stageStats = STATSMAN:GetCurStageStats();
				self:Set(stageStats, playerStageStats);
				self:GetChild("Line"):diffusealpha(0);			
			end
		};
		
		Def.ComboGraph{
			InitCommand=cmd(Load,"ComboGraphP1"; xy, _screen.cx-155, _screen.cy+182.5;);
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1);
				local stageStats = STATSMAN:GetCurStageStats();
				self:Set(stageStats, playerStageStats);
			end;
		};
		
		LoadActor("playerOptions", PLAYER_1)..{
			InitCommand=cmd(xy, _screen.cx -155, _screen.cy+200.5;);
		};
		
		-- was PLAYER_1 disqualified from ranking?
		LoadActor("disqualified", PLAYER_1)..{
			InitCommand=cmd(xy, _screen.cx-84, _screen.cy+138);
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
				InitCommand=cmd( x, _screen.cx + 225; y,_screen.cy-134; );
				OnCommand=cmd(zoom,0.4);
			};
		
			--stepartist for player 2's chart
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(xy, _screen.cx+270, _screen.cy-80; zoom, 0.7; horizalign, right;);
				BeginCommand=function(self)
					local stepartist = "";
					local cs = GAMESTATE:GetCurrentSteps(PLAYER_2);
				
					if cs then
						stepartist = cs:GetAuthorCredit();
					end
					self:settext(stepartist)
				end;
			};
			
			--difficulty text for player 2
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(xy, _screen.cx+270, _screen.cy-64; zoom, 0.7; horizalign, right;);
				OnCommand=function(self)
					if GAMESTATE:IsHumanPlayer(PLAYER_1) then
						local currentSteps = GAMESTATE:GetCurrentSteps(PLAYER_2);
						if currentSteps then
							local difficulty = currentSteps:GetDifficulty();
							--GetDifficulty() returns a value from the Difficulty Enum
							--"Difficulty_Hard" for example.
							-- Strip the characters up to and including the underscore.
							difficulty = string.gsub(difficulty, "Difficulty_", "");
							self:settext(THEME:GetString("Difficulty", difficulty));
							
						end
					end
				end;
			};
			
			-- Record Texts
			LoadActor("recordTexts", PLAYER_2)..{
				InitCommand=cmd(xy, _screen.cx+224, 54; zoom, 0.42; horizalign, right;);
			};

			-- colored background for player 2's chart's difficulty meter
			Def.Quad{
				InitCommand=cmd(zoomto, 30, 30; xy, _screen.cx+289.5, _screen.cy-71 );
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
				InitCommand=cmd(diffuse, color("#000000"); xy, _screen.cx + 289.5, _screen.cy-71; zoom, 0.4 );
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
		};


		-- background for player stats
		Def.Quad{
			InitCommand=cmd(diffuse,color("#1E282F"); x, _screen.cx + 155; y,_screen.cy+34; zoomto, 300,180; );
		};
		
		-- labels
		LoadActor("judgeLabels", PLAYER_2)..{ 
			InitCommand=cmd(x, _screen.cx + 100; y,_screen.cy-24);
		};
		
		-- dark background quad behind player percent score
		Def.Quad{
			InitCommand=cmd(diffuse,color("#101519"); x, _screen.cx + 225.5; y,_screen.cy-26; zoomto, 158.5,60; );
		};
		
		
		-- percentage
		LoadActor("percentage", PLAYER_2)..{
			InitCommand=cmd(xy, _screen.cx+300, _screen.cy-26;zoom, 0.65; horizalign, right;);
			OnCommand=function(self)	
				-- Format the Percentage string, removing the % symbol
				local text = self:GetText();
				text = string.gsub(text, "%%", "");
				self:settext(text);
			end;
		};
	

		-- numbers
		LoadActor("judgeNumbers", PLAYER_2)..{
			InitCommand=cmd(x,_screen.cx+64;y,_screen.cy-24; zoom, 0.8);
		};
		
		Def.GraphDisplay{
			InitCommand=cmd(Load,"GraphDisplay"..(SimplyLoveColor()+2)%12+1; xy, _screen.cx+155, _screen.cy+150.5);
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2);
				local stageStats = STATSMAN:GetCurStageStats();
				self:Set(stageStats, playerStageStats);
				self:GetChild("Line"):diffusealpha(0);
			end;
		};
		
			
		Def.ComboGraph{
			InitCommand=cmd(Load,"ComboGraphP2"; xy, _screen.cx + 155, _screen.cy+182.5;);
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2);
				local stageStats = STATSMAN:GetCurStageStats();
				self:Set(stageStats, playerStageStats);
			end;
		};
		
		-- player 2's options
		LoadActor("playerOptions", PLAYER_2)..{
			InitCommand=cmd(xy, _screen.cx +155, _screen.cy+200.5;);
		};
		
		-- was PLAYER_2 disqualified from ranking?
		LoadActor("disqualified", PLAYER_2)..{
			InitCommand=cmd(xy, _screen.cx + 224, _screen.cy+138);
		};
		
	};
};

return t;