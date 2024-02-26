-- Modified version of Colorful to highlight the timing window you fall into

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

local judgmentToTrim = {
    TapNoteScore_W3 = mods.ErrorBarTrim == "Excellent" and SL.Global.GameMode == "ITG",
    TapNoteScore_W4 = (mods.ErrorBarTrim ~= "Off" and SL.Global.GameMode == "ITG") or (mods.ErrorBarTrim == "Excellent" and SL.Global.GameMode == "FA+"),
    TapNoteScore_W5 = mods.ErrorBarTrim ~= "Off"
}

local enabledTimingWindows = {}
for i = 1, NumJudgmentsAvailable() do
    if gmods.TimingWindows[i] then
        if not judgmentToTrim["TapNoteScore_W" .. tostring(i)] then
            enabledTimingWindows[#enabledTimingWindows + 1] = i
        end

local maxTimingOffset = GetTimingWindow(enabledTimingWindows[#enabledTimingWindows])
local wscale = barWidth / 2 / maxTimingOffset

local function DisplayTick(self, params)
    local score = ToEnumShortString(params.TapNoteScore)
    if score == "W1" or score == "W2" or score == "W3" or score == "W4" or score == "W5" then
        local tick = self:GetChild("Tick" .. currentTick)
        local bar = self:GetChild("Bar")
		local window

        currentTick = currentTick % numTicks + 1
		
		local offset = params.TapNoteOffset
		if judgmentToTrim[params.TapNoteScore] then
			if offset < 0 then offset = -maxTimingOffset
			else offset = maxTimingOffset end
		end
		
		-- Check if we need to adjust the color for the white fantastic window.
        if mods.ShowFaPlusWindow and ToEnumShortString(params.TapNoteScore) == "W1" and
            IsW0Judgment(params, player) then
            score = "W0"
        end
		if offset >= 0 then
			window = self:GetChild("Bar"):GetChild("Windowl" .. score)
		else
			window = self:GetChild("Bar"):GetChild("Windowe" .. score)
		end

        tick:finishtweening()
        bar:finishtweening()
        bar:zoom(1)

        if numTicks > 1 then
            tick:diffusealpha(1)
                :x(offset * wscale)
                :sleep(0.03):linear(tickDuration - 0.03)
                :diffusealpha(0)
        else
            tick:diffusealpha(1)
                :x(offset * wscale)
                :sleep(tickDuration):diffusealpha(0)
        end
		
		if window then
			if score == "W0" then
				window = self:GetChild("Bar"):GetChild("WindowlW0")
				local window2 = self:GetChild("Bar"):GetChild("WindoweW0")
				window2:finishtweening()
					:diffusealpha(1)
					:sleep(0.03):linear(tickDuration - 0.03)
					:diffusealpha(0.3)
			elseif not mods.ShowFaPlusWindow and score == "W1" then
				window = self:GetChild("Bar"):GetChild("WindowlW1")
				local window2 = self:GetChild("Bar"):GetChild("WindoweW1")
				window2:finishtweening()
					:diffusealpha(1)
					:sleep(0.03):linear(tickDuration - 0.03)
					:diffusealpha(0.3)
			end
			window:finishtweening()
				:diffusealpha(1)
				:sleep(0.03):linear(tickDuration - 0.03)
				:diffusealpha(0.3)
		end

        bar:sleep(tickDuration)
            :zoom(0)
    end
end

-- one way of drawing these quads would be to just draw them centered, back to
-- front, with the full width of the corresponding window. this would look bad
-- if we want to alpha blend them though, so i'm drawing the segments
-- individually so that there is no overlap.
local af = Def.ActorFrame{
    InitCommand = function(self)
        self:xy(GetNotefieldX(player), layout.y)
        self:GetChild("Bar"):zoom(0)
    end,
    EarlyHitMessageCommand=function(self, params)
        if params.Player ~= player then return end

        DisplayTick(self, params)
    end,
    JudgmentMessageCommand = function(self, params)
        if params.Player ~= player then return end
        if params.HoldNoteScore then return end

        if params.EarlyTapNoteScore ~= nil then
            local tns = ToEnumShortString(params.TapNoteScore)
            local earlyTns = ToEnumShortString(params.EarlyTapNoteScore)
            if earlyTns ~= "None" then
                if SL.Global.GameMode == "FA+" then
                    if tns == "W5" then
                        return
                    end
                else
                    if tns == "W4" or tns == "W5" then
                        return
                    end
                end
            end
        end

        DisplayTick(self, params)
    end,
}

local bar_af = Def.ActorFrame{
    Name = "Bar",

    -- Background
    Def.Quad{
        InitCommand = function(self)
            self:zoomto(barWidth + 4, barHeight + 4)
                :diffuse(color("#000000"))
        end
    },
}
af[#af+1] = bar_af

local lastx = 0

local windows = {
    timing = {},
    color = {},
}

for i = 1, #enabledTimingWindows do
    local wi = enabledTimingWindows[i]
    
    if mods.ShowFaPlusWindow and wi == 1 then
        -- Split the Fantastic window
        windows.timing[#windows.timing + 1] = GetTimingWindow(1, "FA+")
        windows.color[#windows.color + 1] = SL.JudgmentColors["FA+"][1]

        windows.timing[#windows.timing + 1] = GetTimingWindow(2, "FA+")
        windows.color[#windows.color + 1] = SL.JudgmentColors["FA+"][2]
    else
        windows.timing[#windows.timing + 1] = GetTimingWindow(wi)
        windows.color[#windows.color + 1] = SL.JudgmentColors[SL.Global.GameMode][wi]
    end 
end

-- create two quads for each window.
for i, window in ipairs(windows.timing) do
    local x = window * wscale
    local width = x - lastx
    local judgmentColor = windows.color[i]
	local windowNum = i
	if mods.ShowFaPlusWindow then windowNum = windowNum - 1 end

    bar_af[#bar_af+1] = Def.Quad{
		Name = "Window" .. "eW" .. windowNum,
        InitCommand = function(self)
            self:x(-x):horizalign("left"):zoomto(width, barHeight):diffuse(judgmentColor):diffusealpha(0.3)
        end
    }
    bar_af[#bar_af+1] = Def.Quad{
		Name = "Window" .. "lW" .. windowNum,
        InitCommand = function(self)
            self:x(x):horizalign("right"):zoomto(width, barHeight):diffuse(judgmentColor):diffusealpha(0.3)
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
