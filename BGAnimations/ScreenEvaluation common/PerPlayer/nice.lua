-- draws a "nice" underneath if a 69 appears somewhere on ScreenEvaluation
-- with love, ian klatzco and din

local player = ...
local af = Def.ActorFrame{}

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local failed = stats:GetFailed()
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentDP):gsub("%%", "")

-- for iterating
local TapNoteScores = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }
local RadarCategories = { 'Holds', 'Mines', 'Hands', 'Rolls' }

-- if the table contains a 69 in a substring, "nice"
-- a little bit of code re-use from LetterGrade.lua
local IsNice = function()

	if ThemePrefs.Get("nice") <= 0 then return false end

	if string.match(percent, "69") ~= nil then return true end

	-- check timing ratings (W1..W5, miss)
	local scores_table = {}
	for index, window in ipairs(TapNoteScores) do
		local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
		scores_table[window] = number
	end

	for label,item in pairs(scores_table) do
		if string.match(tostring(item), "69") ~= nil then return true end
	end

	-- check holds mines hands rolls, and their "total possible"
	for index, RCType in ipairs(RadarCategories) do
		local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..RCType )

		if string.match(tostring(performance), "69") ~= nil then return true end
		if string.match(tostring(possible), "69") ~= nil then return true end
	end

	-- check difficulty
	local meter
	if GAMESTATE:IsCourseMode() then -- course mode
		local trail = GAMESTATE:GetCurrentTrail(player)
		if trail then
			meter = trail:GetMeter()
			if string.match(tostring(meter), "69") ~= nil then return true end
		end
	else
		local steps = GAMESTATE:GetCurrentSteps(player) -- regular mode
		if steps then
			meter = steps:GetMeter()
			if string.match(tostring(meter), "69") ~= nil then return true end
		end
	end

	-- song title
	local songtitle = (GAMESTATE:IsCourseMode()
						and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle())
						or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()

	if songtitle then
		if string.match(tostring(songtitle), "69") ~= nil then return true end
	end

	return false
end

local IsCranked = function()
	if not PREFSMAN:GetPreference("EasterEggs") then return false end
	if failed then return false end
	if not (tonumber(percent) <= 77.41) then return false end
	if tonumber(percent) <= 0 then return false end

	local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
	local title = SongOrCourse:GetDisplayFullTitle():lower()
	local genre = not GAMESTATE:IsCourseMode() and SongOrCourse:GetGenre():lower() or ""
	local group = not GAMESTATE:IsCourseMode() and SongOrCourse:GetGroupName():lower() or ""

	if title:match("wrench") or genre:match("dark psytrance") or group:match("cranked pastry") or group:match("scrapyard kent") then return true end

	return false
end


if IsNice() then
	af[#af+1] = LoadActor(THEME:GetPathG("","nice.png"))..{
		InitCommand=function(self)
			self:xy(70, _screen.cy-134)
		end,
		OnCommand=function(self)

			self:y(_screen.cy-94)
			self:zoom(0.4)

			if player == PLAYER_1 then
				self:x( self:GetX() * -1 )
			end

			-- if the value is 2, then this indicates they want sound.
			if ThemePrefs.Get("nice") == 2 then
				-- SOUND:PlayOnce() doesn't take the global SoundVolume Preference into consideration
				-- it just plays the file you pass it at 100%; this can be jarring
				-- use SOUND:DimMusic() as a way to set the volume to match SoundVolume preference
				-- for 1.3 seconds, the duration of nice.ogg
				SOUND:DimMusic(PREFSMAN:GetPreference("SoundVolume"),  1.3)
				SOUND:PlayOnce(THEME:GetPathS("", "nice.ogg"))
			end
		end
	}
end

if IsCranked() then
	af[#af+1] = LoadActor(THEME:GetPathS("", "wrenches.ogg"))..{
		OnCommand=function(self) self:sleep(0.5):queuecommand("Play") end,
		PlayCommand=function(self) self:play() end
	}
end


return af