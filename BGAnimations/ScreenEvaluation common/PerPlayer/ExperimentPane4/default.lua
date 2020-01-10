local player = ...

local pane = Def.ActorFrame{
	Name="Pane4",
	InitCommand=function(self)
		self:visible(false)
	end,
	OnCommand=function(self)
		self:playcommand("Set")
	end,
	SetCommand=function(self)
		local lastPlayedDates = GetLastPlayedDates(player)
		local pn = ToEnumShortString(player)
		local lastPlayed
		local numPlayed
		self:GetChild("LastPlayedNumber"):settext("LAST PLAYED: NEVER") 
		self:GetChild("NumPlayedNumber"):settext("NUMBER OF PLAYS: 1")
		if lastPlayedDates then
			for item in ivalues(lastPlayedDates) do
				if item.group == GAMESTATE:GetCurrentSong():GetGroupName() and
				   item.song == GAMESTATE:GetCurrentSong():GetMainTitle() and
				   item.Difficulty == ToEnumShortString(GAMESTATE:GetCurrentSteps(pn):GetDifficulty()) and
				   item.StepsType == ToEnumShortString(GetStepsType()) then
					if item.LastPlayed then self:GetChild("LastPlayedNumber"):settext("LAST PLAYED: "..item.LastPlayed) end
					if item.NumTimesPlayed then self:GetChild("NumPlayedNumber"):settext("NUMBER OF PLAYS: "..item.NumTimesPlayed+1) end
					break
				end
			end
		end
		local rateScores = GetScores(player,GAMESTATE:GetCurrentSong(),GAMESTATE:GetCurrentSteps(pn))
		if rateScores then 
			table.sort(rateScores,function(k1,k2) return k1.rate > k2.rate end)
			self:GetChild("MaxRate"):settext("MAX RATE: "..rateScores[1].rate.." ("..FormatPercentScore(rateScores[1].score)..")")
		end
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

return pane