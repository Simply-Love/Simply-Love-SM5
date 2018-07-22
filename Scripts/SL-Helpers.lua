------------------------------------------------------------------------------
-- call this to draw a Quad with a border
-- width of quad, height of quad, and border width, in pixels

function Border(width, height, bw)
	return Def.ActorFrame {
		Def.Quad {
			InitCommand=cmd(zoomto, width-2*bw, height-2*bw;  MaskSource,true)
		},
		Def.Quad {
			InitCommand=cmd(zoomto,width,height; MaskDest)
		},
		Def.Quad {
			InitCommand=cmd(diffusealpha,0; clearzbuffer,true)
		},
	}
end


------------------------------------------------------------------------------
-- Misc Lua functions that didn't fit anywhere else...

-- helper function used to detmerine which timing_window a given offset belongs to
function DetermineTimingWindow(offset)
	for i=1,5 do
		if math.abs(offset) < SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..i] + SL.Preferences[SL.Global.GameMode]["TimingWindowAdd"] then
			return i
		end
	end
	return 5
end


function GetCredits()
	local coins = GAMESTATE:GetCoins()
	local coinsPerCredit = PREFSMAN:GetPreference('CoinsPerCredit')
	local credits = math.floor(coins/coinsPerCredit)
	local remainder = coins % coinsPerCredit

	local r = {
		Credits=credits,
		Remainder=remainder,
		CoinsPerCredit=coinsPerCredit
	}
	return r
end

-- Used in Metrics.ini for ScreenRankingSingle and ScreenRankingDouble
function GetStepsTypeForThisGame(type)
	local game = GAMESTATE:GetCurrentGame():GetName()
	-- capitalize the first letter
	game = game:gsub("^%l", string.upper)

	return "StepsType_" .. game .. "_" .. type
end


