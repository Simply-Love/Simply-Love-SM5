local Player = ...;

-- machineProfile contains the overall high scores per song
local machineProfile = PROFILEMAN:GetMachineProfile();

-- get the number of stages that were played
local numStages = STATSMAN:GetStagesPlayed();
local durationPerSong = 3;

local months = {};
for i=1,12 do
	months[#months+1] = THEME:GetString("ScreenNameEntryActual", "Month"..i);
end


local t = Def.ActorFrame{};


-- Banner(s)
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




for i=numStages,1,-1 do
	
	local stageStats = STATSMAN:GetPlayedStageStats(i);
	
	if stageStats then
		local highscoreList, highscores;
		local song = stageStats:GetPlayedSongs()[1];
		local steps = stageStats:GetPlayerStageStats(Player):GetPlayedSteps()[1];
		local text = "";
		
		if song and steps then
			highscoreList = machineProfile:GetHighScoreList(song,steps);
		end;	
		
		if highscoreList then
			highscores = highscoreList:GetHighScores();
		end
		
		t[#t+1] = LoadFont("_misoreg hires")..{
			InitCommand=function(self)
				self:diffusealpha(0);
				self:zoom(0.95);
				if Player == PLAYER_1 then
					self:x(SCREEN_CENTER_X-160);
				elseif Player == PLAYER_2 then
					self:x(SCREEN_CENTER_X+160);
				end
				self:y(SCREEN_CENTER_Y+136);
			end;
			OnCommand=function(self)
				
		
				if highscores then
					
					-- currently hardcoded to only display 5 highscores per stage
					-- this really should use PREFSMAN:GetPreference("MaxHighScoresPerListForMachine")
					for s=1,5 do
						local score, name, date;
						local numbers = {};
						
						if highscores[s] then
							score = highscores[s]:GetPercentDP();
							
							name = highscores[s]:GetName();							
							if name == "" then name = "----" end
							
							date = highscores[s]:GetDate();
							
							for number in string.gmatch(date, "%d+") do
								numbers[#numbers+1] = number;
						    end
							
							date = months[tonumber(numbers[2])] .. " " ..  numbers[3] ..  ", " .. numbers[1];
							text = text .. (name .. "            " .. FormatPercentScore(score) .. "            " .. date .. "\n");
						else
							text = text .. "----              -----           -----------\n";
						end
						
						
					end
				end;
				
				self:settext(text);
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

return t;