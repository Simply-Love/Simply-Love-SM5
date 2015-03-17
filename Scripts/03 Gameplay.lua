-- various functions for doing things by gametype.
-- some of this previously appeared in 03 SystemDirection.

-- GetComboThresholds()
local ComboThresholdTable = {
	dance	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
	pump	=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
	techno	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
	kb7		=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
	-- these values are chosen to match Deluxe's PARASTAR:
	para	=	{ Maintain = "TapNoteScore_W5", Continue = "TapNoteScore_W3" },
	
	-- I don't know what these values are supposed to actually be...
	popn	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
	beat	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" }
}

function GetComboThreshold()
	local CurrentGame = string.lower( GAMESTATE:GetCurrentGame():GetName() );
	return ComboThresholdTable[CurrentGame];
end