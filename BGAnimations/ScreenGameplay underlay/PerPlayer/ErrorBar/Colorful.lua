-- This error bar was made by SteveReen for the Waterfall theme and later
-- modified for SL.

local player, layout = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local gmods = SL.Global.ActiveModifiers

local barWidth = 160
local barHeight = 10
local tickWidth = 2
local tickDuration = 0.5
local numTicks = mods.ErrorBarMultiTick and 10 or 1
local currentTick = 1

local enabledTimingWindows = {}
for i = 1, NumJudgmentsAvailable() do
    if gmods.TimingWindows[i] then
        enabledTimingWindows[#enabledTimingWindows+1] = i
    end
end

local maxTimingOffset = GetTimingWindow(enabledTimingWindows[#enabledTimingWindows])
local wscale = barWidth / 2 / maxTimingOffset

-- one way of drawing these quads would be to just draw them centered, back to
-- front, with the full width of the corresponding window. this would look bad
-- if we want to alpha blend them though, so i'm drawing the segments
-- individually so that there is no overlap.
local af = Def.ActorFrame{
    InitCommand = function(self)
        self:xy(GetNotefieldX(player), layout.y)

        if numTicks == 1 then
            self:zoom(0)
        end
    end,
    JudgmentMessageCommand = function(self, params)
        if params.Player ~= player then return end
        if params.HoldNoteScore then return end

        local score = ToEnumShortString(params.TapNoteScore)
        if score == "W1" or score == "W2" or score == "W3" or score == "W4" or score == "W5" then
            local tick = self:GetChild("Tick" .. currentTick)
            currentTick = currentTick % numTicks + 1

            if numTicks > 1 then
                tick:finishtweening()

                tick:diffusealpha(1)
                    :x(params.TapNoteOffset * wscale)
                    :sleep(0.03):linear(tickDuration - 0.03)
                    :diffusealpha(0)
            else
                self:finishtweening()
                self:zoom(1)

                tick:diffusealpha(1)
                    :x(params.TapNoteOffset * wscale)

                self:sleep(tickDuration)
                    :zoom(0)
            end
        end
    end,

    -- Background
    Def.Quad{
        InitCommand = function(self)
            self:zoomto(barWidth + 4, barHeight + 4)
                :diffuse(color("#000000"))
        end
    },
}

local lastx = 0

-- create two quads for each window.
for i = 1, #enabledTimingWindows do
    local wi = enabledTimingWindows[i]
    local x = GetTimingWindow(wi) * wscale
    local width = x - lastx
    local judgmentColor = SL.JudgmentColors[SL.Global.GameMode][wi]

    af[#af+1] = Def.Quad{
        InitCommand = function(self)
            self:x(-x):horizalign("left"):zoomto(width, barHeight):diffuse(judgmentColor)
        end
    }
    af[#af+1] = Def.Quad{
        InitCommand = function(self)
            self:x(x):horizalign("right"):zoomto(width, barHeight):diffuse(judgmentColor)
        end
    }

    lastx = x
end

-- Ticks
for i = 1, numTicks do
    af[#af+1] = Def.Quad{
        Name = "Tick" .. i,
        InitCommand = function(self)
            self:zoomto(tickWidth, barHeight + 4)
                :diffuse(color("#b20000"))
                :diffusealpha(0)
                :draworder(100)
        end
    }
end

return af
