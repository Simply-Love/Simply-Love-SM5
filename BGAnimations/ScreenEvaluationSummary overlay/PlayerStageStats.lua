local player, displayProfileNames = unpack(...)

local LetterGradesAF
local playerStats
local steps, meter, difficulty, stepartist, grade, score
local TNSTypes = { 'W0', 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }
local Colors = {
			SL.JudgmentColors["FA+"][1],
			SL.JudgmentColors["FA+"][2],
			SL.JudgmentColors["FA+"][3],
			SL.JudgmentColors["FA+"][4],
			SL.JudgmentColors["FA+"][5],
			SL.JudgmentColors["ITG"][5], -- FA+ mode doesn't have a Way Off window. Extract color from the ITG mode.
			SL.JudgmentColors["FA+"][6],
		}

-- variables for positioning and horizalign, dependent on playernumber
local col1x, col2x, gradex, align1, align2
if player == PLAYER_1 then
	col1x =  -90
	col2x =  -_screen.w/2.5
	gradex = -_screen.w/3.33
	align1 = right
	align2 = left
elseif player == PLAYER_2 then
	col1x = 90
	col2x = _screen.w/2.5
	gradex = _screen.w/3.33
	align1 = left
	align2 = right
end


local af = Def.ActorFrame{
	OnCommand=function(self)
		LetterGradesAF = self:GetParent():GetParent():GetChild("LetterGradesAF")
	end,
	DrawStageCommand=function(self, params)
		playerStats = SL[ToEnumShortString(player)].Stages.Stats[params.StageNum]

		if playerStats then
			profile = playerStats.profile
			steps = playerStats.steps
	 		meter = playerStats.meter
	 		difficulty = playerStats.difficulty
	 		stepartist = playerStats.stepartist
	 		grade = playerStats.grade
	 		score = playerStats.score
		end
	end
}

-- profile name (only if there were any profile switches happening this session)
if displayProfileNames then
	af[#af+1] = LoadFont("Common Normal")..{
		InitCommand=function(self) self:zoom(0.5):horizalign(align1):x(col1x):y(-43) end,
		DrawStageCommand=function(self)
			if playerStats and profile then
				self:settext(profile)
			else
				self:settext("")
			end
		end
	}
end

-- percent score
af[#af+1] = LoadFont("Common Bold")..{
	InitCommand=function(self) self:zoom(0.5):horizalign(align1):x(col1x):y(-24) end,
	DrawStageCommand=function(self)
		if playerStats and score then
		
			if playerStats and playerStats.showex then
				self:zoom(0.38):horizalign(align1):x(col1x):y(-12)
			else
				self:horizalign(align1):x(col1x)
				if playerStats and playerStats.judgments.W0 then
					self:zoom(0.48):y(-32)
				else
					self:zoom(0.5):y(-24)
				end
			end

			-- trim off the % symbol
			local score = string.sub(FormatPercentScore(score),1,-2)

			-- If the score is < 10.00% there will be leading whitespace, like " 9.45"
			-- trim that too, so PLAYER_2's scores align properly.
			score = score:gsub(" ", "")
			self:settext(score):diffuse(Color.White)

			if grade and grade == "Grade_Failed" then
				self:diffuse(Color.Red)
			end
		else
			self:settext("")
		end
	end
}

--ex score
af[#af+1] = LoadFont("Common Bold")..{
	InitCommand=function(self) self:zoom(0.38):horizalign(align1):x(col1x):y(-12) end,
	DrawStageCommand=function(self)
		if playerStats and playerStats.judgments and playerStats.judgments.W0 then
			self:settext(("%.2f"):format(playerStats.exscore)):diffuse(Colors[1])
		else
			self:settext("")
		end
		
		if playerStats and playerStats.showex then
			self:zoom(0.48):y(-32):horizalign(align1):x(col1x)
		else
			self:zoom(0.38):horizalign(align1):x(col1x):y(-12)
		end
	end
}

-- stepchart style ("single" or "double" or etc.)
-- difficulty text ("beginner" or "expert" or etc.)
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:y(17)
		self:x(col1x + (player==PLAYER_1 and -1 or 1))
		self:horizalign(align1):zoom(0.65)
	end,
	DrawStageCommand=function(self)
		if playerStats==nil then self:settext(""); return end

		local stepstype = ""
		if steps then
			-- get the StepsType for the stepchart that was played
			-- this will be a string from the StepsType enum like "StepsType_Dance_Single"
			stepstype = steps:GetStepsType()
			-- remove the first two sections, transforming something like "StepsType_Dance_Single" into "Single"
			stepstype = stepstype:gsub("%w+_%w+_", "")
			-- localize
			stepstype = THEME:GetString("ScreenSelectMusic", stepstype)
		end

		local diff_text = ""
		if difficulty then
			diff_text = THEME:GetString("Difficulty", ToEnumShortString(difficulty))
		end

		self:settext( ("%s / %s"):format(stepstype, diff_text))
	end
}

-- difficulty meter
af[#af+1] = LoadFont("Common Bold")..{
	InitCommand=function(self) self:zoom(0.4):horizalign(align1):x(col1x):y(-1) end,
	DrawStageCommand=function(self)
		if playerStats and meter then
			self:diffuse(DifficultyColor(difficulty)):settext(meter)
			if playerStats.judgments and playerStats.judgments.W0 then
				self:zoom(0.3):y(5)
			end
		else
			self:settext("")
		end
	end
}

-- stepartist
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self) self:zoom(0.65):horizalign(align1):x(col1x):y(32) end,
	DrawStageCommand=function(self)
		if playerStats and stepartist then
			self:settext(stepartist)
		else
			self:settext("")
		end
	end
}

-- letter grade
af[#af+1] = Def.ActorProxy{
	InitCommand=function(self)
		self:zoom(WideScale(0.275,0.3)):x( WideScale(194,250) * (player==PLAYER_1 and -1 or 1) ):y(-6)
	end,
	DrawStageCommand=function(self)
		if playerStats and grade then
			if playerStats.judgments.W0 and playerStats.exscore == 100 then
				self:SetTarget( LetterGradesAF:GetChild("Grade_Tier00") ):visible(true)
			else
				self:SetTarget( LetterGradesAF:GetChild(grade) ):visible(true)
			end
		else
			self:visible(false)
		end
	end
}


-- numbers

for i=1,#TNSTypes do

	af[#af+1] = LoadFont("Common Bold")..{
		InitCommand=function(self)
			self:zoom(0.28):horizalign(align2):x(col2x):y(i*13 - 50)
				:diffuse( Colors[i] )
		end,
		DrawStageCommand=function(self, params)
			if playerStats and playerStats.judgments then
				if playerStats.judgments.W0 then
					self:zoom(0.28):horizalign(align2):x(col2x):y(i*13 - 58):diffuse( Colors[i] )
				else
					self:zoom(0.28):horizalign(align2):x(col2x):y(i*13 - 63):diffuse( Colors[i] )
					if i == 2 then
						self:diffuse( Colors[1] )
					end
				end
				local val = playerStats.judgments[TNSTypes[i]]
				if val then self:settext(val) end

				self:visible( (i == 1 and playerStats.judgments.W0 ~= nil) or playerStats.timingwindows[i-1] or i==#TNSTypes )
			else
				self:settext("")
			end
		end
	}
end

return af