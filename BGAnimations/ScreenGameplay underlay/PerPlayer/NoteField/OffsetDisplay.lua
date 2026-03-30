-- This early/late indicator was made by SteveReen for the Waterfall theme and
-- later modified for SL.

local player = ...
local mods = SL[ToEnumShortString(player)].ActiveModifiers

if not mods.ErrorMSDisplay then return end

local judgmentColors = {
    TapNoteScore_W1 = SL.JudgmentColors[SL.Global.GameMode][1],
    TapNoteScore_W2 = SL.JudgmentColors[SL.Global.GameMode][2],
    TapNoteScore_W3 = SL.JudgmentColors[SL.Global.GameMode][3],
    TapNoteScore_W4 = SL.JudgmentColors[SL.Global.GameMode][4],
    TapNoteScore_W5 = SL.JudgmentColors[SL.Global.GameMode][5],
}
if mods.ShowFaPlusWindow then
	judgmentColors["TapNoteScore_W1"] = SL.JudgmentColors["FA+"][1]
end

local af = Def.ActorFrame{
    OnCommand = function(self)
		local opts = GAMESTATE:GetPlayerState(player):GetCurrentPlayerOptions()
        self:xy(GetNotefieldX(player), _screen.cy)
    end,

    LoadFont(ThemePrefs.Get("ThemeFont") == "Common" and "Wendy/_wendy small" or "Mega/_mega font")..{
        Text = "",
        InitCommand = function(self)
            self:zoom(0.25):shadowlength(1)
        end,
        JudgmentMessageCommand = function(self, params)
            if params.Player ~= player then return end
            if params.HoldNoteScore then return end

            local score = ToEnumShortString(params.TapNoteScore)
            if score == "W1" or score == "W2" or score == "W3" or score == "W4" or score == "W5" then
				self:finishtweening()
				
				local color = judgmentColors[params.TapNoteScore] 

				-- Check if we need to adjust the color for the white fantastic window.
				if mods.ShowFaPlusWindow and ToEnumShortString(params.TapNoteScore) == "W1" and
					not IsW0Judgment(params, player) then
						color = SL.JudgmentColors["FA+"][2]
				end

				self:diffusealpha(1)
					:settext( ("%.2fms"):format(params.TapNoteOffset*1000) )
					:diffuse(color)
					:x(0)
					:sleep(0.5)
					:diffusealpha(0)
            end
        end
    },
}

return af
