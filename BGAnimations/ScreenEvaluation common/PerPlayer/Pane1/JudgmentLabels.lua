local player = ...
local pn = ToEnumShortString(player)
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

local mode = ""
if SL.Global.GameMode == "StomperZ" then mode = "StomperZ" end
if SL.Global.GameMode == "ECFA" then mode = "ECFA" end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function getStringFromTheme( arg )
	return THEME:GetString("TapNoteScore" .. mode, arg);
end

--Values above 0 means the user wants to be shown or told they are nice.
local nice = ThemePrefs.Get("nice") > 0

-- i'm learning haskell okay? map is nice
function map(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end

-- Iterating through the enum isn't worthwhile because the sequencing is so bizarre...
local TapNoteScores = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	-- dunno if it's possible to access another subtable from a subtable
	-- i want TapNoteScores.Types in place of the {'W1',...} table below
	-- but i couldn't figure it out so i just lazily pasted it back in.
	Names = map (getStringFromTheme, { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' } )
}

local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Hands'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
}

local EnglishRadarCategories = {
	[THEME:GetString("ScreenEvaluation", 'Holds')] = "Holds",
	[THEME:GetString("ScreenEvaluation", 'Mines')] = "Mines",
	[THEME:GetString("ScreenEvaluation", 'Hands')] = "Hands",
	[THEME:GetString("ScreenEvaluation", 'Rolls')] = "Rolls",
}

local scores_table = {}
for index, window in ipairs(TapNoteScores.Types) do
	local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
	scores_table[window] = number
end

local t = Def.ActorFrame{
	InitCommand=cmd(xy, 50, _screen.cy-24),
	OnCommand=function(self)
		if player == PLAYER_2 then
			self:x( self:GetX() * -1)
		end
	end
}


--  labels: W1 ---> Miss
for index, window in ipairs(TapNoteScores.Types) do

	local label = getStringFromTheme ( window )

	t[#t+1] = LoadFont("_miso")..{
		Text=(nice and scores_table[window] == 69) and 'NICE' or label:upper();
		InitCommand=cmd(zoom,0.833; horizalign,right; maxwidth, 76),
		BeginCommand=function(self)
			self:x( (player == PLAYER_1 and 28) or -28 )
			self:y((index-1)*28 -16)

			-- if StomperZ, diffuse the JudgmentLabel the StomperZ colors
			if SL.Global.GameMode == "StomperZ" then
				self:diffuse( SL.JudgmentColors.StomperZ[index] )

			elseif SL.Global.GameMode == "ECFA" then
				self:diffuse( SL.JudgmentColors.ECFA[index] )
			end


			local gmods = SL.Global.ActiveModifiers

			-- if Way Offs were turned off
			if gmods.DecentsWayOffs == "Decents Only" and label == THEME:GetString("TapNoteScore" .. mode, "W5") then
				self:visible(false)

			-- if both Decents and WayOffs were turned off
			elseif gmods.DecentsWayOffs == "Off" and (label == THEME:GetString("TapNoteScore" .. mode, "W4") or label == THEME:GetString("TapNoteScore" .. mode, "W5")) then
				self:visible(false)
			end
		end
	}
end

-- labels: holds, mines, hands, rolls
for index, label in ipairs(RadarCategories) do

	local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )
	local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )

	t[#t+1] = LoadFont("_miso")..{
		-- lua ternary operators are adorable
		Text=(nice and (performance == 69 or possible == 69)) and 'nice' or label,
		InitCommand=cmd(NoStroke;zoom,0.833; horizalign,right ),
		BeginCommand=function(self)
			self:x( (player == PLAYER_1 and -160) or 90 )
			self:y((index-1)*28 + 41)
		end
	}
end

return t
