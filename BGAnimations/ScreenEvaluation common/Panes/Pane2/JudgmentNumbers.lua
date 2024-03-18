local player, controller = unpack(...)

local pn = ToEnumShortString(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local TapNoteScores = {
	Types = { 'W0', 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	Colors = {
		SL.JudgmentColors["FA+"][1],
		SL.JudgmentColors["FA+"][2],
		SL.JudgmentColors["FA+"][3],
		SL.JudgmentColors["FA+"][4],
		SL.JudgmentColors["FA+"][5],
		SL.JudgmentColors["ITG"][5], -- FA+ mode doesn't have a Way Off window. Extract color from the ITG mode.
		SL.JudgmentColors["FA+"][6],
	},
	-- x values for P1 and P2
	x = { P1=64, P2=94 }
}

local RadarCategories = {
	Types = { 'Holds', 'Mines', 'Rolls' },
	-- x values for P1 and P2
	x = { P1=-180, P2=218 }
}

-- TODO(Zankoku) - EX judgments are in storage now, so we shouldn't have to calculate this all over again
local counts = GetExJudgmentCounts(player)

local t = Def.ActorFrame{
	InitCommand=function(self)self:zoom(0.8):xy(90,_screen.cy-24) end,
	OnCommand=function(self)
		-- shift the x position of this ActorFrame to -90 for PLAYER_2
		if controller == PLAYER_2 then
			self:x( self:GetX() * -1 )
		end
	end
}

-- The FA+ window shares the status as the FA window.
-- If the FA window is disabled, then we consider the FA+ window disabled as well.
local windows = {SL[pn].ActiveModifiers.TimingWindows[1]}
for v in ivalues( SL[pn].ActiveModifiers.TimingWindows) do
	windows[#windows + 1] = v
end

-- do "regular" TapNotes first
for i=1,#TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local number = counts[window] or 0
	local number10 = number
	local display10 = true
	
	if i == 1 then
		number10 = counts["W010"]
	elseif i == 2 then
		number10 = counts["W110"]
	end

	-- actual numbers
	t[#t+1] = Def.RollingNumbers{
		Font=ThemePrefs.Get("ThemeFont") .. " ScreenEval",
		InitCommand=function(self)
			self:zoom(0.5):horizalign(right)

			self:diffuse( TapNoteScores.Colors[i] )

			-- if some TimingWindows were turned off, the leading 0s should not
			-- be colored any differently than the (lack of) JudgmentNumber,
			-- so load a unique Metric group.
			if windows[i]==false and i ~= #TapNoteScores.Types then
				self:Load("RollingNumbersEvaluationNoDecentsWayOffs")
				self:diffuse(color("#444444"))

			-- Otherwise, We want leading 0s to be dimmed, so load the Metrics
			-- group "RollingNumberEvaluationA"	which does that for us.
			else
				self:Load("RollingNumbersEvaluationA")
			end
		end,
		BeginCommand=function(self)
			self:x( TapNoteScores.x[ToEnumShortString(controller)] )
			self:y((i-1)*32 -24)
			self:targetnumber(number)
			if SL[pn].ActiveModifiers.SmallerWhite then
				self:playcommand("Marquee")
			end
		end,
		MarqueeCommand=function(self)
			if display10 then
				self:settext(("%04.0f"):format(number10))
				display10 = false
			else
				self:settext(("%04.0f"):format(number))
				display10 = true
			end
			self:sleep(2):queuecommand("Marquee")
		end
	}

end

-- then handle hands/ex, holds, mines, rolls
for index, RCType in ipairs(RadarCategories.Types) do
	-- Swap to displaying ITG score if we're showing EX score in gameplay.
	local percent = nil
	if SL[pn].ActiveModifiers.ShowEXScore then
		local PercentDP = pss:GetPercentDancePoints()
		percent = FormatPercentScore(PercentDP):gsub("%%", "")
		-- Format the Percentage string, removing the % symbol
		percent = tonumber(percent)
	else
		percent = CalculateExScore(player, counts)
	end

	if index == 1 then
		t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
			Name="Percent",
			Text=("%.2f"):format(percent),
			InitCommand=function(self)
				self:horizalign(right):zoom(0.65)
				self:x( ((controller == PLAYER_1) and -114) or 286 )
				self:y(47)
				
				if SL[pn].ActiveModifiers.ShowEXScore then
					self:diffuse(Color.White)
				else
					self:diffuse( SL.JudgmentColors[SL.Global.GameMode][1] )
				end
			end
		}
	end

	local possible = counts["total"..RCType]
	local performance = counts[RCType]

	if RCType == "Mines" then
		-- The mines in the counts is mines hit but we want to display mines dodged.
		performance = possible - performance
	end

	possible = clamp(possible, 0, 999)

	-- player performance value
	-- use a RollingNumber to animate the count tallying up for visual effect
	t[#t+1] = Def.RollingNumbers{
		Font=ThemePrefs.Get("ThemeFont") .. " ScreenEval",
		InitCommand=function(self) self:zoom(0.5):horizalign(right):Load("RollingNumbersEvaluationB") end,
		BeginCommand=function(self)
			self:x( RadarCategories.x[ToEnumShortString(controller)] )
			self:y((index)*35 + 53)
			self:targetnumber(performance)
		end
	}

	-- slash and possible value
	t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " ScreenEval")..{
		InitCommand=function(self) self:zoom(0.5):horizalign(right) end,
		BeginCommand=function(self)
			self:x( ((controller == PLAYER_1) and -114) or 286 )
			self:y(index*35 + 53)
			self:settext(("/%03d"):format(possible))
			local leadingZeroAttr = { Length=4-tonumber(tostring(possible):len()), Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}
end

return t
