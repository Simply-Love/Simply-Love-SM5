local position_on_screen = ...

local Players = GAMESTATE:GetHumanPlayers()
local SongOrCourse, StageNum, LetterGradesAF

local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualTheme")
local banner_directory = FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")

local t = Def.ActorFrame{
	OnCommand=function(self)
		LetterGradesAF = self:GetParent():GetChild("LetterGradesAF")
	end,
	DrawPageCommand=function(self, params)
		self:finishtweening():sleep(position_on_screen*0.05):linear(0.15):diffusealpha(0)

		StageNum = ((params.Page-1)*4) + position_on_screen
		local stage = SL.Global.Stages.Stats[StageNum]
		SongOrCourse = stage ~= nil and stage.song or nil

		self:queuecommand("DrawStage")
	end,
	DrawStageCommand=function(self)
		if SongOrCourse == nil then
			self:visible(false)
		else
			self:finishtweening():queuecommand("Show"):visible(true)
		end
	end,

	-- black quad
	Def.Quad{
		InitCommand=function(self) self:zoomto( _screen.w-40, 94):diffuse(0,0,0,0.5):y(-6) end
	},

	--fallback banner
	LoadActor(banner_directory.."/banner"..SL.Global.ActiveColorIndex.." (doubleres).png")..{
		InitCommand=function(self) self:y(-6):zoom(0.333) end,
		DrawStageCommand=function(self) self:visible(SongOrCourse ~= nil and not SongOrCourse:HasBanner()) end
	},

	-- the banner, if there is one
	Def.Banner{
		Name="Banner",
		InitCommand=function(self) self:y(-6) end,
		DrawStageCommand=function(self)
			if SongOrCourse then
				if GAMESTATE:IsCourseMode() then
					self:LoadFromCourse(SongOrCourse)
				else
					self:LoadFromSong(SongOrCourse)
				end
				self:setsize(418,164):zoom(0.333)
			end
		end
	},

	-- the title of the song
	LoadFont("Common Normal")..{
		InitCommand=function(self) self:zoom(0.8):y(-43):maxwidth(350) end,
		DrawStageCommand=function(self)
			if SongOrCourse then self:settext(SongOrCourse:GetDisplayFullTitle()) end
		end
	},

	-- the BPM(s) of the song
	-- FIXME: the current layout of ScreenEvaluationSummary doesn't accommodate split BPMs
	--        so this is currently hardcoded to use the MasterPlayer's BPM values
	LoadFont("Common Normal")..{
		InitCommand=function(self) self:zoom(0.6):y(30):maxwidth(350) end,
		DrawStageCommand=function(self)
			if SongOrCourse then
				local MusicRate = SL.Global.Stages.Stats[StageNum].MusicRate
				local mpn = GAMESTATE:GetMasterPlayerNumber()
				local StepsOrTrail = SL[ToEnumShortString(mpn)].Stages.Stats[StageNum].steps
				local bpms = StringifyDisplayBPMs(mpn, StepsOrTrail, MusicRate)
				if MusicRate ~= 1 then
					-- format a string like "150 - 300 bpm (1.5x Music Rate)"
					self:settext( ("%s bpm (%gx %s)"):format(bpms, MusicRate, THEME:GetString("OptionTitles", "MusicRate")) )
				else
					-- format a string like "100 - 200 bpm"
					self:settext( ("%s bpm"):format(bpms))
				end
			end
		end
	}
}

for player in ivalues(Players) do

	local playerStats, difficultyMeter, difficulty, stepartist, grade, score
	local TNSTypes = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }

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
		align1= left
		align2 = right
	end


	local PlayerStatsAF = Def.ActorFrame{
		DrawStageCommand=function(self)
			playerStats = SL[ToEnumShortString(player)].Stages.Stats[StageNum]

			if playerStats then
		 		difficultyMeter = playerStats.meter
		 		difficulty = playerStats.difficulty
		 		stepartist = playerStats.stepartist
		 		grade = playerStats.grade
		 		score = playerStats.score
			end
		end
	}

	--percent score
	PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("_wendy small")..{
		InitCommand=function(self) self:zoom(0.5):horizalign(align1):x(col1x):y(-24) end,
		DrawStageCommand=function(self)
			if playerStats and score then

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

	-- letter grade
	if SL.Global.GameMode ~= "StomperZ" then
		PlayerStatsAF[#PlayerStatsAF+1] = Def.ActorProxy{
			InitCommand=function(self)
				self:zoom(WideScale(0.275,0.3)):x( WideScale(194,250) * (player==PLAYER_1 and -1 or 1) ):y(-6)
			end,
			DrawStageCommand=function(self)
				if playerStats and grade then
					self:SetTarget( LetterGradesAF:GetChild(grade) ):visible(true)
				else
					self:visible(false)
				end
			end
		}
	end

	-- difficulty meter
	PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("_wendy small")..{
		InitCommand=function(self) self:zoom(0.4):horizalign(align1):x(col1x):y(4) end,
		DrawStageCommand=function(self)
			if playerStats and difficultyMeter then
				self:diffuse(DifficultyColor(difficulty)):settext(difficultyMeter)
			else
				self:settext("")
			end
		end
	}

	-- stepartist
	PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("Common Normal")..{
		InitCommand=function(self) self:zoom(0.65):horizalign(align1):x(col1x):y(28) end,
		DrawStageCommand=function(self)
			if playerStats and stepartist then
				self:settext(stepartist)
			else
				self:settext("")
			end
		end
	}

	-- numbers
	for i=1,#TNSTypes do

		PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("_wendy small")..{
			InitCommand=function(self)
				self:zoom(0.28):horizalign(align2):x(col2x):y(i*13 - 50)
					:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
			end,
			DrawStageCommand=function(self)
				if playerStats and playerStats.judgments then
					local val = playerStats.judgments[TNSTypes[i]]
					if val then self:settext(val) end

					local worst = SL.Global.Stages.Stats[StageNum].WorstTimingWindow
					self:visible( i <= worst or i==#TNSTypes )
				else
					self:settext("")
				end
			end
		}
	end

	t[#t+1] = PlayerStatsAF
end

return t
