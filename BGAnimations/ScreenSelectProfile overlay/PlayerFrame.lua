local player = ...

-- I tried really hard to use size + position variables instead of hardcoded numbers all over
-- the place, but gave up after an hour of questioning my sanity due to sub-pixel overlap
-- issues (rounding? texture sizing? I don't have time to figure it out right now.)
local row_height = 35

-- ----------------------------------------------------
-- retrieve and process data (mods, most recently played song, high score name, etc.)
-- for each profile at Init and put it in the profile_data table indexed by "ProfileIndex" (provided by engine)
-- for quick lookup later

local profile_data = {}

-- some local functions that will help process profile data into presentable strings
local RecentMods = function(mods)
	if type(mods) ~= "table" then return "" end

	local text = ""

	if mods.SpeedModType=="x" and mods.SpeedMod > 0 then text = text..tostring(mods.SpeedMod).."x, "
	elseif (mods.SpeedModType=="M" or mods.SpeedModType=="C") and mods.SpeedMod > 0 then text = text..mods.SpeedModType..tostring(mods.SpeedMod)..", "
	end

	if mods.NoteSkin ~= "" then text = text..mods.NoteSkin..", " end
	if mods.Mini ~= "" then text = text..mods.Mini.." "..THEME:GetString("OptionTitles", "Mini")..", " end
	if mods.JudgmentGraphic ~= "" then text = text..StripSpriteHints(mods.JudgmentGraphic) .. ", " end

	-- loop for mods that save as booleans
	local flags, hideflags = "", ""
	for k,v in pairs(mods) do
		-- explicitly check for true (not Lua truthiness)
		if v == true then
			if k:match("Hide") then
				hideflags = hideflags..THEME:GetString("ThemePrefs", "Hide").." "..THEME:GetString("SLPlayerOptions",k:gsub("Hide",""))..", "
			else
				flags = flags..THEME:GetString("SLPlayerOptions", k)..", "
			end
		end
	end
	text = text .. hideflags .. flags

	if mods.DataVisualizations=="Target Score Graph" or mods.DataVisualizations=="Step Statistics" then
		text = text .. THEME:GetString("SLPlayerOptions", mods.DataVisualizations)..", "
	end
	-- remove trailing comma and whitespace
	text = text:sub(1,-3)
	return text
end

local RecentSong = function(song)
	if not song then return "" end
	return (song:GetGroupName() .. "/" .. song:GetDisplayMainTitle())
end

-- profiles have a GetTotalSessions() method, but the value doesn't (seem to?) increment in EventMode
-- making it much less useful for the players who will most likely be using this screen
-- for now, just retrieve total songs played
local TotalSongs = function(numSongs)
	if numSongs == 1 then
		return Screen.String("SingularSongPlayed"):format(numSongs)
	else
		return Screen.String("SeveralSongsPlayed"):format(numSongs)
	end
	return ""
end

-- find the grade the player has most frequently earned in single style, summing across all difficulties
-- I wrote code to support double as well, but have removed it for now due to UI concerns.  Forgive me, TAKASKE-.
local GradeCounts = function(profile)
	local t = {}
	local game = GAMESTATE:GetCurrentGame():GetName()
	local num_grade_tiers = THEME:GetMetric("PlayerStageStats", "NumGradeTiersUsed")
	local style = game=="techno" and "Single8" or "Single"
	local styletype = "StepsType_" .. game:gsub("^%l", string.upper) .. "_" .. style

	-- beginner through challenge
	for difficulty=0,4 do
		-- all available grade tiers
		for grade=0,(num_grade_tiers-1) do
			if not t[grade+1] then t[grade+1] = 0 end
			t[grade+1] = t[grade+1] + profile:GetTotalStepsWithTopGrade(styletype, difficulty, grade)
		end
	end

	local _count = 0
	local _tier
	-- count down in gradetiers (from D to QuadStar) so that if two gradetiers
	-- tie in frequency, we show the player the better grade
	for i=(num_grade_tiers),1,-1 do
		if t[i] > _count then
			_count = t[i]
			_tier = i
		end
	end

	return {tier=_tier, count=_count}
end

-- ----------------------------------------------------

local GetLocalProfiles = function()
	local t = {}

	for i=0, PROFILEMAN:GetNumLocalProfiles()-1 do

		local profile = PROFILEMAN:GetLocalProfileFromIndex(i)

		t[#t+1] = LoadFont("_miso")..{
			Text=profile:GetDisplayName(),
			InitCommand=function(self)
				-- ztest(true) ensures that the text masks properly when scrolling above/below the frame
				self:ztest(true):maxwidth(115)

				-- while we're in this loop and have a handle to this profile, gather relevant data
				local id = PROFILEMAN:GetLocalProfileIDFromIndex(i)
				local dir = PROFILEMAN:LocalProfileIDToDir(id)
				local userprefs = ReadProfileCustom(profile, dir)

				profile_data[i] = {
					highscorename = profile:GetLastUsedHighScoreName(),
					recentsong = RecentSong(profile:GetLastPlayedSong()),
					totalsongs = TotalSongs(profile:GetNumTotalSongsPlayed()),
					grades = GradeCounts(profile),
					mods = RecentMods(userprefs)
				}
			end
		}
	end

	return t
end

local FrameBackground = function(c, player, w)
	w = w or 1

	return Def.ActorFrame {
		InitCommand=function(self) self:zoomto(w, 1) end,

		-- a lightly styled png asset that is not so different than a Quad
		-- currently inherited from _fallback
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardBackground") )..{
			InitCommand=function(self)
				self:diffuse(c):cropbottom(1)
			end,
			OnCommand=function(self) self:smooth(0.3):cropbottom(0) end,
			OffCommand=function(self)
				if not GAMESTATE:IsSideJoined(player) then
					self:accelerate(0.25):cropbottom(1)
				end
			end
		},

		-- a png asset that gives the colored frame (above) a lightly frosted feel
		-- currently inherited from _fallback
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardFrame") )..{
			InitCommand=function(self) self:cropbottom(1) end,
			OnCommand=function(self) self:smooth(0.3):cropbottom(0) end,
			OffCommand=function(self)
				if not GAMESTATE:IsSideJoined(player) then
					self:accelerate(0.25):cropbottom(1)
				end
			end
		}
	}
