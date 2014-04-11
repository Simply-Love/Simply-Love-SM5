local gridLength = 20;
local gridZoomFactor = WideScale(0.27,0.29);

local function GetStepsToDisplay(steps)
	
	--gather any edit charts into a table
	local edits = {};
	local charts = {};
	
	for k,chart in ipairs(steps) do
		
		local difficulty = chart:GetDifficulty();
		
		if chart:IsAnEdit() then
			edits[#edits+1] = chart;
		else
			local index = GetYOffsetByDifficulty(difficulty);
			charts[index] = chart;	
		end
	end
	
	-- if there are no edits we can safely bail now
	if #edits == 0 then return charts end;
	
	
	
	--THERE ARE EDITS, OH NO!
	--HORRIBLE HANDLING/LOGIC BELOW
	
	-- start the editIndex at 6
	-- (one higher than 5, which is used for Challenge charts)
	local editIndex = 6;
	for k,edit in ipairs(edits) do
		charts[5+k] = edit;
		-- editIndex = editIndex + 1;
	end
		
	local currentStepsP1, currentStepsP2;
	local finalReturn = {};
	
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		currentStepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1);
	end
	
	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		currentStepsP2 = GAMESTATE:GetCurrentSteps(PLAYER_2);
	end
	
	-- if only one player is joined
	if (currentStepsP1 and not currentStepsP2) or (currentStepsP2 and not currentStepsP1) then
		
		if (currentStepsP1 and not currentStepsP2) then
			currentSteps = currentStepsP1;
		elseif (currentStepsP2 and not currentStepsP1) then
			currentSteps = currentStepsP2;
		end
		
		-- if the current chart is an edit
		if currentSteps:IsAnEdit() then
			
			local currentIndex;
			
			-- We've used GAMESTATE:GetCurrentSteps(pn) to get the current chart
			-- use a for loop to match that "current chart" against each chart
			-- in our charts table; we want the index of the current chart
			for k,chart in pairs(charts) do
				if chart:GetChartName()==currentSteps:GetChartName() then
					currentIndex = tonumber(k);
				end
			end
			
			local frIndex = 5;
			
			-- "i" will decrement here
			-- if there is one edit chart, it will assign charts to finalReturn like
			-- [5]Edit, [4]Challenge, [3]Hard, [2]Medium, [1]Easy
			--
			-- if there are two edit charts, it will assign charts to finalReturn like
			-- [5]Edit, [4]Edit, [3]Challenge, [2]Hard, [1]Medium
			-- and so on
			for i=currentIndex, currentIndex-4, -1 do
				finalReturn[frIndex] = charts[i];
				frIndex = frIndex - 1;
			end
			
		-- else we are somewhere in the normal five difficulties
		-- and are, for all intents and purposes, uninterested in any edits for now
		-- so remove all edits from the table we're returning
		else
			
			for k,chart in pairs(charts) do
				if chart:IsAnEdit() then
					charts[k] = nil
				end
			end
			
			return charts;
		end
		
		
	-- elseif both players are joined
	-- This can get complicated if P1 is on beginner and P2 is on an edit
	-- AND there is a full difference of charts inbetween
	-- we'll have to hide SOMETHING...
	elseif (currentStepsP1 and currentStepsP2) then
		
			
		if not currentStepsP1:IsAnEdit() and not currentStepsP2:IsAnEdit() then
	
			for k,chart in pairs(charts) do
				if chart:IsAnEdit() then
					charts[k] = nil
				end
			end
	
			return charts;
		end


		local currentIndexP1, currentIndexP2;
		
		-- how broad is the range of charts for this song?
		-- (where beginner=1 and edit=6+)
		-- and how far apart are P1 and P2 currently?
		
		for k,chart in pairs(charts) do

			if chart == currentStepsP1 then
				currentIndexP1 = k;
			end

			if chart == currentStepsP2 then
				currentIndexP2 = k;
			end	
		end
		
		if (currentIndexP1 and currentIndexP2) then
			
			local difference = math.abs(currentIndexP1-currentIndexP2);
								
			local greaterIndex, lesserIndex;
			if currentIndexP1 > currentIndexP2 then
				greaterIndex = currentIndexP1;
				lesserIndex = currentIndexP2;
			else
				greaterIndex = currentIndexP2;
				lesserIndex = currentIndexP1;
			end
				
			if difference > 4 then
			
				local frIndex=1;
				for i=lesserIndex, lesserIndex+2 do
					finalReturn[frIndex] = charts[i];
					frIndex = frIndex + 1;
				end
				for i=greaterIndex-1, greaterIndex do
					finalReturn[frIndex] = charts[i];
					frIndex = frIndex + 1;
				end

			else
				local frIndex = 5;
				for i=greaterIndex, greaterIndex-4, -1 do
					finalReturn[frIndex] = charts[i];
					frIndex = frIndex - 1;
				end
			end
		end
	end
	
	return finalReturn;	
end



