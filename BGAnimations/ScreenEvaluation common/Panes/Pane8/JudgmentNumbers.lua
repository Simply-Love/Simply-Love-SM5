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

local W0_count = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].W0_count

local GetCount = function(window)
	if window == 'W0' then
		return W0_count
	elseif window == 'W1' then
		return pss:GetTapNoteScores( "TapNoteScore_"..window ) - W0_count
	else
		return pss:GetTapNoteScores( "TapNoteScore_"..window )
	end
end

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
local windows = {SL.Global.ActiveModifiers.TimingWindows[1]} 
for v in ivalues( SL.Global.ActiveModifiers.TimingWindows) do
	windows[#windows + 1] = v
end

-- do "regular" TapNotes first
for i=1,#TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local number = GetCount(window)

	-- actual numbers
	t[#t+1] = Def.RollingNumbers{
		Font="Wendy/_ScreenEvaluation numbers",
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
		end
	}

end

-- then handle hands/ex, holds, mines, rolls
for index, RCType in ipairs(RadarCategories.Types) do
	if index == 1 then
		t[#t+1] = LoadFont("Wendy/_wendy white")..{
			Name="Percent",
			Text=("%.2f"):format(CalculateExScore(player)),
			InitCommand=function(self)
				self:horizalign(right):zoom(0.4)
				self:x( ((controller == PLAYER_1) and -114) or 286 )
				self:y(47)
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][1] )
			end
		}
	end

	local performance = pss:GetRadarActual():GetValue( "RadarCategory_"..RCType )
	local possible = pss:GetRadarPossible():GetValue( "RadarCategory_"..RCType )
	possible = clamp(possible, 0, 999)

	-- player performance value
	-- use a RollingNumber to animate the count tallying up for visual effect
	t[#t+1] = Def.RollingNumbers{
		Font="Wendy/_ScreenEvaluation numbers",
		InitCommand=function(self) self:zoom(0.5):horizalign(right):Load("RollingNumbersEvaluationB") end,
		BeginCommand=function(self)
			self:x( RadarCategories.x[ToEnumShortString(controller)] )
			self:y((index)*35 + 53)
			self:targetnumber(performance)
		end
	}

	-- slash and possible value
	t[#t+1] = LoadFont("Wendy/_ScreenEvaluation numbers")..{
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