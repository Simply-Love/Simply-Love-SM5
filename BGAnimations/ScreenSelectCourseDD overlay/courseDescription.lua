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


--[[[local group_durations = {}
for _,group_name in ipairs(SONGMAN:GetSongGroupNames()) do
	group_durations[group_name] = 0
	for _,song in ipairs(SONGMAN:GetSongsInGroup(group_name)) do
		group_durations[group_name] = group_durations[group_name] + song:MusicLengthSeconds()
	end
end--]]


-- ----------------------------------------
local MusicWheel, SelectedType

local af = Def.ActorFrame{
	OnCommand=function(self)
		self:xy(_screen.cx + (SCREEN_WIDTH/4),GAMESTATE:IsPlayerEnabled(1) and _screen.cy - 185 or _screen.cy - 167)
	end,

	CurrentCourseChangedMessageCommand=function(self)  self:playcommand("Set") end,
	CurrentStepsP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentTrailP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentTrailP2ChangedMessageCommand=function(self) self:playcommand("Set") end,
}


-- background Quad for both course description and course contents list
af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:vertalign(top)
		self:horizalign(left)
		self:zoomto(308, 324)
		self:diffuse(color("#7f7f7f"))
		self:addx(-196)
		self:addy(-31)
	end
}

-- background Quad for Artist, BPM, and Song 2
af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:zoomto(300, 22 )
		self:diffuse(color("#1e282f"))
		self:addx(-42)
		self:addy(-16)
	end
}

-- ActorFrame for Artist, BPM, Song length, and CDTitles because I'M GAY LOL
af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:xy(-138, -6) end,
	
	-- ----------------------------------------
	-- Song Count Label
	LoadFont("Common Normal")..{
		Text=THEME:GetString("SongDescription", "NumSongs")..":",
		InitCommand=function(self) 
			self
				:zoom(0.9)
				:horizalign(right)
				:y(-10)
				:x(-9)
				:maxwidth(44)
				:diffuse(0.5,0.5,0.5,1) end,
	},

	-- Number of Songs in this Course
	LoadFont("Common Normal")..{
		InitCommand=function(self) self:zoom(0.9):horizalign(left):xy(IsUsingWideScreen() and -4 or 1,-10):maxwidth(WideScale(225,260)) end,
		SetCommand=function(self)
			local course = GAMESTATE:GetCurrentCourse()
			self:settext( course and #course:GetCourseEntries() or "" )
		end
	},

	-- ----------------------------------------
	-- BPM Label
	LoadFont("Common Normal")..{
		Text=THEME:GetString("SongDescription", "BPM")..":",
		InitCommand=function(self)
			self
				:zoom(0.9)
				:y(-10)
				:x(45)
				:diffuse(0.5,0.5,0.5,1)
				if IsUsingWideScreen() then
					else
					self:x(10)
				end
		end
	},

	-- BPM value
	LoadFont("Common Normal")..{
		InitCommand=function(self)
			-- vertical align has to be middle for BPM value in case of split BPMs having a line break
			self:xy(92,-10):diffuse(1,1,1,1):vertspacing(-8)
		end,
		SetCommand=function(self)
			if GAMESTATE:GetCurrentCourse() == nil then
				self:settext("")
			return end
				
			if MusicWheel then SelectedType = MusicWheel:GetSelectedType() end

			-- if only one player is joined, stringify the DisplayBPMs and return early
			if #GAMESTATE:GetHumanPlayers() == 1 then
				-- StringifyDisplayBPMs() is defined in ./Scipts/SL-BPMDisplayHelpers.lua
				self:settext(StringifyDisplayBPMs() or ""):zoom(0.9)
				return
			end

			-- otherwise there is more than one player joined and the possibility of split BPMs
			local p1bpm = StringifyDisplayBPMs(PLAYER_1)
			local p2bpm = StringifyDisplayBPMs(PLAYER_2)

			-- it's likely that BPM range is the same for both charts
			-- no need to show BPM ranges for both players if so
			if p1bpm == p2bpm then
				self:settext(p1bpm):zoom(0.9)

			-- different BPM ranges for the two players
			else
				-- show the range for both P1 and P2 split by a newline characters, shrunk slightly to fit the space
				self:settext( "P1 ".. p1bpm .. "\n" .. "P2 " .. p2bpm ):zoom(0.6)
				-- the "P1 " and "P2 " segments of the string should be grey
				self:AddAttribute(0,             {Length=3, Diffuse={0.60,0.60,0.60,1}})
				self:AddAttribute(3+p1bpm:len(), {Length=3, Diffuse={0.60,0.60,0.60,1}})
				self:AddAttribute(3,             {Length=p1bpm:len(), Diffuse={1,1,1,1}})
				self:AddAttribute(7+p1bpm:len(), {Length=p2bpm:len(), Diffuse={1,1,1,1}})
			end
		end
	},

	-- ----------------------------------------
	-- Song Duration Label
	LoadFont("Common Normal")..{
		Text=THEME:GetString("SongDescription", "Length")..":",
		InitCommand=function(self)
			self:diffuse(0.5,0.5,0.5,1):zoom(0.9)
			self:x(160):y(-10)
		end
	},

	-- Song Duration Value
	LoadFont("Common Normal")..{
		InitCommand=function(self) 
			self
			:xy(210, -10) 
			:zoom(0.9)
			end,
		SetCommand=function(self)
			

			local seconds

			if SelectedType == "WheelItemDataType_Song" or "SwitchFocusToSingleCourse" then
				-- GAMESTATE:GetCurrentSong() can return nil here if we're in pay mode on round 2 (or later)
				-- and we're returning to SSM to find that the song we'd just played is no longer available
				-- because it exceeds the 2-round or 3-round time limit cutoff.
				local song = GAMESTATE:GetCurrentCourse()
				if song then
					local steps_type = GAMESTATE:GetCurrentStyle():GetStepsType()
					seconds = song:GetTotalSeconds(steps_type)
				end

			elseif SelectedType == "WheelItemDataType_Section" then
				-- MusicWheel:GetSelectedSection() will return a string for the text of the currently active WheelItem
				-- use it here to look up the overall duration of this group from our precalculated table of group durations
				seconds = group_durations[MusicWheel:GetSelectedSection()]
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
}
return af