end

return Def.ActorFrame{
	Name=ToEnumShortString(player) .. "Frame",
	InitCommand=function(self) self:xy(_screen.cx+(150*(player==PLAYER_1 and -1 or 1)), _screen.cy) end,
	OffCommand=function(self)
		if GAMESTATE:IsSideJoined(player) then
			self:bouncebegin(0.35):zoom(0)
		end
	end,
	InvalidChoiceMessageCommand=function(self, params)
		if params.PlayerNumber == player then
			self:finishtweening():bounceend(0.1):addx(5):bounceend(0.1):addx(-10):bounceend(0.1):addx(5)
		end
	end,
	PlayerJoinedMessageCommand=function(self,param)
		if param.Player == player then
			self:zoom(1.15):bounceend(0.175):zoom(1)
		end
	end,


	-- dark frame prompting players to "Press START to join!"
	Def.ActorFrame {
		Name='JoinFrame',
		FrameBackground(Color.Black, player),

		LoadFont("_miso") .. {
			Text=THEME:GetString("ScreenSelectProfile", "PressStartToJoin"),
			InitCommand=cmd(diffuseshift;effectcolor1,Color('White');effectcolor2,color("0.5,0.5,0.5"); diffusealpha, 0),
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,
			OffCommand=function(self) self:linear(0.1):diffusealpha(0) end
		},
	},

	-- colored frame that contains the profile scroller and DataFrame
	Def.ActorFrame {
		Name='ScrollerFrame',
		FrameBackground(PlayerColor(player), player, 1.25),

		-- semi-transparent Quad used to indicate location in SelectProfile scroller
		Def.Quad {
			InitCommand=function(self) self:diffuse({0,0,0,0}):zoomto(124,row_height):x(-56) end,
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
		},

		-- scroller containing local profiles as choices
		Def.ActorScroller{
			Name='Scroller',
			NumItemsToDraw=7,
			InitCommand=cmd(x,-56; SetFastCatchup,true; SetSecondsPerItem,0.15; diffusealpha,0; SetMask, 400,60),
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,
			TransformFunction=function(self, offset, itemIndex, numItems)
				self:y(math.floor(offset*row_height))
			end,
			children = GetLocalProfiles()
		},

		-- player profile data
		Def.ActorFrame{
			Name="DataFrame",
			InitCommand=function(self) self:xy(62,1) end,

			-- semi-transparent Quad to the right of this colored frame to contain player mods
			Def.Quad {
				InitCommand=function(self) self:valign(0):diffuse({0,0,0,0}):zoomto(112,220):y(-111) end,
				OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
			},

			-- put all BitmapText actors in an ActorFrame so they can diffusealpha() simultaneously more easily
			Def.ActorFrame{
				InitCommand=function(self) self:diffusealpha(0) end,
				OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(1) end,

				-- the name the player most recently used for high score entry
				LoadFont("_miso")..{
					Name="HighScoreName",
					InitCommand=function(self) self:align(0,0):xy(-50,-104):zoom(0.65):maxwidth(104/0.65):vertspacing(-2) end,
					SetCommand=function(self, params)
						if params.PlayerNumber == player then
							if params.index and profile_data[params.index] then
								local desc = THEME:GetString("ScreenGameOver","LastUsedHighScoreName") .. ": "
								local name = profile_data[params.index].highscorename
								self:visible(true):settext(desc .. name)
							else
								self:visible(false):settext("")
							end
						end
					end
				},

				-- the song that was most recently played, presented as "group name/song name", eventually
				-- truncated so it passes the "How to Cook Delicious Rice and the Effects of Eating Rice" test.
				LoadFont("_miso")..{
					Name="MostRecentSong",
					InitCommand=function(self) self:align(0,0):xy(-50,-85):zoom(0.65):wrapwidthpixels(104/0.65):vertspacing(-5) end,
					SetCommand=function(self, params)
						if params.PlayerNumber == player then
							if params.index and profile_data[params.index] then
								local desc = THEME:GetString("ScreenSelectProfile","MostRecentSong") .. ":\n"
								self:settext(desc .. profile_data[params.index].recentsong):Truncate(85)
							else
								self:settext("")
							end
						end
					end
				},

				-- how many songs this player has completed in gameplay
				-- failing a song will increment this count, but backing out will not
				LoadFont("_miso")..{
					Name="TotalSongs",
					InitCommand=function(self) self:align(0,0):xy(-50,-30):zoom(0.65):maxwidth(104/0.65):vertspacing(-2) end,
					SetCommand=function(self, params)
						if params.PlayerNumber == player then
							if params.index and profile_data[params.index] then
								self:visible(true):settext(profile_data[params.index].totalsongs)
							else
								self:visible(false):settext("")
							end
						end
					end
				},

				-- "Most Frequent Grade" (static text)
				LoadFont("_miso")..{
					Name="MostCommonGradeDesc",
					InitCommand=function(self) self:align(0,0):xy(-50,-13):zoom(0.65):wrapwidthpixels(104/0.65) end,
					SetCommand=function(self, params)
						if params.PlayerNumber == player then
							if params.index and profile_data[params.index] then
								self:visible(true):settext( THEME:GetString("ScreenSelectProfile","MostFrequentGrade") )
							else
								self:visible(false):settext("")
							end
						end
					end
				},

				-- the letter grade sprite for the grade this player has most frequently earned
				LoadActor(THEME:GetPathG("MusicWheelItem","Grades/grades 1x18.png"))..{
					Name="MostCommonGradeGraphic",
					InitCommand=function(self) self:zoom(0.18):xy(-45,6):animate(0):visible(false) end,
					WhatMessageCommand=function(self) self:setstate(17) end,
					UndistortCommand=function(self) self:playcommand("Set", {PlayerNumber=player, index=SCREENMAN:GetTopScreen():GetProfileIndex(player)-1}) end,
					SetCommand=function(self, params)
						if params.PlayerNumber == player then
							if params.index and profile_data[params.index] and profile_data[params.index].grades.tier then
								self:setstate(profile_data[params.index].grades.tier-1):visible(true)
							else
								self:visible(false)
							end
						end
					end
				},

				-- the number of times this player earned their most frequent grade
				LoadFont("_miso")..{
					Name="MostCommonGradeNumber",
					InitCommand=function(self) self:align(0,0):xy(-30,0):zoom(0.75):wrapwidthpixels(104/0.65):vertspacing(-2) end,
					SetCommand=function(self, params)
						if params.PlayerNumber == player then
							if params.index and profile_data[params.index] and profile_data[params.index].grades.tier then
								self:visible(true):settext(profile_data[params.index].grades.count)
							else
								self:visible(false):settext("")
							end
						end
					end
				},

				-- (some of) the modifiers saved to this player's UserPrefs.ini file
				-- if the list is long, it will line break and eventually be masked
				-- to prevent it from visually spilling out of the FrameBackground
				LoadFont("_miso")..{
					Name="RecentMods",
					InitCommand=function(self) self:align(0,0):xy(-50,25):zoom(0.625):wrapwidthpixels(104/0.625):vertspacing(-5):ztest(true) end,
					SetCommand=function(self, params)
						if params.PlayerNumber == player then
							if params.index and profile_data[params.index] then
								self:visible(true):settext(profile_data[params.index].mods)
							else
								self:visible(false):settext("")
							end
						end
					end
				}
			},

			-- thin white line separating stats from mods
			Def.Quad {
				InitCommand=function(self) self:zoomto(100,1):y(17):diffusealpha(0) end,
				OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(0.5) end,
			},
		}
	},


	LoadActor(THEME:GetPathB("ScreenMemoryCard", "overlay/usbicon.png"))..{
		Name="USBIcon",
		InitCommand=function(self)
			self:rotationz(90):zoom(0.75):visible(false):diffuseshift()
				:effectperiod(1.5):effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.5)
		end
	},

	LoadFont("_miso")..{
		Name='SelectedProfileText',
		InitCommand=cmd(y,160; zoom, 1.35; shadowlength, ThemePrefs.Get("RainbowMode") and 0.5 or 0)
	}
}