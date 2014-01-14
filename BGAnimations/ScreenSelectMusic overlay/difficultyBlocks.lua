local gridLength = 20;

--get what game we're playing
local game = GAMESTATE:GetCurrentGame():GetName();
--capitalize the first letter of game
local capitalizedGame = game:gsub("^%l", string.upper);

--get our style (single, versus, double)
local style = GAMESTATE:GetCurrentStyle():GetName();

--since there are no StepsType "versus"
--we're really only interested in singles charts
--regardless of whether the style is "single" or "versus"
if style == "versus" then
	style = "single";
end
if style == "versus8" then
	style = "single8";
end
--capitalize the first letter of our style
local capitalizedStyle = style:gsub("^%l", string.upper);
local relevantStepsType = "StepsType_"..capitalizedGame.."_"..capitalizedStyle;



local function GetStepsToDisplay(steps)
	
	--gather any edit charts into a table
	local edits = {};
	local charts = {};
	
	for k,chart in ipairs(steps) do
		
		local difficulty = chart:GetDifficulty();
		
		if difficulty == "Difficulty_Edit" then
			edits[#edits+1] = chart;
		else
			local index = GetYOffsetByDifficulty(difficulty);
			charts[index] = chart;	
		end
	end
	
	-- start the editIndex at 6
	-- (one higher than 5, which is used for Challenge charts)
	local editIndex = 6;
	for k,edit in ipairs(edits) do
		charts[editIndex] = edit;
		editIndex = editIndex + 1;
	end

	-- if there are no edits we can safely bail now
	if #edits == 0 then return charts end;
		
	
	--THERE ARE EDITS, OH NO!
	--HORRIBLE HANDLING/LOGIC BELOW
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
	-- AND there is a full range of charts inbetween
	-- we'll have to hide SOMETHING, so I'm opting to hide the medium chart
	-- if such a circumstance arrises
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
		
		-- how broad is the "range" of charts for this song?
		-- (where beginner=1 and edit=6+)
		-- and how far apart are P1 and P2 currently?
		for k,chart in pairs(charts) do
			
			if chart:IsAnEdit() and chart:GetChartName()==currentStepsP1:GetChartName() then
				currentIndexP1 = tonumber(k);
			end
			
			if not chart:IsAnEdit() and chart:GetDifficulty()==currentStepsP1:GetDifficulty() then
				currentIndexP1 = tonumber(k);
			end
			
			
			if chart:IsAnEdit() and chart:GetChartName()==currentStepsP2:GetChartName() then
				currentIndexP2 = tonumber(k);
			end
			
			if not chart:IsAnEdit() and chart:GetDifficulty()==currentStepsP2:GetDifficulty() then
				currentIndexP2 = tonumber(k);
			end
		end
		
		--SCREENMAN:SystemMessage(currentIndexP1 .. " " .. currentIndexP2);
		
		local range = math.abs(currentIndexP1-currentIndexP2);
		
		--SCREENMAN:SystemMessage(range);
		
		local greaterIndex, lesserIndex;
		if currentIndexP1 > currentIndexP2 then
			greaterIndex = currentIndexP1;
			lesserIndex = currentIndexP2;
		else
			greaterIndex = currentIndexP2;
			lesserIndex = currentIndexP1;
		end
		
		
		if range >= 5 then
			
			local frIndex=1;
			for i=lesserIndex, lesserIndex+2 do
				finalReturn[frIndex] = charts[i];
				frIndex = frIndex + 1;
			end
			for i=greaterIndex, greaterIndex-1, -1 do
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
	
	return finalReturn;	
end




local function ColorTheGrid(af)
	local song, steps;
	local difficulties = {};
	
	song = GAMESTATE:GetCurrentSong();
	if song then
		steps = song:GetStepsByStepsType(relevantStepsType);
	
		if steps then				
			
			local stepstodisplay = GetStepsToDisplay(steps);

			--SMPairs(stepstodisplay);

			for k,chart in pairs(stepstodisplay) do
				
				local meter = tonumber(chart:GetMeter());
				local difficulty = chart:GetDifficulty();
							
				-- diffuse and set each chart's difficulty meter
				af:GetChild("Grid"):GetChild( "Row" .. tonumber(k) ):GetChild("Meter"):diffuse( DifficultyColor(difficulty) );
				af:GetChild("Grid"):GetChild( "Row" .. tonumber(k) ):GetChild("Meter"):settext(meter);
				
				-- our grid only supports charts with up to a 20-block difficulty meter
				-- but charts can have higher difficulties
				-- handle that here by setting a maximum number to worry about displaying
				if meter > gridLength then
					meter = gridLength
				end
								
				-- find the proper blocks by row then column,
				-- and diffuse each the appropriate color one by one
				for i=1,meter do
					af:GetChild("Grid"):GetChild("Row".. tonumber(k) ):GetChild("Block"..i):diffuse(DifficultyColor(difficulty));
				end
				
			end			
		end
	else
		-- is it safe to assume that if there isn't a song, we're on a group (folder)?
		-- for now, I'm going to have to go with "yes"
		af:propagatecommand("Group");
	end
end






local t = Def.ActorFrame{
	
	InitCommand=cmd(xy, SCREEN_CENTER_X / WideScale(2, 1.73), SCREEN_CENTER_Y + 70; );
	CurrentStepsP1ChangedMessageCommand=function(self)
		self:propagatecommand("Reset");
		ColorTheGrid(self);
	end;
	CurrentStepsP2ChangedMessageCommand=function(self)
		self:propagatecommand("Reset");
		ColorTheGrid(self);
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:propagatecommand("Reset");
		ColorTheGrid(self);
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
		
		LoadActor("cursor p1.png")..{
			InitCommand=cmd(zoom,0.6; x, WideScale(-142,-152); y,-36; );
			--OnCommand taken from freem's ITG3 SM5 port
			OnCommand=cmd(linear,.4;diffusealpha,1;bounce;effectmagnitude,-3,0,0;effectperiod,1.0;effectoffset,0.2;effectclock,"beat";);
			SetCommand=function(self)
				
				if GAMESTATE:IsHumanPlayer(PLAYER_1) then
					local currentSteps = GAMESTATE:GetCurrentSteps(PLAYER_1);
					if currentSteps then
						local currentDifficulty = currentSteps:GetDifficulty();
						local offset = GetYOffsetByDifficulty(currentDifficulty);
						self:y((offset-3) * 18);
					end
				end
			end;
			
			-- song and course changes
			CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
			CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
		
			CurrentStepsP1ChangedMessageCommand=function(self)
				self:playcommand("Set");
			end;
			CurrentTrailP1ChangedMessageCommand=function(self)
				self:playcommand("Set");
			end;
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
		LoadActor("cursor p2.png")..{
			InitCommand=cmd(zoom,0.6; x, WideScale(142,155); );
			--OnCommand taken from freem's ITG3 SM5 port
			OnCommand=cmd(linear,.4;diffusealpha,1;bounce;effectmagnitude,3,0,0;effectperiod,1.0;effectoffset,0.2;effectclock,"beat";);
			SetCommand=function(self)
				
				if GAMESTATE:IsHumanPlayer(PLAYER_2) then
					local currentSteps = GAMESTATE:GetCurrentSteps(PLAYER_2);
					if currentSteps then
						local currentDifficulty = currentSteps:GetDifficulty();
						local offset = GetYOffsetByDifficulty(currentDifficulty);
						self:y((offset-3) * 18);
					end
				end
			end;
			-- song and course changes
			CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
			CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
	
			CurrentStepsP2ChangedMessageCommand=function(self)
				self:playcommand("Set");
			end;
			CurrentTrailP2ChangedMessageCommand=function(self)
				self:playcommand("Set");
			end;
		};

	};
	
	
	
};



local function DrawRow(y_offset, nBlocks)

	local row = Def.ActorFrame{
		Name="Row"..y_offset;
		InitCommand=cmd(x,WideScale(-16,0); zoom,WideScale(0.98,1));
	};

	row[#row+1] = LoadFont("_wendy small")..{
		Name="Meter";
		Text="?";
		InitCommand=cmd(diffuse,DifficultyIndexColor(y_offset); zoom,0.3; y, y_offset * 18; x, WideScale(4,6); horizalign,right);
		ResetCommand=cmd(settext,"");
		GroupCommand=cmd(settext,"?"; diffuse,DifficultyIndexColor(y_offset);)	
	};

	for i=1,nBlocks do
	
		row[#row+1] = Def.Quad{
			Name="Block"..i;
			InitCommand=function(self)
				self:diffuse(color("#182025"));
				self:zoomto(WideScale(8, 9), 15);
				self:x(i * WideScale(13, 14));
				self:y(y_offset * 18);
			end;
			ResetCommand=cmd(diffuse,color("#182025"));
		};
	end
	
	return row
end




local function DrawGrid(nBlocks)
	
	local grid = Def.ActorFrame{
		Name="Grid";
		InitCommand=cmd(y, -53; x, -SCREEN_WIDTH/WideScale(6, 6.275));
	};

	for i=1,5 do
		grid[#grid+1] = DrawRow(i,nBlocks);
	end

	return grid
end




t[#t+1] = DrawGrid(gridLength);

return t;