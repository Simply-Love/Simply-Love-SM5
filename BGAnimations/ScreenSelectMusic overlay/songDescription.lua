local t = Def.ActorFrame{

	OnCommand=function(self)
		if IsUsingWideScreen() then
			self:xy(_screen.cx - 170, _screen.cy - 28)
		else
			self:xy(_screen.cx - 165, _screen.cy - 28)
		end
	end,

	-- ----------------------------------------
	-- Actorframe for Artist, BPM, and Song length
	Def.ActorFrame{
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentTrailP1ChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentStepsP2ChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentTrailP2ChangedMessageCommand=cmd(playcommand,"Set"),

		-- background for Artist, BPM, and Song Length
		Def.Quad{
			InitCommand=function(self)
				self:diffuse(color("#1e282f"))
					:zoomto( IsUsingWideScreen() and 320 or 310, 48 )

				if ThemePrefs.Get("RainbowMode") then
					self:diffusealpha(0.75)
				end
			end
		},

		Def.ActorFrame{

			InitCommand=cmd(x, -110),

			-- Artist Label
			LoadFont("_miso")..{
				InitCommand=function(self)
					local text = GAMESTATE:IsCourseMode() and "NumSongs" or "Artist"
					self:settext( THEME:GetString("SongDescription", text) )
						:horizalign(right):y(-12)
				end,
				OnCommand=cmd(diffuse,color("0.5,0.5,0.5,1"))
			},

			-- Song Artist
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign,left; xy, 5,-12; maxwidth,WideScale(225,260) ),
				SetCommand=function(self)
					if GAMESTATE:IsCourseMode() then
						local course = GAMESTATE:GetCurrentCourse()
						if course then
							self:settext( #course:GetCourseEntries() )
						else
							self:settext("")
						end
					else
						local song = GAMESTATE:GetCurrentSong()
						if song and song:GetDisplayArtist() then
							self:settext( song:GetDisplayArtist() )
						else
							self:settext("")
						end
					end
				end
			},



			-- BPM Label
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign, right; NoStroke; y, 8),
				SetCommand=function(self)
					self:diffuse(0.5,0.5,0.5,1)
					self:settext( THEME:GetString("SongDescription", "BPM")  )
				end
			},

			-- BPM value
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign, left; NoStroke; y, 8; x, 5; diffuse, color("1,1,1,1")),
				SetCommand=function(self)

					--defined in ./Scipts/SL-CustomSpeedMods.lua
					local text = GetDisplayBPMs()

					if text then
						self:settext(text)
					else
						self:settext("")
					end
				end
			},

			-- Song Length Label
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign, right; y, 8; x, _screen.w/4.5),
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()
					self:diffuse(0.5,0.5,0.5,1)
					self:settext( THEME:GetString("SongDescription", "Length") )
				end
			},

			-- Song Length Value
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign, left; y, 8; x, _screen.w/4.5 + 5),
				SetCommand=function(self)
					local duration

					if GAMESTATE:IsCourseMode() then
						local Players = GAMESTATE:GetHumanPlayers()
						local player = Players[1]
						local trail = GAMESTATE:GetCurrentTrail(player)

						if trail then
							duration = TrailUtil.GetTotalSeconds(trail)
						end
					else
						local song = GAMESTATE:GetCurrentSong()
						if song then
							duration = song:MusicLengthSeconds()
						end
					end


					if duration then
						if duration == 105.0 then
							-- r21 lol
							self:settext( THEME:GetString("SongDescription", "r21") )
						else
							local finalText = SecondsToMSSMsMs(duration)
							self:settext( string.sub(finalText, 0, finalText:len()-3) )
						end
					else
						self:settext("")
					end
				end
			}
		},

		Def.ActorFrame{
			OnCommand=function(self)
				if IsUsingWideScreen() then
					self:x(102)
				else
					self:x(97)
				end
			end,

			LoadActor("bubble.png")..{
				InitCommand=cmd(diffuse,GetCurrentColor(); visible, false; zoom, 0.9; y, 30),
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()

					if song then
						if song:IsLong() or song:IsMarathon() then
							self:visible(true)
						else
							self:visible(false)
						end
					else
						self:visible(false)
					end
				end
			},

			LoadFont("_miso")..{
				InitCommand=cmd(diffuse, Color.Black; zoom,0.8; y, 34),
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()

					if song then
						if song:IsLong() then
							self:settext( THEME:GetString("SongDescription", "IsLong") )
						elseif song:IsMarathon() then
							self:settext( THEME:GetString("SongDescription", "IsMarathon")  )
						else
							self:settext("")
						end
					else
						self:settext("")
					end
				end
			}
		}
	}
}

return t