-- Modified Error Bar that displays the average error of the last X number of steps (or all steps hit within the last X ms)

local player, layout = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local playerState = GAMESTATE:GetPlayerState(player)

local hideEarlyJudgment = mods.HideEarlyDecentWayOffJudgments and true or false

local barWidth = 325
local barHeight = 7
local tickWidth = 2
local tickDuration = 0.5
local numTicks = mods.ErrorBarMultiTick and 5 or 1
local currentTick = 1

local offsets = {} --track all offsets for averaging
local numMillisecondsToAvg = 400
local numArrowsToAvg = 1
local offsetScale = 1 --Make the movements on the error bar more or less pronounced
--barWidth = mods.ErrorBarMultiTick and barWidth or barWidth*mods.HighlightZoom

local enabledTimingWindows = {}

-- Find out maximum timing window for error bar
local judgmentToTrim = {
	TapNoteScore_W2 = mods.ErrorBarTrim == "Fantastic" and SL.Global.GameMode == "ITG",
    TapNoteScore_W3 = (mods.ErrorBarTrim == "Fantastic" or mods.ErrorBarTrim == "Excellent") and SL.Global.GameMode == "ITG",
    TapNoteScore_W4 = (mods.ErrorBarTrim ~= "Off" and SL.Global.GameMode == "ITG") or (mods.ErrorBarTrim == "Excellent" and SL.Global.GameMode == "FA+"),
    TapNoteScore_W5 = mods.ErrorBarTrim ~= "Off"
}

