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

-- shim to suppress errors resulting from SM3.95 "Gimmick" charts
function Actor:hidden(self, flag)
	-- if a value other than 0 or 1 was passed, don't do anything...
	if flag == 0 or flag == 1 then
		self:visible(math.abs(flag - 1))
	end
end


function GetNotefieldX( player )
	local pn = ToEnumShortString(player)

	local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player')
	local NumPlayersEnabled = GAMESTATE:GetNumPlayersEnabled()
	local NumSidesJoined = GAMESTATE:GetNumSidesJoined()
	local IsPlayingDanceSolo = GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo" and true or false

	if IsUsingSoloSingles and NumPlayersEnabled == 1 and NumSidesJoined == 1 then return _screen.cx end
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then return _screen.cx end

	local NumPlayersAndSides = ToEnumShortString( GAMESTATE:GetCurrentStyle():GetStyleType() )
	return THEME:GetMetric("ScreenGameplay","Player".. pn .. NumPlayersAndSides .."X")
end

function GetNotefieldWidth()

	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
		return _screen.w*1.058/GetScreenAspectRatio()
	elseif IsPlayingDanceSolo then
		return _screen.w*0.8/GetScreenAspectRatio()
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