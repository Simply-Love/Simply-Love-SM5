local stageStats = ...;
local Players = GAMESTATE:GetHumanPlayers();



-- what sort of scenario would cause this to return a table of multiple songs?
-- I honestly don't know...
local song = stageStats:GetPlayedSongs()[1];


--
local t = Def.ActorFrame{
	
	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/banner"..SimplyLoveColor()..".png"))..{
		InitCommand=cmd(y,-6; zoom, 0.333);
	};
	
	-- the banner, if there is one
	Def.Sprite{
		Name="Banner";
		InitCommand=function(self)
			self:y(-6);
			
			local bannerpath;
			if song then
				bannerpath = song:GetBannerPath();
			end			
	
			if bannerpath then
				self:LoadBanner(bannerpath);			
				self:setsize(418,164);
				self:zoom(0.333);
			end
		end;
	};
	
	-- the title of the song
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(zoom,0.8; y,-40; maxwidth, 350;);
		OnCommand=function(self)
			if song then
				self:settext(song:GetDisplayFullTitle());
			end
		end;
	};
	
	-- the BPM(s) of the song
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(zoom,0.6; y,30; maxwidth, 350;);
		OnCommand=function(self)
			if song then
				local BPMs = song:GetDisplayBpms();
				if BPMs then
					if BPMs[1] == BPMs[2] then
						self:settext(round(BPMs[1]) .. " bpm");
					else
						self:settext(round(BPMs[1]) .. " - " .. round(BPMs[2]) .. " bpm");
					end
				end
			end
		end;
	};
};




for pn in ivalues(Players) do
	local playerStats;
	
	if stageStats then
		playerStats = stageStats:GetPlayerStageStats(pn);
	end
	
	if playerStats then
		
		local percentScore = playerStats:GetPercentDancePoints();
		local difficultyMeter, difficulty, stepartist, grade;
		
		if playerStats:GetPlayedSteps()[1] then
			difficultyMeter = playerStats:GetPlayedSteps()[1]:GetMeter();
			difficulty = playerStats:GetPlayedSteps()[1]:GetDifficulty();
			stepartist = playerStats:GetPlayedSteps()[1]:GetAuthorCredit()
			grade = playerStats:GetGrade();
		
		
			local TNSTypes = {
				'TapNoteScore_W1',
				'TapNoteScore_W2',
				'TapNoteScore_W3',
				'TapNoteScore_W4',
				'TapNoteScore_W5',
				'TapNoteScore_Miss'
			};
	
	
			-- variables for positioning and horizalign, dependent on playernumber
			local col1x, col2x, gradex, align1, align2;
	
			if pn == PLAYER_1 then
				col1x =  -90;
				col2x =  -SCREEN_WIDTH/2.5;
				gradex = -SCREEN_WIDTH/3.33;
				align1 = right;
				align2 = left;
			elseif pn == PLAYER_2 then
				col1x = 90;
				col2x = SCREEN_WIDTH/2.5;
				gradex = SCREEN_WIDTH/3.33;
				align1= left;
				align2 = right;
			end
	
			--percent score
			t[#t+1] = LoadFont("_wendy small")..{
				InitCommand=cmd(zoom,0.5; horizalign, align1; x,col1x; y,-24);
				OnCommand=function(self)
					if percentScore then
						
						-- trim off the % symbol
						local score = string.sub(FormatPercentScore(percentScore),1,-2);
						
						-- If the score is < 10.00% there will be leading whitespace, like " 9.45"
						-- trim that too, so PLAYER_2's scores align properly.
						score = string.gsub(score, " ", "")	
						self:settext(score);
					end
				end		
			};
	
			-- difficulty meter
			t[#t+1] = LoadFont("_wendy small")..{
				InitCommand=cmd(zoom,0.4; horizalign, align1; x,col1x; y,4);
				OnCommand=function(self)
					if difficultyMeter then
						if difficulty then
							local y_offset = GetYOffsetByDifficulty(difficulty)
							self:diffuse(DifficultyIndexColor(y_offset));
						end
				
						self:settext(difficultyMeter);
					end
				end		
			};
	
			-- stepartist
			t[#t+1] = LoadFont("_misoreg hires")..{
				InitCommand=cmd(zoom,0.65; horizalign, align1; x,col1x; y,28);
				OnCommand=function(self)
					if stepartist then
						self:settext(stepartist);
					end
				end		
			};
	
	
			-- letter grade
			t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"))..{
				OnCommand=cmd(zoom,0.2; x, gradex);
			};
	
	
			-- numbers
			for i=1,#TNSTypes do
		
				t[#t+1] = LoadFont("_wendy small")..{
					InitCommand=cmd(zoom,0.28; horizalign, align2; x,col2x; y,i*13 - 50);
					OnCommand=function(self)
				
						local val = playerStats:GetTapNoteScores(TNSTypes[i]);
				
						if val then
							self:settext(val);
						end;
				
						-- the only place in this theme that color is hard-coded...
				
						if i == 1 then						-- fantastic
							self:diffuse(color("#21CCE8"));	-- blue
					
						elseif i == 2 then					-- perfect
							self:diffuse(color("#e29c18"));	-- gold
					
						elseif i == 3 then					-- great
							self:diffuse(color("#66c955"));	-- green
				
						elseif i == 4 then					-- good
							self:diffuse(color("#5b2b8e"));	-- purple
					
						elseif i == 5 then					-- decent
							self:diffuse(color("#c9855e"));	-- peach?
					
						else								--miss
							self:diffuse(color("#ff0000"));	--red
						end	
				
					end;
				};
			end
		end
	end	
end



return t;