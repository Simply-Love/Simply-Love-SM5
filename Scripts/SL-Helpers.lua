-- -----------------------------------------------------------------------
-- call this to draw a Quad with a border
-- arguments are: width of quad, height of quad, and border width, in pixels

Border = function(width, height, bw)
	width  = width  or 2
	height = height or 2
	bw     = bw     or 1

	return Def.ActorFrame {
		Def.Quad { InitCommand=function(self) self:zoomto(width-2*bw, height-2*bw):MaskSource(true) end },
		Def.Quad { InitCommand=function(self) self:zoomto(width,height):MaskDest() end },
		Def.Quad { InitCommand=function(self) self:diffusealpha(0):clearzbuffer(true) end },
	}
end

-- -----------------------------------------------------------------------
-- SL_WideScale() is modified version of WideScale() from SM5.1's _fallback theme
--
-- _fallback's WideScale() is useful for scaling a number to accommodate both 4:3 and 16:9 aspect ratios
-- first arg is what will be returned if AspectRatio is 4:3
-- second arg is what will be returned if AspectRatio is 16:9
-- The number returned will be scaled proprotionately between if AspectRatio is, for example, 16:10
-- and likewise scaled futher up if AspectRatio is, for example, 21:9.
--
-- SL's UI was originally designed for 4:3 and later extended for 16:9, so WideScale() works great there.
-- I'm opting to accommodate ultrawide displays by clamping the scale at 16:9.
--
-- You may not want to adopt this strategy in your theme, but for here
-- it's easier than redesigning the UI again.
--
-- It's important to not override _fallback's WideScale() for the sake of scripted simfiles
-- that expect it to behave a particular way.

SL_WideScale = function(AR4_3, AR16_9)
	return clamp(scale( SCREEN_WIDTH, 640, 854, AR4_3, AR16_9 ), AR4_3, AR16_9)
end


-- -----------------------------------------------------------------------
-- get timing window in milliseconds

GetTimingWindow = function(n, mode, tenms)
	local prefs = SL.Preferences[mode or SL.Global.GameMode]
	local scale = PREFSMAN:GetPreference("TimingWindowScale")
	if mode == "FA+" and tenms and n == 1 then
		return 0.0085 * scale + prefs.TimingWindowAdd
	end
	return prefs["TimingWindowSecondsW"..n] * scale + prefs.TimingWindowAdd
end

-- -----------------------------------------------------------------------
-- determines which timing_window an offset value (number) belongs to
-- used by the judgment scatter plot and offset histogram in ScreenEvaluation

DetermineTimingWindow = function(offset)
	for i=1,NumJudgmentsAvailable() do
		if math.abs(offset) <= GetTimingWindow(i) then
			return i
		end
	end
	return 5
end

-- -----------------------------------------------------------------------
-- return number of available judgments

NumJudgmentsAvailable = function()
	return 5
end

-- -----------------------------------------------------------------------
-- some common information needed by ScreenSystemOverlay's credit display,
-- as well as ScreenTitleJoin overlay and ./Scripts/SL-Branches.lua regarding coin credits

GetCredits = function()
	local coins = GAMESTATE:GetCoins()
	local coinsPerCredit = PREFSMAN:GetPreference('CoinsPerCredit')
	local credits = math.floor(coins/coinsPerCredit)
	local remainder = coins % coinsPerCredit

	return { Credits=credits,Remainder=remainder, CoinsPerCredit=coinsPerCredit }
end

