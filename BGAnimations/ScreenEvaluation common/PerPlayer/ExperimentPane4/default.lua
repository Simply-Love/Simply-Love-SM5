local args = ...
local player = args.player
local hash = args.hash

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
		if not SL[pn]['Scores'][hash] then
			lastPlayed = "NEVER"
			numPlayed = 1
			firstPass = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() and "NEVER" or "TODAY"
		else
			lastPlayed = SL[pn]['Scores'][hash].LastPlayed
			numPlayed = tonumber(SL[pn]['Scores'][hash].NumTimesPlayed) + 1
			if not STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() and SL[pn]['Scores'][hash].FirstPass == "Never" then
				firstPass = GetCurrentDateTime()
			else firstPass = SL[pn]['Scores'][hash].FirstPass end
		end
		self:GetChild("LastPlayedNumber"):settext("LAST PLAYED: "..lastPlayed)
		self:GetChild("NumPlayedNumber"):settext("NUMBER OF PLAYS: "..numPlayed)
		self:GetChild("FirstPass"):settext("FIRST PASS: "..firstPass)
		--determining the highest rate we've passed the song at
		local rateScores = GetScores(player,GetCurrentHash(player),false,true) --ignore rate, check for fail
		local highestRate, highestScore
		if rateScores then --if we have scores saved for this song
			table.sort(rateScores,function(k1,k2) if k1.rate == k2.rate then return k1.score > k2.score else return tonumber(k1.rate) > tonumber(k2.rate) end end)
			highestRate = rateScores[1].rate
			highestScore = rateScores[1].score
		end
		--if we passed the song we still need to compare the current song as scores don't save until profile does (after screeneval)
		if not STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() then
			--if there were no scores saved then current song is highest
			if not highestRate then
				highestRate = SL.Global.ActiveModifiers.MusicRate
				highestScore = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints()
			--if there is a score saved but our current rate is higher
			elseif highestRate and SL.Global.ActiveModifiers.MusicRate > tonumber(highestRate) then
				highestRate = SL.Global.ActiveModifiers.MusicRate
				highestScore = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints()
			--if there is a score saved and the rate is the same
			elseif highestRate and SL.Global.ActiveModifiers.MusicRate == tonumber(highestRate) and
			STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints() >= tonumber(highestScore) then
				highestScore = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints()
			end
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