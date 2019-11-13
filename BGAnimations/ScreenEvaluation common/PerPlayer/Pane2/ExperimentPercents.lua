local player = ...
local pn = ToEnumShortString(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local TapNoteScores = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	-- x values for P1 and P2
	x = { P1=64, P2=94 }
}

local RadarCategories = {
	Types = { 'Holds', 'Mines', 'Hands', 'Rolls' },
	-- x values for P1 and P2
	x = { P1=-180, P2=218 }
}

-----------------------------------------------------------------------------------------------------------------
--AF for the stats to compare to

local percentT = Def.ActorFrame{
	InitCommand=function(self)self:zoom(0.8):xy(_screen.cx - 155,_screen.cy-24) end,
}

-- do "regular" TapNotes first
for i=1,#TapNoteScores.Types do
	local window = TapNoteScores.Types[i]

	--delta between current stats and highscore stats
	percentT[#percentT+1] = LoadFont("_wendy small")..{
		InitCommand=function(self)
			self:settext(string.format("%.2f%%", pss:GetPercentageOfTaps( "TapNoteScore_"..window )*100.0))
			self:zoom(.5):horizalign(left)
			self:x( TapNoteScores.x[pn] -200)
			self:y((i-1)*35 -20)
			if SL.Global.GameMode ~= "ITG" then
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
			end
			-- if some TimingWindows were turned off, the leading 0s should not
			-- be colored any differently than the (lack of) JudgmentNumber,
			-- so load a unique Metric group.
			local gmods = SL.Global.ActiveModifiers
			if i > gmods.WorstTimingWindow and i ~= #TapNoteScores.Types then
				self:diffuse(color("#444444"))
			end
		end,
	}
end

local percentLostT = Def.ActorFrame{
	InitCommand=function(self)self:zoom(0.8):xy(_screen.cx - 155,_screen.cy-40) end,
	
	LoadFont("_wendy small")..{
		Text="LOST %",
		InitCommand=function(self)
			self:zoom(.5):horizalign(left)
		end,
	},
	LoadFont("_wendy small")..{
		InitCommand=function(self)
			self:zoom(.5):x(150):horizalign(left)
			if pss:GetFailed() then
				self:settext("FAILED"):x(120)
			else
				self:settext("100")
			end
		end,
	}
}

local total = {100}
-- do "regular" TapNotes
for i=2,#TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local missingDP = (5 - SL.Metrics.ITG["PercentScoreWeight"..window]) * pss:GetTapNoteScores( "TapNoteScore_"..window ) --TODO only works for ITG weights
	local missingPercent = missingDP / pss:GetPossibleDancePoints() * 100
	total[#total+1] = total[#total] - missingPercent
	--delta between current stats and highscore stats
	percentLostT[#percentLostT+1] = LoadFont("_wendy small")..{
		InitCommand=function(self)
			self:settext(string.format("%.2f%%",missingPercent))
			self:zoom(.5):horizalign(left)
			self:y((i-1)*35)
			if SL.Global.GameMode ~= "ITG" then
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
			end
			-- if some TimingWindows were turned off, the leading 0s should not
			-- be colored any differently than the (lack of) JudgmentNumber,
			-- so load a unique Metric group.
			local gmods = SL.Global.ActiveModifiers
			if i > gmods.WorstTimingWindow and i ~= #TapNoteScores.Types then
				self:diffuse(color("#444444"))
			end
		end,
	}
	if not pss:GetFailed() then
		percentLostT[#percentLostT+1] = LoadFont("_ScreenEvaluation numbers")..{
			InitCommand=function(self)
				self:settext(string.format("%.2f",total[i]))
				self:zoom(.4):x(150):horizalign(left)
				self:y((i-1)*35)
				if SL.Global.GameMode ~= "ITG" then
					self:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
				end
				-- if some TimingWindows were turned off, the leading 0s should not
				-- be colored any differently than the (lack of) JudgmentNumber,
				-- so load a unique Metric group.
				local gmods = SL.Global.ActiveModifiers
				if i > gmods.WorstTimingWindow and i ~= #TapNoteScores.Types then
					self:diffuse(color("#444444"))
				end
			end,
		}
	end
end

local toReturn = Def.ActorFrame{Name="DeltaT"}
toReturn[#toReturn+1] = percentT
toReturn[#toReturn+1] = percentLostT

return toReturn