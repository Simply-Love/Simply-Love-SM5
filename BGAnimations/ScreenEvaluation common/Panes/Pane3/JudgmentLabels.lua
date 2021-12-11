local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local TapNoteScores = {Types={}, Names={}}
local Colors = {}
if mods.ShowFaPlusWindow and mods.ShowFaPlusPane then
	TapNoteScores.Types = {'W0', 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss'}
	Colors = {
		SL.JudgmentColors["FA+"][1],
		SL.JudgmentColors["FA+"][2],
		SL.JudgmentColors["FA+"][3],
		SL.JudgmentColors["FA+"][4],
		SL.JudgmentColors["FA+"][5],
		SL.JudgmentColors["ITG"][5], -- FA+ mode doesn't have a Way Off window. Extract color from the ITG mode.
		SL.JudgmentColors["FA+"][6],
	}
	-- get all TNS names
	TapNoteScores.Names = {
		THEME:GetString("TapNoteScoreFA+", "W1"),
		THEME:GetString("TapNoteScoreFA+", "W2"),
		THEME:GetString("TapNoteScoreFA+", "W3"),
		THEME:GetString("TapNoteScoreFA+", "W4"),
		THEME:GetString("TapNoteScoreFA+", "W5"),
		THEME:GetString("TapNoteScore", "W5"), -- FA+ mode doesn't have a Way Off window. Extract name from the ITG mode.
		THEME:GetString("TapNoteScoreFA+", "Miss"),
	}
else
	TapNoteScores.Types = {'W1', 'W2', 'W3', 'W4', 'W5', 'Miss'}
	Colors = {
		SL.JudgmentColors[SL.Global.GameMode][1],
		SL.JudgmentColors[SL.Global.GameMode][2],
		SL.JudgmentColors[SL.Global.GameMode][3],
		SL.JudgmentColors[SL.Global.GameMode][4],
		SL.JudgmentColors[SL.Global.GameMode][5],
		SL.JudgmentColors[SL.Global.GameMode][6],
	}
	local tns_string = "TapNoteScore" .. (SL.Global.GameMode=="ITG" and "" or SL.Global.GameMode)
	-- get TNS names appropriate for the current GameMode, localized to the current language
	for i, judgment in ipairs(TapNoteScores.Types) do
		TapNoteScores.Names[#TapNoteScores.Names+1] = THEME:GetString(tns_string, judgment)
	end
end

local box_height = 146
local row_height = box_height/#TapNoteScores.Types

local t = Def.ActorFrame{
	InitCommand=function(self) self:xy(50 * (player==PLAYER_2 and -1 or 1), _screen.cy-36) end
}

local miss_bmt

local windows = SL[pn].ActiveModifiers.TimingWindows

--  labels: W1 ---> Miss
for i=1, #TapNoteScores.Types do
	-- no need to add BitmapText actors for TimingWindows that were turned off
	if windows[i] or i == #TapNoteScores.Types or (mods.ShowFaPlusWindow and mods.ShowFaPlusPane and windows[i-1]) then

		local window = TapNoteScores.Types[i]
		local label = TapNoteScores.Names[i]

		t[#t+1] = LoadFont("Common Normal")..{
			Text=label:upper(),
			InitCommand=function(self)
				self:zoom(0.8):horizalign(right):maxwidth(65/self:GetZoom())
					:x( (player == PLAYER_1 and -130) or -28 )
					:y( i * row_height )
					:diffuse( Colors[i] )

				if i == #TapNoteScores.Types then miss_bmt = self end
			end
		}
	end
end

t[#t+1] = LoadFont("Common Normal")..{
	Text=ScreenString("Held"),
	InitCommand=function(self)
		self:y(140):zoom(0.6):halign(1)
			:diffuse( SL.JudgmentColors[SL.Global.GameMode][6] )
	end,
	OnCommand=function(self)
		self:x( miss_bmt:GetX() - miss_bmt:GetWidth()/1.15 )
	end
}

return t