local t = Def.ActorFrame{
	
	InitCommand=cmd(xy, SCREEN_CENTER_X / WideScale(2, 1.73), SCREEN_CENTER_Y + 70; );
	CurrentStepsP1ChangedMessageCommand=function(self)
		self:propagatecommand("Reset");
	end;
	CurrentStepsP2ChangedMessageCommand=function(self)
		self:propagatecommand("Reset");
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:propagatecommand("Reset");
	end;


	-- background
	Def.Quad{
		Name="Background";
		InitCommand=cmd(diffuse,color("#1e282f"); zoomto, SCREEN_WIDTH/WideScale(2.05, 2.47) - 10, SCREEN_HEIGHT/5;);
	};
	
	
	
	
	
	-- PLAYER_1's bouncing cursor
	Def.ActorFrame {
		
		InitCommand=cmd(player,PLAYER_1);
		
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:visible(true);
				(cmd(zoom,0;bounceend,0.3;zoom,1))(self);
			end;
	 	end;
	 	
		PlayerUnjoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:visible(true);
				(cmd(bouncebegin,0.3;zoom,0))(self);
			end;
		end;
		
		LoadActor("cursor.png")..{
			InitCommand=cmd(zoom,0.6; x, WideScale(-142,-155); y,-36; );
			--OnCommand taken from freem's ITG3 SM5 port
			OnCommand=cmd(linear,.4;diffusealpha,1;bounce;effectmagnitude,-3,0,0;effectperiod,1.0;effectoffset,0.2;effectclock,"beat";);
			SetCommand=function(self)
				
				if GAMESTATE:IsHumanPlayer(PLAYER_1) then
					local SongOrCourse, AllStepsOrTrails, CurrentStepsOrTrail;
					
					if GAMESTATE:IsCourseMode() then
						SongOrCourse = GAMESTATE:GetCurrentCourse();
					else
						SongOrCourse = GAMESTATE:GetCurrentSong();
					end

					if SongOrCourse then
						if GAMESTATE:IsCourseMode() then
							AllStepsOrTrails = SongOrCourse:GetAllTrails();
							CurrentStepsOrTrail = GAMESTATE:GetCurrentTrail(PLAYER_1);
						else
							AllStepsOrTrails = SongUtil.GetPlayableSteps( SongOrCourse );
							CurrentStepsOrTrail = GAMESTATE:GetCurrentSteps(PLAYER_1);
						end

						if CurrentStepsOrTrail then
							local stepstodisplay = GetStepsToDisplay(AllStepsOrTrails);
							local offset=0;
							for k,chart in pairs(stepstodisplay) do
								if chart:IsAnEdit() then
									if chart:GetChartName()==CurrentStepsOrTrail:GetChartName() then
										offset = tonumber(k);
									end
								else
									if chart:GetDifficulty()==CurrentStepsOrTrail:GetDifficulty() then
										offset = tonumber(k);
									end
								end
							end
							self:y((offset-3) * 18);
						end
					end
				end
			end;
			ResetCommand=cmd(playcommand,"Set");

			-- song and course changes
			CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
			CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
		
			CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set");
			CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set");
		};
	};
	
	
	
	
	--PLAYER_2's bouncing cursor
	Def.ActorFrame {
		InitCommand=cmd(player,PLAYER_2);
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_2 then
				self:visible(true);
				(cmd(zoom,0;bounceend,0.3;zoom,1))(self);
			end;
		end;
		PlayerUnjoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_2 then
				self:visible(true);
				(cmd(bouncebegin,0.3;zoom,0))(self);
			end;
		end;
		LoadActor("cursor.png")..{
			InitCommand=cmd(zoom,0.6; rotationz,180; x, WideScale(142,155); );
			--OnCommand taken from freem's ITG3 SM5 port
			OnCommand=cmd(linear,.4;diffusealpha,1;bounce;effectmagnitude,3,0,0;effectperiod,1.0;effectoffset,0.2;effectclock,"beat";);
			SetCommand=function(self)
				
				if GAMESTATE:IsHumanPlayer(PLAYER_2) then
					local SongOrCourse, StepsOrTrails, CurrentStepsOrTrails;
					
					if GAMESTATE:IsCourseMode() then
						SongOrCourse = GAMESTATE:GetCurrentCourse();
					else
						SongOrCourse = GAMESTATE:GetCurrentSong();
					end

					if SongOrCourse then
						if GAMESTATE:IsCourseMode() then
							StepsOrTrails = SongOrCourse:GetAllTrails();
							CurrentStepsOrTrails = GAMESTATE:GetCurrentTrail(PLAYER_2);
						else
							StepsOrTrails = SongUtil.GetPlayableSteps( SongOrCourse );
							CurrentStepsOrTrails = GAMESTATE:GetCurrentSteps(PLAYER_2);
						end


						if CurrentStepsOrTrails then
							local stepstodisplay = GetStepsToDisplay(StepsOrTrails);
							local offset = 0;
							for k,chart in pairs(stepstodisplay) do
								if chart:IsAnEdit() then
									if chart:GetChartName()==CurrentStepsOrTrails:GetChartName() then
										offset = tonumber(k);
									end
								else
									if chart:GetDifficulty()==CurrentStepsOrTrails:GetDifficulty() then
										offset = tonumber(k);
									end
								end
							end
							self:y((offset-3) * 18);
						end
					end
				end
			end;
			ResetCommand=cmd(playcommand,"Set");
			
			-- song and course changes
			CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
			CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
	
			CurrentStepsP2ChangedMessageCommand=cmd(playcommand,"Set");
			CurrentTrailP2ChangedMessageCommand=cmd(playcommand,"Set");
		};

	};
	
};