for i = 1, NumJudgmentsAvailable() do
    if mods.TimingWindows[i] then
        if not judgmentToTrim["TapNoteScore_W" .. tostring(i)] then
            enabledTimingWindows[#enabledTimingWindows + 1] = i
        end
    end
end

local maxTimingOffset = GetTimingWindow(enabledTimingWindows[#enabledTimingWindows])
local wscale = barWidth / 2 / maxTimingOffset

local function DisplayTick(self, params)
    local score = ToEnumShortString(params.TapNoteScore)
    if score == "W1" or score == "W2" or score == "W3" or score == "W4" or score == "W5" then
        local tick = self:GetChild("Tick" .. currentTick)
		local centerTick = self:GetChild("CenterTick")
        local bar = self:GetChild("Bar")
		local window

        currentTick = currentTick % numTicks + 1
		
		local currentTimeMilliseconds = round(playerState:GetSongPosition():GetMusicSeconds(),2) * 1000
		
		offsets[#offsets+1] = {currentTimeMilliseconds, params.TapNoteOffset}
		numOffsets = 0
		totalOffset = 0;
		local lastOffsetIndex = #offsets
		if numMillisecondsToAvg == 0 then
			-- Average the last numArrowsToAvg steps
			for i = 1, numArrowsToAvg do
				if #offsets+1-i <= 0 then
					break
				end
				lastOffsetIndex = #offsets+1-i
				totalOffset = totalOffset + offsets[#offsets+1-i][2]
				numOffsets = numOffsets + 1
			end
		else
			--Average all steps in the last numMillisecondsToAvg ms
			for i = 1, #offsets do
				--If current offset is not within numMillisecondsToAvg ms of the last note hit, then break
				if currentTimeMilliseconds - offsets[#offsets+1-i][1] > numMillisecondsToAvg then
					break
				end
				lastOffsetIndex = #offsets+1-i
				totalOffset = totalOffset + offsets[#offsets+1-i][2]
				numOffsets = numOffsets + 1
			end
		end
		--If numOffsets to average is odd, then discard the last one to make it even
		if numOffsets > 1 and numOffsets % 2 == 1 then
			totalOffset = totalOffset - offsets[lastOffsetIndex][2]
			numOffsets = numOffsets - 1
		end
		local offset = totalOffset/numOffsets
		
		if math.abs(offset) > maxTimingOffset then
			-- Round score to the error cap
			score = "W" .. enabledTimingWindows[#enabledTimingWindows]
			if offset < 0 then offset = -maxTimingOffset
			else offset = maxTimingOffset end
		end
		
		offset = offset*offsetScale
		
		--Apply an additional correction if not using an average because it's jarring otherwise
		if numOffsets == 1 then
			offset = offset*0.75
		end
		
		-- SM("-----------Debug Offset-----------")
		-- SM(string.format("%.2f", offset*1000) .. " " .. string.format("%.2f", offset*(15/(math.abs(offset*1000) + 5))*1000))
		
		--Custom correction (move the tick less and less outwards as the error gets worse)
		--offset = offset*(15/(math.abs(offset*1000) + 5))
		
		
		-- Check if we need to adjust the color for the white fantastic window.
		local is_W0 = IsW010Judgment(params, player) or (not mods.SmallerWhite and IsW0Judgment(params, player))
        if mods.ShowFaPlusWindow and ToEnumShortString(params.TapNoteScore) == "W1" and
            is_W0 then
            score = "W0"
        end
		if offset >= 0 then
			window = self:GetChild("Bar"):GetChild("Windowl" .. score)
		else
			window = self:GetChild("Bar"):GetChild("Windowe" .. score)
		end

        tick:finishtweening()
		centerTick:finishtweening()
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
		
		if mods.CenterTick then
			centerTick:diffusealpha(0.3)
                  :sleep(tickDuration):diffusealpha(0)
		end
		
		-- Disable the error bar rectangle for now
		window = nil
		
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
	-- y-70 with -90 rotation is centered over the targets (y-43 is lined up with bottom of receptors for 10% mini)
        self:xy(GetNotefieldX(player), layout.y-70)
        self:GetChild("Bar"):zoom(0)
		--self:rotationz(-90)
    end,
    EarlyHitMessageCommand=function(self, params)
        if params.Player ~= player or hideEarlyJudgment then return end

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
				:diffusealpha(0)
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
        windows.timing[#windows.timing + 1] = GetTimingWindow(1, "FA+", mods.SmallerWhite)
        windows.color[#windows.color + 1] = SL.JudgmentColors["FA+"][1]

        windows.timing[#windows.timing + 1] = GetTimingWindow(2, "FA+")
        windows.color[#windows.color + 1] = SL.JudgmentColors["FA+"][2]
    else
        windows.timing[#windows.timing + 1] = GetTimingWindow(wi)
        windows.color[#windows.color + 1] = SL.JudgmentColors[SL.Global.GameMode][wi]
    end 
end

-- Disable the error bar rectangle for now
-- create two quads for each window.
-- for i, window in ipairs(windows.timing) do
    -- local x = window * wscale
    -- local width = x - lastx
    -- local judgmentColor = windows.color[i]
	-- local windowNum = i
	-- if mods.ShowFaPlusWindow then windowNum = windowNum - 1 end

    -- bar_af[#bar_af+1] = Def.Quad{
		-- Name = "Window" .. "eW" .. windowNum,
        -- InitCommand = function(self)
            -- self:x(-x):horizalign("left"):zoomto(width, barHeight):diffuse(judgmentColor):diffusealpha(0.3)
        -- end
    -- }
    -- bar_af[#bar_af+1] = Def.Quad{
		-- Name = "Window" .. "lW" .. windowNum,
        -- InitCommand = function(self)
            -- self:x(x):horizalign("right"):zoomto(width, barHeight):diffuse(judgmentColor):diffusealpha(0.3)
        -- end
    -- }

    -- lastx = x
-- end

-- Ticks
for i = 1, numTicks do
    af[#af+1] = Def.Quad{
        Name = "Tick" .. i,
        InitCommand = function(self)
            self:zoomto(tickWidth, barHeight + 4 + 75)
                :diffuse(color("#b20000"))
                :diffusealpha(0)
                :draworder(100)
        end
    }
end

af[#af+1] = Def.Quad{
	Name = "CenterTick",
	InitCommand = function(self)
		self:zoomto(1, barHeight + 4 + 75)
			:diffuse(color("#ffffff"))
			:diffusealpha(0)
			:draworder(100)
	end
}

return af
