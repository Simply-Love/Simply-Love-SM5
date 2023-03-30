-- This early/late indicator was made by SteveReen for the Waterfall theme and
-- later modified for SL.

local player, layout = ...
local mods = SL[ToEnumShortString(player)].ActiveModifiers

local threshold = nil
for i = 1, NumJudgmentsAvailable() do
    if mods.TimingWindows[i] then
        if i == 1 and (mods.ShowFaPlusWindow or (mods.SmallerWhite and SL.Global.GameMode == "FA+")) then
            threshold = GetTimingWindow(1, "FA+", mods.SmallerWhite)
        else
            threshold = GetTimingWindow(i)
        end
        break
    end
end

local af = Def.ActorFrame{
    OnCommand = function(self)
        self:xy(GetNotefieldX(player), layout.y)
    end,

    LoadFont("Wendy/_wendy small")..{
        Text = "",
        InitCommand = function(self)
            self:zoom(0.25):shadowlength(1)
        end,
        JudgmentMessageCommand = function(self, params)
            if params.Player ~= player then return end
            if params.HoldNoteScore then return end

            local score = ToEnumShortString(params.TapNoteScore)
            if score == "W1" or score == "W2" or score == "W3" or score == "W4" or score == "W5" then
                if math.abs(params.TapNoteOffset) > threshold then
                    self:finishtweening()

                    self:diffusealpha(1)
                        :settext(params.Early and "EARLY" or "LATE")
                        :diffuse(color("#ffffff"))
                        :x((params.Early and -1 or 1) * 40)
                        :sleep(0.5)
                        :diffusealpha(0)
                else
                    self:finishtweening()
                    self:diffusealpha(0)
                end
            end
        end
    },
}

return af
