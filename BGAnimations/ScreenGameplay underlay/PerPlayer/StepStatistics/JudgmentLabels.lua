local player = ...
local pn = ToEnumShortString(player)

local TapNoteScores = { Types={'W1', 'W2', 'W3', 'W4', 'W5', 'Miss'}, Names={} }
local tns_string = "TapNoteScore" .. (SL.Global.GameMode=="ITG" and "" or SL.Global.GameMode)
-- get TNS names appropriate for the current GameMode, localized to the current language
for i, judgment in ipairs(TapNoteScores.Types) do
	TapNoteScores.Names[#TapNoteScores.Names+1] = THEME:GetString(tns_string, judgment)
end

local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
}

local row_height = 28
local windows = SL.Global.ActiveModifiers.TimingWindows

local af = Def.ActorFrame{}

--  labels: W1, W2, W3, W4, W5, Miss
for i, label in ipairs(TapNoteScores.Names) do

	-- no need to add BitmapText actors for TimingWindows that were turned off
	if windows[i] or i==#TapNoteScores.Names then

		af[#af+1] = LoadFont("Common Normal")..{
			Text=label:upper(),
			InitCommand=function(self) self:zoom(0.833):horizalign(right):maxwidth(72) end,
			BeginCommand=function(self)
				self:x(80):y((i-1)*row_height - 226)
				    :diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
			end
		}
	end
end

-- labels: holds, mines, rolls
for i, label in ipairs(RadarCategories) do
	af[#af+1] = LoadFont("Common Normal")..{
		Text=label,
		InitCommand=function(self) self:zoom(0.833):horizalign(right) end,
		BeginCommand=function(self)
			self:x(-94):y((i-1)*row_height - 143)
		end
	}
end

return af