-- the grey background blocks
t[#t+1] = LoadActor("_block.png")..{
	Name="BackgroundBlocks";
	InitCommand=cmd(diffuse,color("#182025"); halign,0);
	OnCommand=function(self)
		width = self:GetWidth();
		height= self:GetHeight();
		self:x(-(width * gridLength)/4 + WideScale(32,26));
		self:zoomto(width * gridLength * gridZoomFactor * 1.55, height * 5 * gridZoomFactor);
		self:customtexturerect(0, 0, gridLength, 5);
	end;
};


for row=1,5 do

	t[#t+1] = LoadFont("_wendy small")..{
		Name="Meter"..row;
		Text="?";
		InitCommand=cmd(diffuse,DifficultyIndexColor(row); zoom,gridZoomFactor; y, row * WideScale(17.333,18.333) - WideScale(52,55.5); x, WideScale(-128,-135); horizalign,right);
		ResetCommand=function(self)
			local SongOrCourse, StepsOrTrails;
	
			if GAMESTATE:IsCourseMode() then
				SongOrCourse = GAMESTATE:GetCurrentCourse();		
			else
				SongOrCourse = GAMESTATE:GetCurrentSong();
			end;
	
			if SongOrCourse then
		
				if GAMESTATE:IsCourseMode() then
					StepsOrTrails = SongOrCourse:GetAllTrails()		
				else
					StepsOrTrails = SongUtil.GetPlayableSteps( SongOrCourse )
				end;
	
	
				if StepsOrTrails then				
			
					local stepstodisplay = GetStepsToDisplay(StepsOrTrails);
			
					if stepstodisplay[row] then
				
						local meter = tonumber(stepstodisplay[row]:GetMeter());
						local difficulty = stepstodisplay[row]:GetDifficulty();
						
						-- diffuse and set each chart's difficulty meter
						self:diffuse( DifficultyColor(difficulty) );
						self:settext(meter);
	
					else
						self:settext("");
					end			
				end
		
			else
				-- is it safe to assume that if there isn't a song, we're on a group (folder)?
				-- for now, I'm going to have to go with "yes"
				self:settext("?");
			end
		end;
	};
	
	t[#t+1] = LoadActor("_block.png")..{
		Name="BlockRow"..row;
		InitCommand=cmd(halign,0; diffuse,DifficultyIndexColor(row));
		OnCommand=function(self)
			local width = self:GetWidth();
			local height= self:GetHeight();
			
			self:y(row*height*gridZoomFactor - (height*gridZoomFactor*3));
			self:x(-(width * gridLength)/4 + WideScale(32,26));
		end;
		ResetCommand=function(self)
			local width = self:GetWidth();
			local height= self:GetHeight();
			local SongOrCourse, StepsOrTrails;
	
			if GAMESTATE:IsCourseMode() then
				SongOrCourse = GAMESTATE:GetCurrentCourse();		
			else
				SongOrCourse = GAMESTATE:GetCurrentSong();
			end;
	
			if SongOrCourse then
		
				if GAMESTATE:IsCourseMode() then
					StepsOrTrails = SongOrCourse:GetAllTrails()		
				else
					StepsOrTrails = SongUtil.GetPlayableSteps( SongOrCourse )
				end;
	
	
				if StepsOrTrails then				
			
					local stepstodisplay = GetStepsToDisplay(StepsOrTrails);
					
					if stepstodisplay[row] then
						local meter = stepstodisplay[row]:GetMeter();
						local difficulty = stepstodisplay[row]:GetDifficulty();
						
						-- our grid only supports charts with up to a 20-block difficulty meter
						-- but charts can have higher difficulties
						-- handle that here by setting a maximum number to worry about displaying
						if meter > gridLength then
							meter = gridLength
						end
						
						self:zoomto(width * meter * gridZoomFactor * 1.55, height * gridZoomFactor);
						self:customtexturerect(0, 0, meter, 1);
						self:texcoordvelocity(0,0);
						-- diffuse and set each chart's difficulty meter
						self:diffuse( DifficultyColor(difficulty) );
					else
						self:zoomto(0,0);
					end
				end
			else
				self:zoomto(0, 0);
			end
		end;
	};
end

return t;