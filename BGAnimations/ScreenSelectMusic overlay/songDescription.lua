local t = Def.ActorFrame{

	OnCommand=function(self)
		if IsUsingWideScreen() then
				self:x(_screen.cx - 197)
				if GAMESTATE:IsCourseMode() then
					self:y(_screen.cy - 52)
				else
					self:y(_screen.cy - 42)
				end
		else
			self:x(_screen.cx - 165)
			if GAMESTATE:IsCourseMode() then
				self:y(_screen.cy - 52)
			else
				self:y(_screen.cy - 42)
			end
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
					if GAMESTATE:IsCourseMode() then
						self:zoomto( IsUsingWideScreen() and 320 or 310, 48 )
					else
						self:zoomto( IsUsingWideScreen() and 320 or 310, 67 )
					end
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
					if GAMESTATE:IsCourseMode() then
						self:horizalign(right):y(-12)
					else
						self:horizalign(right):y(0)
					end
				end,
				OnCommand=cmd(diffuse,color("0.5,0.5,0.5,1"))
			},

			-- Song Artist
			LoadFont("_miso")..{
				InitCommand=function(self)
					self:horizalign('left')
					if GAMESTATE:IsCourseMode() then
						self:maxwidth(WideScale(225,260))
						self:xy(5,-12)
					else
						self:maxwidth(WideScale(255,260))
						self:xy(5,0)
					end
				end,
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

			-- Song Folder Label
			LoadFont("_miso")..{
				InitCommand=function(self)
					if GAMESTATE:IsCourseMode() then
						self:visible(false)
					end
					self:horizalign(right);
					self:y(-20)
					if ThemePrefs.Get("VerboseSongFolder") then
						self:settext(THEME:GetString("SongDescription", "Folder"))
					else
						self:settext(THEME:GetString("SongDescription", "Group"))
					end
				end,
				OnCommand=cmd(diffuse,color("0.5,0.5,0.5,1"))
			},

			-- Song Folder
			LoadFont("_miso")..{
				InitCommand=cmd(horizalign,left; xy, 6,-20; maxwidth,WideScale(255,260) ),
				SetCommand=function( actor )
					local song = GAMESTATE:GetCurrentSong()
					local text = ""
						if ThemePrefs.Get("VerboseSongFolder") then
							if song then
									--I would like to find a better method to trim up GetSongDir, but this will work for now, because I highly doubt people will name their packs "Songs" or "AdditionalSongs"
								local fulldir = song:GetSongDir();
									--removes the "/ " suffix placed by GetSongDir() (will not impact
								local remove_end = string.sub(fulldir, 0, -2);
									--removes "/Songs/" prefix, but if a songs folder is called "Songs" you'll get weird formatting
								local trimmed_dir = string.gsub(remove_end, "/Songs/", "", 1)
									--removes "/AdditionalSongs/" from the directory string, and will cause formatting weirdness if there is a song folder with that name
								local SongDir = string.gsub(trimmed_dir, "/AdditionalSongs/", "", 1)
								text = SongDir
							end
					   actor:settext( text )
					 else

				--  This is a cleaner way to call the group name of a selected song, but I prefer the above method because it shows the actual songfolder directory, which sometimes has information in it. You can set your preference in Simply Love Options for which method you prefer.
						 if song then
							 actor:settext(song:GetGroupName());
						 else
							 actor:settext("")
						 end
					 end
				end
			},

			-- BPM Label
			LoadFont("_miso")..{
				InitCommand=function(self)
					self:horizalign(right)
					self:NoStroke()
					if GAMESTATE:IsCourseMode() then
						self:y(8)
					else
						self:y(20)
					end
				end,
				SetCommand=function(self)
					self:diffuse(0.5,0.5,0.5,1)
					self:settext( THEME:GetString("SongDescription", "BPM")  )
				end
			},

			-- BPM value
			LoadFont("_miso")..{
				InitCommand=function(self)
					self:horizalign(left)
					self:NoStroke()
					self:x(5)
					self:diffuse(color(1,1,1,1))
					if GAMESTATE:IsCourseMode() then
						self:y(8)
					else
						self:y(20)
					end
				end,
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
				InitCommand=function(self)
					self:horizalign(right)
					self:NoStroke()
					if GAMESTATE:IsCourseMode() then
						self:xy(_screen.w/4.5,8)
					else
						self:xy(200,20)
					end
				end,
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()
					self:diffuse(0.5,0.5,0.5,1)
					self:settext( THEME:GetString("SongDescription", "Length") )
				end
			},

			-- Song Length Value
			LoadFont("_miso")..{
				InitCommand=function(self)
					self:horizalign(left)
					self:NoStroke()
					if GAMESTATE:IsCourseMode() then
						self:xy(_screen.w/4.5 + 5,8)
					else
						self:xy(207,20)
					end
				end,
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
						duration = duration / SL.Global.ActiveModifiers.MusicRate
						if duration == 105.0 then
							-- r21 lol
							self:settext( THEME:GetString("SongDescription", "r21") )
						else
							local hours = 0
							if duration > 3600 then
								hours = math.floor(duration / 3600)
								duration = duration % 3600
							end

							local finalText
							if hours > 0 then
								-- where's HMMSS when you need it?
								finalText = hours .. ":" .. SecondsToMMSS(duration)
							else
								finalText = SecondsToMSS(duration)
							end

							self:settext( finalText )
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
					self:x(103)
				else
					self:x(97)
				end
			end,

			LoadActor("bubble.png")..{
				InitCommand=function(self)
					self:diffuse(GetCurrentColor())
					self:visible(false)
					self:zoom(0.9)
					if GAMESTATE:IsCourseMode() then
						self:y(30)
					else
						self:y(39)
					end
				end,
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
				InitCommand=function(self)
					self:diffuse(Color.Black)
					self:zoom(0.8)
					if GAMESTATE:IsCourseMode() then
						self:y(34)
					else
						self:y(43)
					end
				end,
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
