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

	local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player')
	local NumPlayersEnabled = GAMESTATE:GetNumPlayersEnabled()
	local NumSidesJoined = GAMESTATE:GetNumSidesJoined()
	local IsPlayingDanceSolo = GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo" and true or false

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

-- Setting values here in ComboThresholdsTable doesn't inherently do anything.
-- This is just a convenient place to define all of them.
-- We reference this table in Metrics.ini under the [Gameplay] section.
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

function GetComboThreshold()
	local CurrentGame = string.lower( GAMESTATE:GetCurrentGame():GetName() )
	return ComboThresholdTable[CurrentGame]
end


function SetGameModePreferences()
	for key,val in pairs(SL.Preferences[SL.Global.GameMode]) do
		PREFSMAN:SetPreference(key, val)
	end

	local prefix = {
		Competitive = "",
		Marathon = "",
		StomperZ = "StomperZ-",
		Casual = "Casual-"
	}

	if PROFILEMAN:GetStatsPrefix() ~= prefix[SL.Global.GameMode] then
		PROFILEMAN:SetStatsPrefix(prefix[SL.Global.GameMode])
	end
end


function GetPlayerOptionsLineNames()
	if SL.Global.GameMode == "Casual" then
		return "SpeedMod,BackgroundFilter,MusicRate,Difficulty,ScreenAfterPlayerOptions"
	else
		return "SpeedModType,SpeedMod,Mini,Perspective,NoteSkin2,Judgment,BackgroundFilter,MusicRate,Difficulty,ScreenAfterPlayerOptions"
	end
end

function GetPlayerOptions2LineNames()
	local mods = "Turn,Scroll,7,8,9,10,11,12,13,Attacks,Hide,TargetStatus,TargetBar,GameplayExtras,MeasureCounter,DecentsWayOffs,Vocalization,ScreenAfterPlayerOptions2"

	if SL.Global.GameMode == "StomperZ" then
		mods = mods:gsub("DecentsWayOffs,", "")
	end

	if SL.Global.Gamestate.Style == "double" then
		mods = mods:gsub("TargetStatus,TargetBar,", "")
	end

	return mods
end