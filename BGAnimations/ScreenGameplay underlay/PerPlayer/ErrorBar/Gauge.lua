-- Copyright (c) 2016-2019 Etterna <etternadev@gmail.com>.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- This error bar was made by prim for the spawncamping-wallhack theme and
-- later heavily modified by etterna devs, jordando and natano.

local player, layout = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
--local mods = SL.Global.ActiveModifiers

local judgmentColors = {
    TapNoteScore_W1 = SL.JudgmentColors[SL.Global.GameMode][1],
    TapNoteScore_W2 = SL.JudgmentColors[SL.Global.GameMode][2],
    TapNoteScore_W3 = SL.JudgmentColors[SL.Global.GameMode][3],
    TapNoteScore_W4 = SL.JudgmentColors[SL.Global.GameMode][4],
    TapNoteScore_W5 = SL.JudgmentColors[SL.Global.GameMode][5],
}

local barWidth = 240
local barHeight = layout.maxHeight
local tickWidth = 2
local tickDuration = 0.75
local numTicks = mods.ErrorBarMultiTick and 15 or 1
local currentTick = 1

-- Find out maximum timing window for error bar
local maxError = mods.ErrorBarCap < NumJudgmentsAvailable() and mods.ErrorBarCap or NumJudgmentsAvailable()

local enabledTimingWindows = {}
for i = 1, maxError do
    if mods.TimingWindows[i] then
        enabledTimingWindows[#enabledTimingWindows+1] = i
    end
end

local maxTimingOffset = GetTimingWindow(enabledTimingWindows[#enabledTimingWindows])
local wscale = 90 / maxTimingOffset

local af = Def.ActorFrame{
    InitCommand = function(self)
        self:xy(GetNotefieldX(player), layout.y)
    end,
    RemoveLabelsCommand = function(self)
        self:RemoveChild("EarlyLabel")
        self:RemoveChild("LateLabel")
    end,
    JudgmentMessageCommand = function(self, params)
        if params.Player ~= player then return end
        if params.HoldNoteScore then return end
        if not judgmentColors[params.TapNoteScore] then return end

        if params.TapNoteOffset then
            local tick = self:GetChild("Tick" .. currentTick)
            currentTick = currentTick % numTicks + 1

            tick:finishtweening()


            local color = judgmentColors[params.TapNoteScore] 

            -- Check if we need to adjust the color for the white fantastic window.
            if mods.ShowFaPlusWindow and ToEnumShortString(params.TapNoteScore) == "W1" and not IsW0Judgment(params, player) then
                color = SL.JudgmentColors["FA+"][2]
            end
			
			local offset = params.TapNoteOffset
			if math.abs(params.TapNoteOffset) > maxTimingOffset then
				if params.TapNoteOffset > 0 then
					offset = maxTimingOffset
				else
					offset = -maxTimingOffset
				end
			end

            tick:diffusealpha(1)
                :diffuse(color)
                :rotationz(offset * wscale)

            if numTicks > 1 then
                tick:sleep(0.03):linear(tickDuration - 0.03)
            else
                tick:sleep(tickDuration)
            end

            tick:diffusealpha(0)
        end
    end,

    -- Background
    Def.Quad{
        InitCommand = function(self)
            self:zoomto(barWidth + 2, barHeight+2)
                :diffuse(color("#000000"))
                :diffusealpha(.5)

            -- When a background filter or cover is used the bar doesn't need a
            -- background
            local opts = GAMESTATE:GetPlayerState(player):GetCurrentPlayerOptions()
            if mods.BackgroundFilter ~= "Off" or opts:Cover() == 1 then
                self:diffusealpha(0)
            end
        end
    },

    -- Centerpiece
    Def.Quad{
        InitCommand = function(self)
            self:vertalign('VertAlign_Bottom'):zoomto(2, math.min(barHeight*10, 100))
                :diffuse(color(.5, .5, .5, 1))
        end
    },

    -- Indicates which side is which (early/late) These will be be destroyed
    -- after the song starts.
    LoadFont("Common Normal") .. {
        Name = "EarlyLabel",
        InitCommand = function(self)
            self:x(-barWidth / 4):zoom(0.7):draworder(100)
        end,
        BeginCommand = function(self)
            self:settext("Early")
                :diffusealpha(0)
                :smooth(.5):diffusealpha(1)
                :sleep(2):smooth(.5):diffusealpha(0)
        end,
    },
    LoadFont("Common Normal") .. {
        Name = "LateLabel",
        InitCommand = function(self)
            self:x(barWidth / 4):zoom(0.7):draworder(100)
        end,
        BeginCommand = function(self)
            self:settext("Late")
                :diffusealpha(0)
                :smooth(.5):diffusealpha(1)
                :sleep(2):smooth(.5):diffusealpha(0)
                :queuecommand("Cleanup")
        end,
        CleanupCommand = function(self)
            self:GetParent():queuecommand("RemoveLabels")
        end,
    },
}

local timing = {}

for i = 1, #enabledTimingWindows do
    local wi = enabledTimingWindows[i]
    
    if mods.ShowFaPlusWindow and wi == 1 then
        -- Split the Fantastic window
        timing[#timing + 1] = GetTimingWindow(1, "FA+", mods.SmallerWhite)
        timing[#timing + 1] = GetTimingWindow(2, "FA+")
    else
        timing[#timing + 1] = GetTimingWindow(wi)
    end 
end

for window in ivalues(timing) do
    local offset = window * wscale

    af[#af+1] = Def.Quad{
        InitCommand = function(self)
            self:vertalign('VertAlign_Bottom')
				:rotationz(-offset)
                :zoomto(1, math.min(barHeight*10, 100))
                :diffuse(color(1, 1, 1, 1))
                :diffusealpha(0)
                :sleep(2.5):smooth(.5)
                :diffusealpha(.3)
        end,
    }
    af[#af+1] = Def.Quad{
        InitCommand = function(self)
            self:vertalign('VertAlign_Bottom')
				:rotationz(offset)
                :zoomto(1, math.min(barHeight*10, 100))
                :diffuse(color(1, 1, 1, 1))
                :diffusealpha(0)
                :sleep(2.5):smooth(.5)
                :diffusealpha(.3)
        end,
    }
end

-- Ticks
for i = 1, numTicks do
    af[#af+1] = Def.Quad{
        Name = "Tick" .. i,
        InitCommand = function(self)
            self:zoomto(tickWidth*2, math.min(barHeight*10, 100)):diffusealpha(0):vertalign('VertAlign_Bottom')
        end,
    }
end

return af
