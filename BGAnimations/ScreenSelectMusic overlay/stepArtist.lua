local t = Def.ActorFrame{};


for p=1,2 do
	
	local player = "PlayerNumber_P"..p;


	t[#t+1] = Def.ActorFrame
	{
		InitCommand=function(self)		
			self:Center();
			if player == PLAYER_1 then
				self:player(PLAYER_1)
				self:addy(43.5);
				self:x( WideScale(8.5,79.5) );
			elseif player == PLAYER_2 then
				self:player(PLAYER_2)
				self:addy(96.5);
				self:x(SCREEN_CENTER_X - SCREEN_WIDTH/4 - WideScale(8.5,12.5));
			end
			
			if p == 1 and GAMESTATE:IsHumanPlayer(PLAYER_1) then
				self:queuecommand("AppearP1");
			end
			if p == 2 and GAMESTATE:IsHumanPlayer(PLAYER_2) then
				self:queuecommand("AppearP2");
			end
		end;
			
		AppearP1Command=cmd(visible, true; ease, 0.5, 275; addy, -30;);
		AppearP2Command=cmd(visible, true; ease, 0.5, 275; addy,  30;);
		
		PlayerJoinedMessageCommand=function(self, params)
			if p == 1 and	params.Player == PLAYER_1 then
				self:queuecommand("AppearP1");
			elseif p == 2 and params.Player == PLAYER_2 then
				self:queuecommand("AppearP2");
			end;
	 	end;
		
		
		

		
		-- colored background quad		
		Def.Quad{
			InitCommand=function(self)
			
				self:zoomto(SCREEN_WIDTH/4, SCREEN_HEIGHT/28);
				if player == PLAYER_1 then				
					self:diffuse(DifficultyIndexColor(2));
					self:horizalign(left);
				elseif player == PLAYER_2 then
					self:diffuse(DifficultyIndexColor(4));
					self:horizalign(left);
				end		
			end;
			SetCommand=function(self)
				
				if GAMESTATE:IsHumanPlayer(player) then
					local currentSteps = GAMESTATE:GetCurrentSteps(player);
					if currentSteps then
						local currentDifficulty = currentSteps:GetDifficulty();
						self:diffuse(DifficultyColor(currentDifficulty));
					end
				end
			end;
			
			
		};
	
		--STEPS label
		LoadFont("_misoreg hires")..{
			OnCommand=function(self)
				self:diffuse(color("0,0,0,1"));
				self:settext("STEPS");
				self:horizalign("HorizAlign_Left");
				
				if player == PLAYER_1 then
					self:x(10);
		 		elseif player == PLAYER_2 then
					self:addx(10);
				end
			end;
		};
	
		--stepartist text
		LoadFont("_misoreg hires")..{
			OnCommand=function(self)
				self:diffuse(color("#1e282f"));
				self:addx(45);
				self:horizalign("HorizAlign_Left");
				
				self:zoom(WideScale(0.9,1));
				self:maxwidth(WideScale(115,200));
				
				
				if player == PLAYER_1 then
					 self:x(55);
		 		elseif player == PLAYER_2 then
				 	self:addx(10);
				end	
			end;
			SetCommand=function(self)
				local stepartist;
				local cs = GAMESTATE:GetCurrentSteps(player);
				
				if cs then
					stepartist = cs:GetAuthorCredit();
				end;
				
				if stepartist then
					if stepartist ~= "" then
						self:settext(stepartist);
					else
						self:settext("???");
					end
				end
				
				
				local song = GAMESTATE:GetCurrentSong();
				local course = GAMESTATE:GetCurrentCourse();
				self:visible(song ~= nil or course ~= nil)
			end;
		};
		
		-- song and course changes
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
		
		CurrentStepsP1ChangedMessageCommand=function(self)
			if player == PLAYER_1 then self:playcommand("Set"); end;
		end;
		CurrentTrailP1ChangedMessageCommand=function(self)
			if player == PLAYER_1 then self:playcommand("Set"); end;
		end;
		CurrentStepsP2ChangedMessageCommand=function(self)
			if player == PLAYER_2 then self:playcommand("Set"); end;
		end;
		CurrentTrailP2ChangedMessageCommand=function(self)
			if player == PLAYER_2 then self:playcommand("Set"); end;
		end;
	};
end

return t;