function GetNotefieldX( player )
	local p = ToEnumShortString(player)

	local IsPlayingDanceSolo = (GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo")
	local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player') or IsPlayingDanceSolo
	local NumPlayersEnabled = GAMESTATE:GetNumPlayersEnabled()
	local NumSidesJoined = GAMESTATE:GetNumSidesJoined()

	if IsUsingSoloSingles and NumPlayersEnabled == 1 and NumSidesJoined == 1 then return _screen.cx end
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then return _screen.cx end

	local NumPlayersAndSides = ToEnumShortString( GAMESTATE:GetCurrentStyle():GetStyleType() )
	return THEME:GetMetric("ScreenGameplay","Player".. p .. NumPlayersAndSides .."X")
end

function GetNotefieldWidth()

	-- double
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
		return _screen.w*1.058/GetScreenAspectRatio()

	-- dance solo
	elseif GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo" then
		return _screen.w*0.8/GetScreenAspectRatio()

	-- single
	else
		return _screen.w*0.529/GetScreenAspectRatio()
	end
end

------------------------------------------------------------------------------
-- Define what is necessary to maintain and/or increment your combo, per Gametype.
-- For example, in dance Gametype, TapNoteScore_W3 (window #3) is commonly "Great"
-- so in dance, a "Great" will not only maintain a player's combo, it will also increment it.
--
-- We reference this function in Metrics.ini under the [Gameplay] section.
function GetComboThreshold( MaintainOrContinue )
	local CurrentGame = string.lower( GAMESTATE:GetCurrentGame():GetName() )

	local ComboThresholdTable = {
		dance	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		pump	=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
		techno	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		kb7		=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
		-- these values are chosen to match Deluxe's PARASTAR
		para	=	{ Maintain = "TapNoteScore_W5", Continue = "TapNoteScore_W3" },

		-- I don't know what these values are supposed to actually be...
		popn	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		beat	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" }
	}


	if CurrentGame == "dance" then
		if SL.Global.GameMode == "StomperZ" or SL.Global.GameMode=="ECFA" then
			ComboThresholdTable.dance.Maintain = "TapNoteScore_W4"
			ComboThresholdTable.dance.Continue = "TapNoteScore_W4"
		end
	end

	return ComboThresholdTable[CurrentGame][MaintainOrContinue]
end


function SetGameModePreferences()
	for key,val in pairs(SL.Preferences[SL.Global.GameMode]) do
		PREFSMAN:SetPreference(key, val)
	end

	-- If we're switching to Casual mode,
	-- we want to reduce the number of judgments,
	-- so turn Decents and WayOffs off now.
	if SL.Global.GameMode == "Casual" then
		SL.Global.ActiveModifiers.DecentsWayOffs = "Off"

	-- Otherwise, we want Decents and WayOffs enabled by default.
	else
 		SL.Global.ActiveModifiers.DecentsWayOffs = "On"
	end

	-- Now that we've set the SL table for DecentsWayOffs appropriately,
	-- use it to apply DecentsWayOffs as a mod.
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local OptRow = CustomOptionRow( "DecentsWayOffs" )
		OptRow:LoadSelections( OptRow.Choices, player )
	end

	local prefix = {
		Competitive = "",
		ECFA = "ECFA-",
		StomperZ = "StomperZ-",
		Casual = "Casual-"
	}

	if PROFILEMAN:GetStatsPrefix() ~= prefix[SL.Global.GameMode] then
		PROFILEMAN:SetStatsPrefix(prefix[SL.Global.GameMode])
	end
end

function GetOperatorMenuLineNames()
	local lines = "System,KeyConfig,TestInput,Visual,GraphicsSound,Arcade,Input,Theme,MenuTimer,CustomSongs,Advanced,Profiles,Acknowledgments,Reload"

	-- CustomSongs preferences don't exist in 5.0.x, which many players may still be using
	-- thus, if the preference for CustomSongsEnable isn't found in this version of SM, don't let players
	-- get into the CustomSongs submenu in the OperatorMenu by removing that OptionRow
	if not PREFSMAN:PreferenceExists("CustomSongsEnable") then
		lines = lines:gsub("CustomSongs,", "")
	end
	return lines
end


function GetSimplyLoveOptionsLineNames()
	local lines = "CasualMaxMeter,AutoStyle,DefaultGameMode,TimingWindowAdd,CustomFailSet,CreditStacking,MusicWheelStyle,MusicWheelSpeed,SelectProfile,SelectColor,EvalSummary,NameEntry,GameOver,HideStockNoteSksins,DanceSolo,GradesInMusicWheel,Nice,VisualTheme,RainbowMode"
	if Sprite.LoadFromCached ~= nil then
		lines = lines .. ",UseImageCache"
	end
	return lines
end


function GetPlayerOptionsLineNames()
	if SL.Global.GameMode == "Casual" then
		return "SpeedMod,BackgroundFilter,MusicRate,Difficulty,ScreenAfterPlayerOptions"
	else
		return "SpeedModType,SpeedMod,Mini,Perspective,NoteSkin2,Judgment,BackgroundFilter,MusicRate,Difficulty,ScreenAfterPlayerOptions"
	end
end

function GetPlayerOptions2LineNames()
	local mods = "Turn,Scroll,7,8,9,10,11,12,13,Attacks,Hide,ReceptorArrowsPosition,LifeMeterType,TargetStatus,TargetBar,ActionOnMissedTarget,GameplayExtras,MeasureCounterPosition,MeasureCounter,DecentsWayOffs,Vocalization,ScreenAfterPlayerOptions2"

	-- remove ReceptorArrowsPosition if GameMode isn't StomperZ
	if SL.Global.GameMode ~= "StomperZ" then
		mods = mods:gsub("ReceptorArrowsPosition", "")
	end

	-- remove DecentsWayOffs and LifeMeterType if GameMode is StomperZ
	if SL.Global.GameMode == "StomperZ" then
		mods = mods:gsub("DecentsWayOffs,", ""):gsub("LifeMeterType", "")
	end

	-- remove TargetStatus and TargetBar (IIDX pacemaker) if style is double
	if SL.Global.Gamestate.Style == "double" then
		mods = mods:gsub("TargetStatus,TargetBar,ActionOnMissedTarget,", "")
	end
	
	-- only show if the user is in event mode
	-- no need to have this show up in arcades.
	-- the pref is also checked against EventMode during runtime.
	if not PREFSMAN:GetPreference("EventMode") then
		mods = mods:gsub("ActionOnMissedTarget,", "")
	end

	return mods
end

BrighterOptionRows = function()
	if ThemePrefs.Get("RainbowMode") then return true end
	if PREFSMAN:GetPreference("EasterEggs") and MonthOfYear()==11 then return true end -- holiday cheer
	return false
end
