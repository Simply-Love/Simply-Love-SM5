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

		if GAMESTATE:IsEventMode() or song_cost <= stages_remaining then
			group_durations[group_name] = group_durations[group_name] + song:MusicLengthSeconds()
		end
	end
end

-- ----------------------------------------
local MusicWheel, SelectedType

local t = Def.ActorFrame{

	OnCommand=function(self)
		self:xy(_screen.cx - (IsUsingWideScreen() and 170 or 165), _screen.cy - 28)
	end,

	-- ----------------------------------------
	-- ActorFrame for Artist, BPM, and Song length
	Def.ActorFrame{
		CurrentSongChangedMessageCommand=function(self)    self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self)  self:playcommand("Set") end,
		CurrentStepsP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentTrailP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentStepsP2ChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentTrailP2ChangedMessageCommand=function(self) self:playcommand("Set") end,

		-- background for Artist, BPM, and Song Length
		Def.Quad{
			InitCommand=function(self)
				self:setsize( IsUsingWideScreen() and 320 or 310, 53 )
				self:diffuse(color("#1e282f")):y(-3)

				if ThemePrefs.Get("RainbowMode") then self:diffusealpha(0.9) end
			end
		},

		Def.ActorFrame{

			InitCommand=function(self) self:x(-110) end,

			-- Artist Label
			LoadFont("Common Normal")..{
				Text=THEME:GetString("SongDescription", GAMESTATE:IsCourseMode() and "NumSongs" or "Artist"),
				InitCommand=function(self) self:horizalign(right):y(-12.5):maxwidth(44) end,
				OnCommand=function(self) self:diffuse(0.5,0.5,0.5,1) end
			},

			-- Song Artist (or number of Songs in this Course, if CourseMode)
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(5,-12.5):maxwidth(WideScale(225,260)) end,
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
					self:horizalign(right):y(9)
						:diffuse(0.5,0.5,0.5,1)
				end
			},

			-- BPM value
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(5,9):diffuse(1,1,1,1):vertspacing(-7) end,
				SetCommand=function(self)

					if MusicWheel then SelectedType = MusicWheel:GetSelectedType() end

					-- we only want to try to show BPM values for Songs and Courses
					-- not Section, Roulette, Random, Portal, Sort, or Custom
					-- (aside: what is "WheelItemDataType_Custom"?  I need to look into that.)
					if not (SelectedType=="WheelItemDataType_Song" or SelectedType=="WheelItemDataType_Course") then
						self:settext("")
						return
					end

					-- if only one player is joined, stringify the DisplayBPMs and return early
					if #GAMESTATE:GetHumanPlayers() == 1 then
						-- StringifyDisplayBPMs() is defined in ./Scipts/SL-BPMDisplayHelpers.lua
						self:settext(StringifyDisplayBPMs() or ""):zoom(1)
						return
					end

					-- otherwise there is more than one player joined and the possibility of split BPMs
					local p1bpm = StringifyDisplayBPMs(PLAYER_1)
					local p2bpm = StringifyDisplayBPMs(PLAYER_2)

					-- it's likely that BPM range is the same for both charts
					-- no need to show BPM ranges for both players if so
					if p1bpm == p2bpm then
						self:settext(p1bpm):zoom(1)

					-- different BPM ranges for the two players
					else
						-- show the range for both P1 and P2 split by a newline characters, shrunk slightly to fit the space
						self:settext( "P1 ".. p1bpm .. "\n" .. "P2 " .. p2bpm ):zoom(0.8)
						-- the "P1 " and "P2 " segments of the string should be grey
						self:AddAttribute(0,             {Length=3, Diffuse={0.60,0.60,0.60,1}})
						self:AddAttribute(3+p1bpm:len(), {Length=3, Diffuse={0.60,0.60,0.60,1}})

						if GAMESTATE:IsCourseMode() then
							-- P1 and P2's BPM text in CourseMode is white until I have time to figure CourseMode out
							self:AddAttribute(3,             {Length=p1bpm:len(), Diffuse={1,1,1,1}})
							self:AddAttribute(7+p1bpm:len(), {Length=p2bpm:len(), Diffuse={1,1,1,1}})

						else
							-- P1 and P2's BPM text is the color of their difficulty
							if GAMESTATE:GetCurrentSteps(PLAYER_1) then
								self:AddAttribute(3,             {Length=p1bpm:len(), Diffuse=DifficultyColor(GAMESTATE:GetCurrentSteps(PLAYER_1):GetDifficulty())})
							end
							if GAMESTATE:GetCurrentSteps(PLAYER_2) then
								self:AddAttribute(7+p1bpm:len(), {Length=p2bpm:len(), Diffuse=DifficultyColor(GAMESTATE:GetCurrentSteps(PLAYER_2):GetDifficulty())})
							end
						end
					end
				end
			},

			-- Song Duration Label
			LoadFont("Common Normal")..{
				Text=THEME:GetString("SongDescription", "Length"),
				InitCommand=function(self)
					self:horizalign(right):diffuse(0.5,0.5,0.5,1)
						:x(_screen.w/4.5):y(8)
				end
			},

			-- Song Duration Value
			LoadFont("Common Normal")..{
				InitCommand=function(self) self:horizalign(left):xy(_screen.w/4.5 + 5, 8) end,
				SetCommand=function(self)
					if MusicWheel == nil then MusicWheel = SCREENMAN:GetTopScreen():GetMusicWheel() end

					SelectedType = MusicWheel:GetSelectedType()
					local seconds

					if SelectedType == "WheelItemDataType_Song" then
						-- GAMESTATE:GetCurrentSong() can return nil here if we're in pay mode on round 2 (or later)
						-- and we're returning to SSM to find that the song we'd just played is no longer available
						-- because it exceeds the 2-round or 3-round time limit cutoff.
						local song = GAMESTATE:GetCurrentSong()
						if song then
							seconds = song:MusicLengthSeconds()
						end

					elseif SelectedType == "WheelItemDataType_Section" then
						-- MusicWheel:GetSelectedSection() will return a string for the text of the currently active WheelItem
						-- use it here to look up the overall duration of this group from our precalculated table of group durations
						seconds = group_durations[MusicWheel:GetSelectedSection()]

					elseif SelectedType == "WheelItemDataType_Course" then
						-- is it possible for 2 Trails within the same Course to have differing durations?
						-- I can't think of a scenario where that would happen, but hey, this is StepMania.
						-- In any case, I'm opting to display the duration of the MPN's current trail.
						local trail = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber())
						if trail then
							seconds = TrailUtil.GetTotalSeconds(trail)
						end
					end

					-- r21 lol
					if seconds == 105.0 then self:settext(THEME:GetString("SongDescription", "r21")); return end

					if seconds then
						seconds = seconds / SL.Global.ActiveModifiers.MusicRate

						-- longer than 1 hour in length
						if seconds > 3600 then
							-- format to display as H:MM:SS
							self:settext(math.floor(seconds/3600) .. ":" .. SecondsToMMSS(seconds%3600))
						else
							-- format to display as M:SS
							self:settext(SecondsToMSS(seconds))
						end
					else
						self:settext("")
					end
				end
			}
		},

		-- long/marathon version bubble graphic and text
		Def.ActorFrame{
			InitCommand=function(self)
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
