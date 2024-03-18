local player, controller = unpack(...)

local pn = ToEnumShortString(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local TapNoteScores = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	-- x values for P1 and P2
	x = { P1=64, P2=94 }
}

local RadarCategories = {
	Types = { 'Hands', 'Holds', 'Mines', 'Rolls' },
	-- x values for P1 and P2
	x = { P1=-180, P2=218 }
}

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

-- do "regular" TapNotes first
for i=1,#TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local number = pss:GetTapNoteScores( "TapNoteScore_"..window )
	local number10 = number
	local display15 = false

	-- actual numbers
	t[#t+1] = Def.RollingNumbers{
		Font=ThemePrefs.Get("ThemeFont") .. " ScreenEval",
		InitCommand=function(self)
			self:zoom(0.5):horizalign(right)

			self:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )

			-- if some TimingWindows were turned off, the leading 0s should not
			-- be colored any differently than the (lack of) JudgmentNumber,
			-- so load a unique Metric group.
			if SL[pn].ActiveModifiers.TimingWindows[i]==false and i ~= #TapNoteScores.Types then
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
			self:y((i-1)*35 -20)
			self:targetnumber(number)
		end,
	}

end

-- then handle hands/ex, holds, mines, rolls
for index, RCType in ipairs(RadarCategories.Types) do
	-- Replace hands with the EX score only in FA+ mode.
	-- We have a separate FA+ pane for ITG mode.
	if index == 1 and SL.Global.GameMode == "FA+" then
		t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
			Name="Percent",
			Text=("%.2f"):format(CalculateExScore(player, counts)),
			InitCommand=function(self)
				self:horizalign(right):zoom(0.65)
				self:x( ((controller == PLAYER_1) and -114) or 286 )
				self:y(47)
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][1] )
			end
		}
	else
		local performance = pss:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		local possible = pss:GetRadarPossible():GetValue( "RadarCategory_"..RCType )
		possible = clamp(possible, 0, 999)

		-- player performance value
		-- use a RollingNumber to animate the count tallying up for visual effect
		t[#t+1] = Def.RollingNumbers{
			Font=ThemePrefs.Get("ThemeFont") .. " ScreenEval",
			InitCommand=function(self) self:zoom(0.5):horizalign(right):Load("RollingNumbersEvaluationB") end,
			BeginCommand=function(self)
				self:x( RadarCategories.x[ToEnumShortString(controller)] )
				self:y((index-1)*35 + 53)
				self:targetnumber(performance)
			end
		}

		-- slash and possible value
		t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " ScreenEval")..{
			InitCommand=function(self) self:zoom(0.5):horizalign(right) end,
			BeginCommand=function(self)
				self:x( ((controller == PLAYER_1) and -114) or 286 )
				self:y((index-1)*35 + 53)
				self:settext(("/%03d"):format(possible))
				local leadingZeroAttr = { Length=4-tonumber(tostring(possible):len()), Diffuse=color("#5A6166") }
				self:AddAttribute(0, leadingZeroAttr )
			end
		}
	end
end

return t