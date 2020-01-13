local player = ...

local CurrentDate = function()
	return Year().."-"..(MonthOfYear()+1).."-"..DayOfMonth().." "..Hour()..":"..Minute()..":00"
end

local pane = Def.ActorFrame{
	Name="Pane4",
	InitCommand=function(self)
		self:visible(false)
	end,
	OnCommand=function(self)
		self:playcommand("Set")
	end,
	SetCommand=function(self)
		local pn = ToEnumShortString(player)
		local lastPlayed, numPlayed, firstPass
		local stepsType = ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetStepsType())
		local difficulty = ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty())
		if stepsType == 'Dance_Single' then stepsType = 'dance-single' end
		if stepsType == 'Dance_Double' then stepsType = 'dance-double' end
		local hash = GenerateHash(stepsType, difficulty)
		if not SL[pn]['Scores'][hash] then
			lastPlayed = "NEVER"
			numPlayed = 1
			firstPass = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() and "TODAY" or "NEVER"
		else
			lastPlayed = SL[pn]['Scores'][hash].LastPlayed
			numPlayed = tonumber(SL[pn]['Scores'][hash].NumTimesPlayed) + 1
			firstPass = SL[pn]['Scores'][hash].FirstPass
		end
		self:GetChild("LastPlayedNumber"):settext("LAST PLAYED: "..lastPlayed)
		self:GetChild("NumPlayedNumber"):settext("NUMBER OF PLAYS: "..numPlayed)
		self:GetChild("FirstPass"):settext("FIRST PASS: "..firstPass)
		local rateScores = GetScores(player,GAMESTATE:GetCurrentSong(),GAMESTATE:GetCurrentSteps(pn))
		local highestRate, highestScore
		if rateScores then 
			table.sort(rateScores,function(k1,k2) if k1.rate == k2.rate then return k1.score > k2.score else return tonumber(k1.rate) > tonumber(k2.rate) end end)
			for score in ivalues(rateScores) do
				if score.grade ~= "Failed" then
					highestRate = score.rate
					highestScore = score.score
					break
				end
			end
		end
		if not STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() and
		SL.Global.ActiveModifiers.MusicRate >= tonumber(highestRate) and 
		STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints() >= tonumber(highestScore) then
			highestRate = SL.Global.ActiveModifiers.MusicRate
			highestScore = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints()
		end
		if highestScore then self:GetChild("MaxRate"):settext("MAX RATE CLEAR: "..highestRate.." ("..FormatPercentScore(tonumber(highestScore))..")")
		else self:GetChild("MaxRate"):settext("MAX RATE CLEAR: NONE") end
	end,
}

pane[#pane+1] = LoadActor(THEME:GetPathB("ScreenEvaluation", "common/PerPlayer/Pane3"), player)..{InitCommand=function(self) self:visible(true) end}



--LastPlayed
pane[#pane+1] = LoadFont("_wendy small")..{
	Name="LastPlayedNumber",
	InitCommand=function(self)
		self:zoom(.4):xy(_screen.cx - 250, 200):halign(0)
	end,
}

--NumTimes
pane[#pane+1] = LoadFont("_wendy small")..{
	Name="NumPlayedNumber",
	InitCommand=function(self)
		self:zoom(.4):xy(_screen.cx - 250, 230):halign(0)
	end,
}

--MaxRate
pane[#pane+1] = LoadFont("_wendy small")..{
	Name="MaxRate",
	InitCommand=function(self)
		self:zoom(.4):xy(_screen.cx - 250, 260):halign(0)
	end,
}

--FirstPass
pane[#pane+1] = LoadFont("_wendy small")..{
	Name="FirstPass",
	InitCommand=function(self)
		self:zoom(.4):xy(_screen.cx - 250, 290):halign(0)
	end,
}

return pane