-- draws a "nice" underneath if a 69 appears somewhere on ScreenEvaluation
-- with love, ian klatzco and din
local pn = ...
local t = nil

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

-- for iterating
local TapNoteScores = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	-- x values for P1 and P2
	x = { 64, 94 }
}

local RadarCategories = {
	Types = { 'Holds', 'Mines', 'Hands', 'Rolls' },
	-- x values for P1 and P2
	x = { -180, 218 }
}

-- if the table contains a 69 in a substring, "nice"
-- a little bit of code re-use from LetterGrade.lua
local function IsNice()

	local isNice = false

	-- check percent
	local PercentDP = stats:GetPercentDancePoints()
	local percent = FormatPercentScore(PercentDP)
	percent = percent:gsub("%%", "")

	if string.match(percent, "69") ~= nil then
		isNice = true
	end

	-- check timing ratings (W1..W5, miss)
	local scores_table = {}
	for index, window in ipairs(TapNoteScores.Types) do
		local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
		scores_table[window] = number
	end

	for label,item in pairs(scores_table) do
		if string.match(tostring(item), "69") ~= nil then
			isNice = true
		end
	end

	-- check holds mines hands rolls, and their "total possible"
	for index, RCType in ipairs(RadarCategories.Types) do
		local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..RCType )

		if string.match(tostring(performance), "69") ~= nil then
			isNice = true
		end
		if string.match(tostring(possible), "69") ~= nil then
			isNice = true
		end
	end

	-- check difficulty
	local meter
	if GAMESTATE:IsCourseMode() then -- course mode
		local trail = GAMESTATE:GetCurrentTrail(pn)
		if trail then
			meter = trail:GetMeter()
			if string.match(tostring(meter), "69") ~= nil then
				isNice = true
			end
		end
	else
		local steps = GAMESTATE:GetCurrentSteps(pn) -- regular mod
		if steps then
			meter = steps:GetMeter()
			if string.match(tostring(meter), "69") ~= nil then
				isNice = true
			end
		end
	end

	-- song title
	local songtitle = (GAMESTATE:IsCourseMode() 
						and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()) 
						or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()

	if songtitle then
		if string.match(tostring(songtitle), "69") ~= nil then
			isNice = true
		end
	end

	-- potential extensions that i don't wanna do
	-- artist?
	-- max combo from combo graph?
	
	return isNice
	
end



--Don't even bother putting another ActorFrame on the screen
--if it isn't nice. No need to increase system usage.
if IsNice() then
	t = Def.ActorFrame{
		LoadActor(THEME:GetPathG("","_grades/graphics/nice.png"))..{
			InitCommand=function(self)
				self:xy(70, _screen.cy-134)
			end,
			OnCommand=function(self)
				
				self:y(_screen.cy-94)
				self:zoom(0.4)
				
				if pn == PLAYER_1 then
					self:x( self:GetX() * -1 )
				end
				
				--If the value is 2, then this indicates they want sound.
				if ThemePrefs.Get("nice") == 2 then
					--For some reason Stepmania could play 
					--this sound lounder than the
					--system preference, so let's ensure 
					--we are turned down for the meme.
					SOUND:DimMusic(PREFSMAN:GetPreference("SoundVolume"),  1.3)
					SOUND:PlayOnce(THEME:GetPathS("", "nice.ogg"))
				end

			end,
		};
	}
end


return t 
