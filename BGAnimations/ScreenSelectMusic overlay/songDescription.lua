local t = Def.ActorFrame{

	InitCommand=cmd(xy, SCREEN_CENTER_X/WideScale(2,1.73), SCREEN_CENTER_Y - 40 );
	

	-- ----------------------------------------
	-- Actorframe for Artist, BPM, and Song length
	Def.ActorFrame{
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
		CurrentStepsP1ChangedMessageCommand=function(self)
			self:playcommand("Set");
		end;
		CurrentTrailP1ChangedMessageCommand=function(self)
			self:playcommand("Set");
		end;
		CurrentStepsP2ChangedMessageCommand=function(self)
			self:playcommand("Set");
		end;
		CurrentTrailP2ChangedMessageCommand=function(self)
			self:playcommand("Set");
		end;
		
		-- background for Artist, BPM, and Song Length
		Def.Quad{
			InitCommand=cmd(diffuse, color("#1e282f"); zoomto, SCREEN_WIDTH/WideScale(2.05, 2.47) - 10, SCREEN_HEIGHT/10; addy, 12; )
		};
		
	
	
		Def.ActorFrame{
			
			InitCommand=cmd(horizalign, left; x, -SCREEN_WIDTH/7.25);
			
			-- Artist Label
			LoadFont("_misoreg hires")..{
				Text="ARTIST";
				InitCommand=cmd(horizalign, right; NoStroke;);
				OnCommand=cmd(diffuse,color("0.5,0.5,0.5,1"););
			};

			-- Song Artist
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(horizalign,left; NoStroke; addx, 5 );
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong();
					
					self:maxwidth(WideScale(225,300));
					
					if song then
						if song:GetDisplayArtist() then
							self:settext(song:GetDisplayArtist());
						end
					else
						self:settext("");
					end
				end;
			};



			-- BPM Label
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(horizalign, right; NoStroke; y, 20);
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong();
					self:diffuse(0.5,0.5,0.5,1);
					self:settext("BPM");
				end;
			};

			-- BPM value
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(horizalign, left; NoStroke; y, 20; x, 5; diffuse, color("1,1,1,1"));
				SetCommand=function(self)
						
					--defined in ./Scipts/SL-Other.lua
					local text = GetDisplayBPMs();
						
					if text then	
						self:settext(text);	
					else
						self:settext("");
					end
				end;
			};
			
			-- Song Length Label
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(horizalign, right; NoStroke; y, 20; x, SCREEN_WIDTH/4.5);
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong();
					self:diffuse(0.5,0.5,0.5,1);
					self:settext("LENGTH");
				end;
			};
	
			-- Song Length Value
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(horizalign, left; NoStroke; y, 20; x, SCREEN_WIDTH/4.5 + 5);
				SetCommand=function(self)
					local duration;
			
					if GAMESTATE:IsCourseMode() then
						local Players = GAMESTATE:GetHumanPlayers();
						local player = Players[1];		
						local trail = GAMESTATE:GetCurrentTrail(player);
						
						if trail then
							duration = TrailUtil.GetTotalSeconds(trail);
						end
					else
						local song = GAMESTATE:GetCurrentSong();
						if song then
							duration = song:MusicLengthSeconds();
						end
					end;
					
					
					if duration then
						self:diffuse(1,1,1,1);
					
						if duration == 105.0 then
							-- r21 lol							
							self:settext("not 1:45");
						else
							local finalText = SecondsToMSSMsMs(duration);
							self:settext( string.sub(finalText, 0, string.len(finalText)-3) );
						end;
					else
						self:settext("")
					end
			
				end;
			};
		};
	
		Def.ActorFrame{
			LoadActor("bubble.png")..{
				InitCommand=cmd(diffuse,GetCurrentColor();visible, false; zoom, 0.9; y,WideScale(42,41.5); x,WideScale(93.5,110.5));
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong();
				
					if song then
						if song:IsLong() then
							self:visible(true);
						elseif song:IsMarathon() then
							self:visible(true);
						else
							self:visible(false);
						end
					else
						self:visible(false);
					end
				end;
			};
			
			LoadFont("_misoreg hires")..{
				InitCommand=cmd(diffuse, color("#000000"); zoom,0.8; y,46; x,WideScale(93.5,110.5));
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong();
				
					if song then
						if song:IsLong() then
							self:settext("COUNTS AS 2 ROUNDS");
						elseif song:IsMarathon() then
							self:settext("COUNTS AS 3 ROUNDS");
						else
							self:settext("");
						end
					else
						self:settext("");
					end
				end;				
			};
		};	
	};
	
};


return t;