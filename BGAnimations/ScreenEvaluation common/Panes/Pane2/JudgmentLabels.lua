local player = ...
local pn = ToEnumShortString(player)
local track_missbcheld = SL[pn].ActiveModifiers.MissBecauseHeld

local TapNoteScores = { Types={'W1', 'W2', 'W3', 'W4', 'W5', 'Miss'}, Names={} }
local tns_string = "TapNoteScore" .. (SL.Global.GameMode=="DD" and "")
-- get TNS names appropriate for the current GameMode, localized to the current language
for i, judgment in ipairs(TapNoteScores.Types) do
	TapNoteScores.Names[#TapNoteScores.Names+1] = THEME:GetString(tns_string, judgment)
end

local box_height = 146
local row_height = box_height/#TapNoteScores.Types

local t = Def.ActorFrame{
	InitCommand=function(self) self:xy(50 * (player==PLAYER_2 and -1 or 1), _screen.cy-36) end
}

local miss_bmt

local windows = SL.Global.ActiveModifiers.TimingWindows

--  labels: W1 ---> Miss
for i=1, #TapNoteScores.Types do
	-- no need to add BitmapText actors for TimingWindows that were turned off
	if windows[i] or i==#TapNoteScores.Types then

		local window = TapNoteScores.Types[i]
		local label = TapNoteScores.Names[i]

		t[#t+1] = LoadFont("Common Normal")..{
			Text=label:upper(),
			InitCommand=function(self)
				self:zoom(0.8):horizalign(right):maxwidth(65/self:GetZoom())
					:x( (player == PLAYER_1 and -130) or -28 )
					:y( i * row_height )
					:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )

				if i == #TapNoteScores.Types then miss_bmt = self end
			end
		}
	end
end

if track_missbcheld then
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
end

return t