-- -----------------------------------------------------------------------
-- return the x value for the center of a player's notefield
--   this is used to position various elements in ScreenGameplay
--   but it is not used to position the notefields themselves
--   (that's handled in Metrics.ini under [ScreenGameplay])

GetNotefieldX = function( player )
	if not player then return end

	local style = GAMESTATE:GetCurrentStyle()
	if not style then return end

	local p = ToEnumShortString(player)
	local game = GAMESTATE:GetCurrentGame():GetName()

	local IsPlayingDanceSolo = (style:GetStepsType() == "StepsType_Dance_Solo")
	local NumPlayersEnabled  = GAMESTATE:GetNumPlayersEnabled()
	local NumSidesJoined     = GAMESTATE:GetNumSidesJoined()
	local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player') or IsPlayingDanceSolo or (NumSidesJoined==1 and (game=="techno" or game=="kb7"))

	-- dance solo is always centered
	if IsUsingSoloSingles and NumPlayersEnabled == 1 and NumSidesJoined == 1 then return _screen.cx end
	-- double is always centered
	if style:GetStyleType() == "StyleType_OnePlayerTwoSides" then return _screen.cx end

	local NumPlayersAndSides = ToEnumShortString( style:GetStyleType() )
	return THEME:GetMetric("ScreenGameplay","Player".. p .. NumPlayersAndSides .."X")
end

-- -----------------------------------------------------------------------
-- this is verbose, but it lets us manage what seem to be
-- quirks/oversights in the engine on a per-game + per-style basis

local NoteFieldWidth = {
	-- dance uses such nice, clean multiples of 64.  It's almost like this game gets the most attention and fixes.
	dance = {
		single  = 256,
		versus  = 256,
		double  = 512,
		solo    = 384,
		routine = 512,
		-- couple and threepanel not supported in Simply Love at this time D:
		-- couple = 256,
		-- threepanel = 192
	},
	-- pump's values are very similar to those used in dance, but curiously smaller
	pump = {
		single  = 250,
		versus  = 250,
		double  = 500,
		routine = 500,
	},
	-- These values for techno, para, and kb7 are the result of empirical observation
	-- of the SM5 engine and should not be regarded as any kind of Truth.
	techno = {
		single8 = 448,
		versus8 = 272,
		double8 = 543,
	},
	para = {
		single = 280,
		versus = 280,
	},
	kb7 = {
		single = 480,
		versus = 270,
	},
}

GetNotefieldWidth = function()
	local game = GAMESTATE:GetCurrentGame()

	if game then
		local game_widths = NoteFieldWidth[game:GetName()]
		local style = GAMESTATE:GetCurrentStyle()
		if style then
			return game_widths[style:GetName()]
		end
	end

	return false
end

-- -----------------------------------------------------------------------
-- Define what is necessary to maintain and/or increment your combo, per Gametype.
-- For example, in dance Gametype, TapNoteScore_W3 (window #3) is commonly "Great"
-- so in dance, a "Great" will not only maintain a player's combo, it will also increment it.
--
-- We reference this function in Metrics.ini under the [Gameplay] section.
GetComboThreshold = function( MaintainOrContinue )

	local Combo = {}
	Combo.dance = { Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" }
	Combo.pump  = { Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" }
	Combo.techno= { Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" }
	Combo.kb7   = { Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" }

	-- values for para were inherited from freem's Moonlight theme which had an inline comment stating:
	-- "these are chosen to match Deluxe's PARASTAR"
	Combo.para = { Maintain = "TapNoteScore_W5", Continue = "TapNoteScore_W3" }

	-- I don't know what these values are supposed to be.
	Combo.popn    = { Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" }
	Combo.beat    = { Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" }
	Combo.kickbox = { Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" }

	-- lights is not a playable game mode, but it is, oddly, a selectable one within the operator menu
	-- include dummy values here to prevent Lua errors in case players accidentally switch to lights
	Combo.lights  = { Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" }


	-- handle FA+ for Dance
	-- should these values change for Pump?  I guess that's up to me.
	if SL.Global.GameMode=="FA+" then
		Combo.dance.Maintain = "TapNoteScore_W4"
		Combo.dance.Continue = "TapNoteScore_W4"
	end


	local game = GAMESTATE:GetCurrentGame():GetName() or "dance"
	return Combo[game][MaintainOrContinue]
end

-- -----------------------------------------------------------------------

-- FailType is a PlayerOption that can be set using SM5's PlayerOptions interface.
-- If you wanted, you could set FailTyper per-player, prior to Gameplay like
--
-- GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Preferred"):FailSetting("FailType_ImmediateContinue")
-- GAMESTATE:GetPlayerState(PLAYER_2):GetPlayerOptions("ModsLevel_Preferred"):FailSetting("FailType_Off")
--
-- and then P1 and P2 would have different Fail settings during gameplay.
--
-- That sounds kind of chaotic, particularly with saving Machine HighScores, so Simply Love
-- enforces the same FailType for both players and allows machine operators to set a
-- "default FailType" within Advanced Options in the Operator Menu.
--
-- This "default FailType" is sort of handled by the engine, but not in a way that is
-- necessarily clear to me.  Whatever the history there was, it is lost to me now.
--
-- The engine's FailType enum has the following four values:
-- 'FailType_Immediate', 'FailType_ImmediateContinue', 'FailType_EndOfSong', and 'FailType_Off'
--
-- The conf-based OptionRow for "DefaultFailType" presents these^ as the following hardcoded English strings:
-- 'Immediate', 'ImmediateContinue', 'EndOfSong', and 'Off'
--
-- and whichever the machine operator chooses gets saved as a different hardcoded English string in
-- the DefaultModifiers Preference for the current game:
-- '', 'FailImmediateContinue', 'FailAtEnd', or 'FailOff'

-- It is worth pointing out that a default FailType of "FailType_Immediate" is saved to the DefaultModifiers
-- Preference as an empty string!
--
-- so this:
-- DefaultModifiers=FailOff, Overhead, Cel
-- would result in the engine applying FailType_Off to players when they join the game
--
-- while this:
-- DefaultModifiers=Overhead, Cel
-- would result in the engine applying FailType_Immediate to players when they join the game
--
-- Anyway, this is all convoluted enough that I wrote this global helper function to find the default
-- FailType setting in the current game's DefaultModifiers Preference and return it as an enum value
-- the PlayerOptions interface can accept.
--
-- Keeping track of the logical flow of which preference overrides which metrics
-- and attempting to extrapolate how that will play out over time in a community
-- where players expect to be able to modify the code that drives gameplay is so
-- convoluted that it seems unreasonable to expect any player to follow along.
--
-- I can barely follow along.
--
-- I'm pretty sure ZP Theart was wailing about such project bitrot in Lost Souls in Endless Time.

GetDefaultFailType = function()
	local default_mods = PREFSMAN:GetPreference("DefaultModifiers")

	local default_fail = ""
	local fail_strings = {}

	-- -------------------------------------------------------------------
	-- these mappings just recreate the if/else chain in PlayerOptions.cpp
	fail_strings.failarcade            = "FailType_Immediate"
	fail_strings.failimmediate         = "FailType_Immediate"
	fail_strings.failendofsong         = "FailType_ImmediateContinue"
	fail_strings.failimmediatecontinue = "FailType_ImmediateContinue"
	fail_strings.failatend             = "FailType_EndOfSong"
	fail_strings.failoff               = "FailType_Off"

	-- handle the "faildefault" string differently than the SM5 engine
	-- PlayerOptions.cpp will lookup GAMESTATE's DefaultPlayerOptions
	-- which applies, in sequence:
	--    DefaultModifiers from Preferences.ini
	--    DefaultModifers from [Common] in metrics.ini
	--    DefaultNoteSkinName from [Common] in metrics.ini
	--
	-- SM5.1's _fallback theme does not currently specify any FailType
	-- in DefaultModifiers under [Common] in its metrics.ini
	--
	-- This suggests that if a non-standard failstring (like "FailASDF")
	-- is found, the _fallback theme won't enforce anything, but the engine
	-- will enforce FailType_Immediate.  Brief testing seems to align with this
	-- theory, but I haven't dug through enough of the src to *know*.
	--
	-- So, anyway, if Simply Love finds "faildefault" as a DefaultModifier in
	-- Simply Love UserPrefs.ini, I'll go with "FailType_ImmediateContinue.
	-- ImmediateContinue will be Simply Love's default.
	fail_strings.faildefault           = "FailType_ImmediateContinue"
	-- -------------------------------------------------------------------

	for mod in string.gmatch(default_mods, "%w+") do
		if mod:lower():find("fail") then
			-- we found something matches "fail", so set our default_fail variable
			-- and keep looking; don't break from the loop immediately.
			-- I don't know if it's possible to have multiple FailType
			-- strings saved in a single DefaultModifiers string...
			default_fail = mod:lower()
		end
	end

	-- return the appropriate Enum string or "FailType_Immediate" if nothing was parsed out of DefaultModifiers
	return fail_strings[default_fail] or "FailType_Immediate"
end

-- -----------------------------------------------------------------------

SetGameModePreferences = function()
	-- apply the preferences associated with this SL GameMode (Casual, ITG, FA+)
	for key,val in pairs(SL.Preferences[SL.Global.GameMode]) do
		PREFSMAN:SetPreference(key, val)
	end

	--------------------------------------------
	-- loop through human players and apply whatever mods need to be set now
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local pn = ToEnumShortString(player)
		-- If we're switching to Casual mode,
		-- we want to reduce the number of judgments,
		-- so turn Decents and WayOffs off now.
		if SL.Global.GameMode == "Casual" then
			SL[pn].ActiveModifiers.TimingWindows = {true,true,true,false,false}
		end

		-- Now that we've set the SL table for TimingWindows appropriately,
		-- use it to apply TimingWindows.
		local TW_OptRow = CustomOptionRow( "TimingWindows" )
		TW_OptRow:LoadSelections( TW_OptRow.Choices, player )


		local player_modslevel = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

		-- using PREFSMAN to set the preference for MinTNSToHideNotes apparently isn't
		-- enough when switching gamemodes because MinTNSToHideNotes is also a PlayerOption.
		-- so, set the PlayerOption version of it now, too, to ensure that arrows disappear
		-- at the appropriate judgments during gameplay for this gamemode.
		player_modslevel:MinTNSToHideNotes(SL.Preferences[SL.Global.GameMode].MinTNSToHideNotes)

		-- FailSetting is also a modifier that can be set per-player per-stage in SM5, but I'm
		-- opting to enforce it in Simply Love using what the machine operator sets
		-- as the default FailType in Advanced Options in the operator menu
		player_modslevel:FailSetting( GetDefaultFailType() )
	end

	--------------------------------------------
	-- finally, load the Stats.xml file appropriate for this SL GameMode

	-- these are the prefixes that are prepended to each custom Stats.xml, resulting in
	-- Stats.xml, ECFA-Stats.xml, Casual-Stats.xml
	local prefix = {}

	-- ITG has no prefix and scores go directly into the main Stats.xml
	-- this was probably a Bad Decision™ on my part in hindsight  -quietly
	prefix["ITG"] = ""

	-- "FA+" mode is prefixed with "ECFA-" because the mode was previously known as "ECFA Mode"
	-- and I don't want to deal with renaming relatively critical files from the theme.
	-- Thus, scores from FA+ mode will continue to go into ECFA-Stats.xml.
	prefix["FA+"] = "ECFA-"
	prefix["Casual"] = "Casual-"

	if PROFILEMAN:GetStatsPrefix() ~= prefix[SL.Global.GameMode] then
		PROFILEMAN:SetStatsPrefix(prefix[SL.Global.GameMode])
	end
end

-- -----------------------------------------------------------------------
-- Call ResetPreferencesToStockSM5() to reset all the Preferences that SL silently
-- manages for you back to their stock SM5 values.
--
-- These "managed" Preferences are listed in ./Scripts/SL_Init.lua
-- per-gamemode (Casual, ITG, FA+), and actively applied (and reapplied)
-- for each new game using SetGameModePreferences()
--
-- SL normally calls ResetPreferencesToStockSM5() from
-- ./BGAnimations/ScreenPromptToResetPreferencesToStock overlay.lua
-- but people have requested that the functionality for resetting Preferences be
-- generally accessible (for example, switching themes via a pad code).
-- Thus, this global function.

ResetPreferencesToStockSM5 = function()
	-- loop through all the Preferences that SL forcibly manages and reset them
	for key, value in pairs(SL.Preferences[SL.Global.GameMode]) do
		PREFSMAN:SetPreferenceToDefault(key)
	end
	-- now that those Preferences are reset to default values, write Preferences.ini to disk now
	PREFSMAN:SavePreferences()
end

-- -----------------------------------------------------------------------
-- given a player, return a table of stepartist text for the current song or trail
-- so that various screens (SSM, Eval) can cycle through these values and players
-- can see each for brief duration

GetStepsCredit = function(player)
	local t = {}

	if GAMESTATE:IsCourseMode() then
		local trail = GAMESTATE:GetCurrentTrail(player)
		local entries = trail:GetTrailEntries()
		local song

		for i, entry in ipairs(entries) do
			steps = entry:GetSteps()
			if steps then
				-- prefer steps Description; this is where stepartists seem to put chart info
				if steps:GetDescription() ~= "" then
					t[i] = steps:GetDescription()

				-- if no description was available, use AuthorCredit instead
				elseif steps:GetAuthorCredit() ~= "" then
					t[i] = steps:GetAuthorCredit()
				end
			end
		end
	else
		local steps = GAMESTATE:GetCurrentSteps(player)
		-- credit
		if steps:GetAuthorCredit() ~= "" then t[#t+1] = steps:GetAuthorCredit() end
		-- description
		if steps:GetDescription() ~= "" and steps:GetDescription() ~= steps:GetAuthorCredit() then t[#t+1] = steps:GetDescription() end
		-- chart name
		if steps:GetChartName() ~= "" and steps:GetChartName() ~= steps:GetAuthorCredit() and steps:GetChartName() ~= steps:GetDescription() then t[#t+1] = steps:GetChartName() end
	end

	return t
end

-- -----------------------------------------------------------------------
-- the best way to spread holiday cheer is singing loud for all to hear

HolidayCheer = function()
	return (PREFSMAN:GetPreference("EasterEggs") and MonthOfYear()==11)
end

DarkUI = function()
	-- During the process of switching games, THEME:GetCurThemeName() will temporarily return "_fallback"
	-- which will cause the ThemePrefs system to throw errors when a "RainbowMode" key isn't found
	-- because a [_fallback] section doesn't exist.  This should really be fixed in the _fallback theme,
	-- but we can prevent Lua errors from being thrown in the meantime.
	if THEME:GetCurThemeName() ~= PREFSMAN:GetPreference("Theme") then return false end

	if ThemePrefs.Get("RainbowMode") then return true end
	if HolidayCheer() then return true end
	return false
end

-- -----------------------------------------------------------------------
-- "The chills, I have them down my spine."
IsSpooky = function()
	return (PREFSMAN:GetPreference("EasterEggs") and MonthOfYear()==9 and ThemePrefs.Get("VisualStyle")=="Spooky")
end

-- -----------------------------------------------------------------------
-- functions that handle custom judgment graphic detection/loading

-- look for the "[frames wide] x [frames tall]" and some sort of all-letters file extension
-- return true if both are found in the filename
-- (note: Lua doesn't natively support an end-of-string regex marker.)
local FilenameIsMultiFrameSprite = function(filename)
	return string.match(filename, " %d+x%d+") and string.match(filename, "%.[A-Za-z]+")
end

-- remove "[frames wide] x [frames tall]"
-- remove "(doublres)"
-- remove ".png"
StripSpriteHints = function(filename)
	-- handle common cases here, gory details in /src/RageBitmapTexture.cpp
	return filename:gsub(" %d+x%d+", ""):gsub(" %(doubleres%)", ""):gsub(".png", "")
end

GetJudgmentGraphics = function()
	local path = THEME:GetPathG('', '_judgments')
	local files = FILEMAN:GetDirListing(path .. '/')
	local judgment_graphics = {}

	for i,filename in ipairs(files) do

		-- Filter out files that aren't judgment graphics
		-- e.g. hidden system files like .DS_Store
		if FilenameIsMultiFrameSprite(filename) then

			-- remove the file extension from the string, leaving only the name of the graphic
			local name = StripSpriteHints(filename)

			-- Fill the table, special-casing Love so that it comes first.
			if name == "Love" then
				table.insert(judgment_graphics, 1, filename)
			else
				judgment_graphics[#judgment_graphics+1] = filename
			end
		end
	end

	-- "None" results in Player judgment.lua returning an empty Def.Actor
	judgment_graphics[#judgment_graphics+1] = "None"

	return judgment_graphics
end

GetHoldJudgments = function()
	local path = THEME:GetCurrentThemeDirectory().."Graphics/_HoldJudgments/"
	local files = FILEMAN:GetDirListing(path)
	local hold_graphics = {}

	for i,filename in ipairs(files) do

		-- Filter out files that aren't HoldJudgment labels
		-- e.g. hidden system files like .DS_Store
		if FilenameIsMultiFrameSprite(filename) then
			table.insert(hold_graphics, filename)
		end
	end

	return hold_graphics
end


-- -----------------------------------------------------------------------
-- GetComboFonts returns a table of strings that match valid ComboFonts for use in Gameplay
--
-- a valid ComboFont must:
--   • have its assets in a unique directory at ./Fonts/_Combo Fonts/
--   • include the usual files needed for a StepMania BitmapText actor (a png and an ini)
--   • have its png and ini file both be named to match the directory they are in
--
-- a valid ComboFont should:
--   • include glyphs for 1234567890()/.-%
--   • be open source or "100% free" on dafont.com

GetComboFonts = function()
	local path = THEME:GetCurrentThemeDirectory().."Fonts/_Combo Fonts/"
	local dirs = FILEMAN:GetDirListing(path, true, false)
	local fonts = {}
	local has_wendy_cursed = false

	for directory_name in ivalues(dirs) do
		local files = FILEMAN:GetDirListing(path..directory_name.."/")
		local has_png, has_ini = false, false

		for filename in ivalues(files) do
			if FilenameIsMultiFrameSprite(filename) and StripSpriteHints(filename)==directory_name then has_png = true end
			if filename:match(".ini") and filename:gsub(".ini","")==directory_name then has_ini = true end
		end

		if has_png and has_ini then
			-- special-case Wendy to always appear first in the list
			if directory_name == "Wendy" then
				table.insert(fonts, 1, directory_name)

			-- special-case Wendy (Cursed) to always appear last in the last
			elseif directory_name == "Wendy (Cursed)" then
				has_wendy_cursed = true
			else
				table.insert(fonts, directory_name)
			end
		end
	end

	if has_wendy_cursed then table.insert(fonts, "Wendy (Cursed)") end

	return fonts
end


-- -----------------------------------------------------------------------
IsHumanPlayer = function(player)
	return GAMESTATE:GetPlayerState(player):GetPlayerController() == "PlayerController_Human"
end

-- -----------------------------------------------------------------------
IsAutoplay = function(player)
	return GAMESTATE:GetPlayerState(player):GetPlayerController() == "PlayerController_Autoplay"
end

-- -----------------------------------------------------------------------
-- Helper function to determine if a TNS falls within the W0 window.
-- Params are the params received from the JudgmentMessageCommand.
-- Returns true/false
IsW0Judgment = function(params, player)
	if params.Player ~= player then return false end
	if params.HoldNoteScore then return false end
	
	-- Only check/update FA+ count if we received a TNS in the top window.
	if params.TapNoteScore == "TapNoteScore_W1" and SL.Global.GameMode == "ITG"  then
		local prefs = SL.Preferences["FA+"]
		local scale = PREFSMAN:GetPreference("TimingWindowScale")
		local pn = ToEnumShortString(player)
		local W0 = prefs["TimingWindowSecondsW1"] * scale + prefs["TimingWindowAdd"]
		if SL[pn].ActiveModifiers.SmallerWhite then
			W0 = 0.0085 * scale + prefs["TimingWindowAdd"]
		end

		local offset = math.abs(params.TapNoteOffset)
		if offset <= W0 then
			return true
		end
	elseif params.TapNoteScore == "TapNoteScore_W1" and SL.Global.GameMode == "FA+" then
		local prefs = SL.Preferences["FA+"]
		local scale = PREFSMAN:GetPreference("TimingWindowScale")
		local pn = ToEnumShortString(player)
		local W0 = prefs["TimingWindowSecondsW1"] * scale + prefs["TimingWindowAdd"]
		if SL[pn].ActiveModifiers.SmallerWhite then
			W0 = 0.0085 * scale + prefs["TimingWindowAdd"]
		end
		
		local offset = math.abs(params.TapNoteOffset)
		if offset <= W0 then
			return true
		end
	end
	return false
end

IsW015Judgment = function(params, player)
	if params.Player ~= player then return false end
	if params.HoldNoteScore then return false end
	
	-- Only check/update FA+ count if we received a TNS in the top window.
	if params.TapNoteScore == "TapNoteScore_W1" and SL.Global.GameMode == "ITG"  then
		local prefs = SL.Preferences["FA+"]
		local scale = PREFSMAN:GetPreference("TimingWindowScale")
		local pn = ToEnumShortString(player)
		local W0 = prefs["TimingWindowSecondsW1"] * scale + prefs["TimingWindowAdd"]

		local offset = math.abs(params.TapNoteOffset)
		if offset <= W0 then
			return true
		end
	end
	return false
end

-- -----------------------------------------------------------------------
-- Gets the fully populated judgment counts for a player.
-- This includes the FA+ window (W0). Decents/WayOffs (W4/W5) will only exist in the
-- resultant table if the windows were active.
--
-- Should NOT be used in casual mode.
--
-- Returns a table with the following keys:
-- {
--             "W0" -> the fantasticPlus count
--             "W1" -> the fantastic count
--             "W2" -> the excellent count
--             "W3" -> the great count
--             "W4" -> the decent count (may not exist if window is disabled)
--             "W5" -> the way off count (may not exist if window is disabled)
--           "Miss" -> the miss count
--     "totalSteps" -> the total number of steps in the chart (including hold heads)
--          "Holds" -> total number of holds held
--     "totalHolds" -> total number of holds in the chart
--          "Mines" -> total number of mines hit
--     "totalMines" -> total number of mines in the chart
--          "Rolls" -> total number of rolls held
--     "totalRolls" -> total number of rolls in the chart
-- }
--
-- Note: The returned table can't be used directly into CalculateExScore because the keys
-- "HitMine", "Held", and "LetGo" aren't calculated here.
GetExJudgmentCounts = function(player)
	local pn = ToEnumShortString(player)
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)

	local counts = {}

	local TNS = { "W1", "W2", "W3", "W4", "W5", "Miss" }
	
	if SL.Global.GameMode == "FA+" then
		for window in ivalues(TNS) do
			adjusted_window = window
			-- In FA+ mode, we need to shift the windows up 1 so that the key we're using is accurate.
			-- E.g. W1 window becomes W0, W2 becomes W1, etc.
			if window ~= "Miss" then
				adjusted_window = "W"..(tonumber(window:sub(-1))-1)
			end
			
			-- Get the count.
			local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
			-- 10ms check
			if window == "W1" then
				local faPlus = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts.W0
				local faPlus15 = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts.W015
				local fa = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts.W1
				-- Subtract white count from blue count
				local fa15 = fa - faPlus15 + faPlus
				
				-- Populate the two numbers.
				counts["W0"] = faPlus
				counts["W015"] = faPlus15
				counts["W1"] = fa
				counts["W115"] = fa15
			elseif window == "W2" then
				local x=0
			-- For the last window (Decent) in FA+ mode...
			elseif window == "W5" then
				-- Only populate if the window is still active.
				if SL[pn].ActiveModifiers.TimingWindows[5] then
					counts[adjusted_window] = number
				end
			else
				counts[adjusted_window] = number
			end
		end
	elseif SL.Global.GameMode == "ITG" then
		for window in ivalues(TNS) do
			-- Get the count.
			local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
			-- We need to extract the W0 count in ITG mode.
			if window == "W1" then
				local faPlus = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts.W0_total
				local faPlus15 = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts.W015_total
				-- Subtract white count from blue count
				local number15 = number - faPlus15
				number = number - faPlus
				
				-- Populate the two numbers.
				counts["W0"] = faPlus
				counts["W015"] = faPlus15
				counts["W1"] = number
				counts["W115"] = number15
				
			else
				if ((window ~= "W4" and window ~= "W5") or
						-- Only populate decent and way off windows if they're active.
						(window == "W4" and SL[pn].ActiveModifiers.TimingWindows[4]) or
						(window == "W5" and SL[pn].ActiveModifiers.TimingWindows[5])) then
					counts[window] = number
				end
			end
		end
	end
	counts["totalSteps"] = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_TapsAndHolds" )
	
	local RadarCategory = { "Holds", "Mines", "Rolls" }

	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

	for RCType in ivalues(RadarCategory) do
		local number = stats:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		local possible = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_"..RCType )

		if RCType == "Mines" then
			-- NoMines still report the total number of mines that exist in a chart, even if they weren't played in the chart.
			-- If NoMines was set, report 0 for the number of mines as the chart actually didn't have any.
			-- TODO(teejusb): Track AvoidMine in the future. This is fine for now as ITL compares serverside.
			if po:NoMines() then
				counts[RCType] = 0
				counts["total"..RCType] = 0
			else
				-- We want to keep track of mines hit.
				counts[RCType] = possible - number
				counts["total"..RCType] = possible
			end
		else
			counts[RCType] = number
			counts["total"..RCType] = possible
		end
	end

	return counts
end

-- -----------------------------------------------------------------------
-- Calculate the EX score given for a given player.
--
-- The ex_counts default to those computed in BGAnimations/ScreenGameplay underlay/TrackExScoreJudgments.lua
-- They are computed from the HoldNoteScore and TapNotScore from the JudgmentMessageCommands.
-- We look for the following keys: 
-- {
--             "W0" -> the fantasticPlus count
--             "W1" -> the fantastic count
--             "W2" -> the excellent count
--             "W3" -> the great count
--             "W4" -> the decent count
--             "W5" -> the way off count
--           "Miss" -> the miss count
--           "Held" -> the number of holds/rolds held
--          "LetGo" -> the number of holds/rolds dropped
--        "HitMine" -> total number of mines hit
-- }
CalculateExScore = function(player, ex_counts)
	-- No EX scores in Casual mode, just return some dummy number early.
	if SL.Global.GameMode == "Casual" then return 0 end
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)

	local totalSteps = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_TapsAndHolds" )
	local totalHolds = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Holds" )
	local totalRolls = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Rolls" )

	local total_possible = totalSteps * SL.ExWeights["W0"] + (totalHolds + totalRolls) * SL.ExWeights["Held"]

	local total_points = 0

	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

	-- If mines are disabled, they should still be accounted for in EX Scoring based on the weight assigned to it.
	-- Stamina community does often play with no-mines on, but because EX scoring is more timing centric where mines
	-- generally have a negative weight, it's a better experience to make sure the EX score reflects that.
	if po:NoMines() then
		local totalMines = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Mines" )
		total_points = total_points + totalMines * SL.ExWeights["HitMine"];
	end

	-- Use W015 instead of W0, to always calculate EX score based on 15ms blue fantastic window
	local FAplus = (SL.Metrics[SL.Global.GameMode].PercentScoreWeightW1 == SL.Metrics[SL.Global.GameMode].PercentScoreWeightW2)
	local keys = FAplus and { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" } or { "W015", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" }
	local counts = ex_counts or SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts
	-- Just for validation, but shouldn't happen in normal gameplay.
	if counts == nil then return 0 end

	for key in ivalues(keys) do
		local value = counts[key]
		if value ~= nil then
			if key == "W015" then
				total_points = total_points + value * SL.ExWeights["W0"]
			else
				total_points = total_points + value * SL.ExWeights[key]
			end
		end
	end

	return math.max(0, math.floor(total_points/total_possible * 10000) / 100)
end

-- -----------------------------------------------------------------------
-- Generates the column mapping in case of any turn mods.
-- Returns a table containing the column swaps.
-- Returns nil if we can't compute it
GetColumnMapping = function(player)
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Preferred')

	local shuffle = po:Shuffle() or po:SoftShuffle() or po:SuperShuffle() 
	local notes_inserted = (po:Wide() or po:Skippy() or po:Quick() or po:Echo() or
													po:BMRize() or po:Stomp() or po:Big())
	local notes_removed = (po:Little()  or po:NoHolds() or po:NoStretch() or
													po:NoHands() or po:NoJumps() or po:NoFakes() or 
													po:NoLifts() or po:NoQuads() or po:NoRolls())
	
	-- If shuffle is used or notes were inserted/removed, we can't compute it
	-- return early
	-- TODO(teejusb): Add support for Backwards()
	if shuffle or notes_inserted or notes_removed or po:Backwards() then
		return nil
	end

	local flip = po:Flip() > 0
	local invert = po:Invert() > 0
	local left = po:Left()
	local right = po:Right()
	local mirror = po:Mirror()

	-- Combining flip and invert results in unusual spacing so ignore it.
	if flip and invert then
		return nil
	end

	local has_turn = flip or invert or left or right or mirror
	local style = GAMESTATE:GetCurrentStyle()
	local num_columns = style:ColumnsPerPlayer()

	-- We only resolve turn mods in 4 and 8 panel.
	if num_columns ~= 4 and num_columns ~= 8 then
		if not has_turn then
			-- Not turn mod used, return 1-to-1 mapping.
			return range(num_columns)
		else
			-- If we are using turn mods in modes without 4 or 8 columns then return
			-- early since we don't try to resolve them.
			return nil
		end
	end

	local column_mapping = {1, 2, 3, 4}

	if flip then
		column_mapping = {column_mapping[4], column_mapping[3], column_mapping[2], column_mapping[1]}
	end

	if invert then
		column_mapping = {column_mapping[2], column_mapping[1], column_mapping[4], column_mapping[3]}
	end

	if left then
		column_mapping = {column_mapping[2], column_mapping[4], column_mapping[1], column_mapping[3]}
	end

	if right then
		column_mapping = {column_mapping[3], column_mapping[1], column_mapping[4], column_mapping[2]}
	end

	if mirror then
		column_mapping = {column_mapping[4], column_mapping[3], column_mapping[2], column_mapping[1]}
	end

	if num_columns == 8 then
		for i=1,4 do
			column_mapping[4+i] = column_mapping[i] + 4
		end

		-- We only need to apply the following if exactly one of flip or mirror is active
		-- since they otherwise cancel each other out
		if (not flip and mirror) or (flip and not mirror) then
			for i=1,4 do
				column_mapping[i] = column_mapping[i] + 4
				column_mapping[i+4] = column_mapping[i+4] - 4
			end
		end
	end

	return column_mapping
end