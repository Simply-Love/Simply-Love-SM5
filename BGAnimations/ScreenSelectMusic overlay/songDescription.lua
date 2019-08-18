-- before loading actors, pre-calculate each group's overall duration by
-- looping through its songs and summing their duration
-- store each group's overall duration in a lookup table, keyed by group_name
-- to be retrieved + displayed when actively hovering on a group (not a song)
--
-- I haven't checked, but I assume that continually recalculating group durations could
-- have performance ramifications when rapidly scrolling through the MusicWheel
--
-- a consequence of pre-calculating and storing the group_durations like this is that
-- live-reloading a song on ScreenSelectMusic via Control R might cause the group duration
-- to then be inaccurate, until the screen is reloaded.

local group_durations = {}
local stages_remaining = GAMESTATE:GetNumStagesLeft(GAMESTATE:GetMasterPlayerNumber())

for _,group_name in ipairs(SONGMAN:GetSongGroupNames()) do
	group_durations[group_name] = 0

	for _,song in ipairs(SONGMAN:GetSongsInGroup(group_name)) do
		local song_cost = song:IsMarathon() and 3 or song:IsLong() and 2 or 1

		if song_cost <= stages_remaining then
			group_durations[group_name] = group_durations[group_name] + song:MusicLengthSeconds()
		end
	end
end

-- ----------------------------------------

local t = Def.ActorFrame{

	OnCommand=function(self)
		self:xy(_screen.cx - (IsUsingWideScreen() and 170 or 165), _screen.cy - 28)
	end,

	-- ----------------------------------------
	-- Actorframe for Artist, BPM, and Song length
	Def.ActorFrame{
		CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentStepsP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentTrailP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentStepsP2ChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentTrailP2ChangedMessageCommand=function(self) self:playcommand("Set") end,

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

			InitCommand=function(self) self:x(-110) end,

			-- Artist Label
			LoadFont("Common Normal")..{
				InitCommand=function(self)
					local text = GAMESTATE:IsCourseMode() and "NumSongs" or "Artist"
					self:settext( THEME:GetString("SongDescription", text) )
						:horizalign(right):y(-12)
						:maxwidth(44)
				end,
				OnCommand=function(self) self:diffuse(0.5,0.5,0.5,1) end
			},

			-- Song Artist
			LoadFont("Common Normal")..{
				InitCommand=cmd(horizalign,left; xy, 5,-12; maxwidth,WideScale(225,260) ),
				SetCommand=function(self)
					if GAMESTATE:IsCourseMode() then
						local course = GAMESTATE:GetCurrentCourse()
						self:settext( course and #course:GetCourseEntries() or "" )
					else
						local song = GAMESTATE:GetCurrentSong()
						self:settext( song and song:GetDisplayArtist() or "" )
					end
				end
			},



			-- BPM Label
			LoadFont("Common Normal")..{
				Text=THEME:GetString("SongDescription", "BPM"),
				InitCommand=function(self)
					self:horizalign(right):y(8)
						:diffuse(0.5,0.5,0.5,1)
				end
			},

			-- BPM value
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(5,8):diffuse(1,1,1,1) end,
				SetCommand=function(self)
					--defined in ./Scipts/SL-BPMDisplayHelpers.lua
					local text = GetDisplayBPMs()
					self:settext(text or "")
				end
			},

			-- Song Duration Label
			LoadFont("Common Normal")..{
				Text=THEME:GetString("SongDescription", "Length"),
				InitCommand=function(self)
					self:horizalign(right)
						:x(_screen.w/4.5):y(8)
						:diffuse(0.5,0.5,0.5,1)
				end
			},

			-- Song Duration Value
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(_screen.w/4.5 + 5, 8) end,
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
						else
							local group_name = SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection()
							if group_name then
								duration = group_durations[group_name]
							end
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

		-- long/marathon version bubble graphic and text
		Def.ActorFrame{
			OnCommand=function(self)
				self:x( IsUsingWideScreen() and 102 or 97 )
			end,
			SetCommand=function(self)
				local song = GAMESTATE:GetCurrentSong()
				self:visible( song and (song:IsLong() or song:IsMarathon()) or false )
			end,

			LoadActor("bubble")..{
				InitCommand=function(self) self:diffuse(GetCurrentColor()):zoom(0.455):y(29) end
			},

			LoadFont("Common Normal")..{
				InitCommand=function(self) self:diffuse(Color.Black):zoom(0.8):y(34) end,
				SetCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()
					if not song then self:settext(""); return end

					if song:IsMarathon() then
						self:settext(THEME:GetString("SongDescription", "IsMarathon"))
					elseif song:IsLong() then
						self:settext(THEME:GetString("SongDescription", "IsLong"))
					else
						self:settext("")
					end
				end
			}
		}
	}
}

return t
