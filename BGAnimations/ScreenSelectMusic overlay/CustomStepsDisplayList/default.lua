local gridLength = 20
local gridZoomFactor = 0.27
if IsUsingWideScreen() then	gridZoomFactor = 0.28 end

local t = Def.ActorFrame{
	
	InitCommand=function(self)
		if IsUsingWideScreen() then
			self:xy(_screen.cx - 173, _screen.cy + 70)
		else
			self:xy(_screen.cx - 163, _screen.cy + 70)
		end
	end,
	
	CurrentStepsP1ChangedMessageCommand=cmd(propagatecommand,"Reset"),
	CurrentStepsP2ChangedMessageCommand=cmd(propagatecommand,"Reset"),
	CurrentTrailP1ChangedMessageCommand=cmd(propagatecommand,"Reset"),
	CurrentTrailP2ChangedMessageCommand=cmd(propagatecommand,"Reset"),
	CurrentSongChangedMessageCommand=cmd(propagatecommand,"Reset"),

	-- background
	Def.Quad{
		Name="Background",
		InitCommand=function(self)
			self:diffuse(color("#1e282f"))
			if IsUsingWideScreen() then
				self:zoomto(320, _screen.h/5)
			else
				self:zoomto(310, _screen.h/5)
			end
		end
	},

	LoadActor("cursor", PLAYER_1),
	LoadActor("cursor", PLAYER_2)
}

-- the grey background blocks
t[#t+1] = LoadActor("_block.png")..{
	Name="BackgroundBlocks",
	InitCommand=cmd(diffuse,color("#182025"); halign,0),
	OnCommand=function(self)
		width = self:GetWidth()
		height= self:GetHeight()
		self:x(-(width * gridLength)/4 + WideScale(32,26))
		self:zoomto(width * gridLength * gridZoomFactor * 1.55, height * 5 * gridZoomFactor)
		self:customtexturerect(0, 0, gridLength, 5)
	end
}


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