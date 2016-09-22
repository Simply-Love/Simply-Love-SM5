local position_on_screen = ...

local Players = GAMESTATE:GetHumanPlayers()
local song, StageNum, DecentsWayOffs

local colors = {
	Competitive = {
		color("#21CCE8"),	-- blue
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#5b2b8e"),	-- purple
		color("#c9855e"),	-- peach?
		color("#ff0000")	-- red
	},
	ECFA = {
		color("#21CCE8"),	-- blue
		color("#ffffff"),	-- white
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#5b2b8e"),	-- purple
		color("#ff0000")	-- red
	},
	StomperZ = {
		color("#FFFFFF"),	-- white
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#21CCE8"),	-- blue
		color("#000000"),	-- black
		color("#ff0000")	-- red
	}
}

local banner_directory = ThemePrefs.Get("VisualTheme")
local t = Def.ActorFrame{
	DrawPageCommand=function(self, params)
		self:sleep(position_on_screen*0.05):linear(0.15):diffusealpha(0)

		StageNum = ((params.Page-1)*4) + position_on_screen
		local stage = SL.Global.Stages.Stats[StageNum]
		song = stage ~= nil and stage.song or nil

		self:queuecommand("DrawStage")
	end,
	DrawStageCommand=function(self)
		if song == nil then
			self:visible(false)
		else
			self:queuecommand("Show"):visible(true)
		end
	end,

	-- black quad
	Def.Quad{
		InitCommand=function(self) self:zoomto( _screen.w-40, 94):diffuse(0,0,0,0.5):y(-6) end
	},

	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/".. banner_directory .."/banner"..SL.Global.ActiveColorIndex.." (doubleres).png"))..{
		InitCommand=cmd(y,-6; zoom, 0.333)
	},

	-- the banner, if there is one
	Def.Banner{
		Name="Banner",
		DrawStageCommand=function(self)
			self:y(-6)

			if song then
				self:LoadFromSong(song)
					:setsize(418,164):zoom(0.333)
			end
		end
	},

	-- the title of the song
	LoadFont("_miso")..{
		InitCommand=cmd(zoom,0.8; y,-40; maxwidth, 350),
		DrawStageCommand=function(self)
			if song then
				self:settext(song:GetDisplayFullTitle())
			end
		end
	},

	-- the BPM(s) of the song
	LoadFont("_miso")..{
		InitCommand=cmd(zoom,0.6; y,30; maxwidth, 350),
		DrawStageCommand=function(self)
			if song then
				local text = ""
				local BPMs = song:GetDisplayBpms()
				local MusicRate = SL.Global.Stages.Stats[StageNum].MusicRate

				if BPMs then
					if BPMs[1] == BPMs[2] then
						text = text .. round(BPMs[1] * MusicRate) .. " bpm"
					else
						text = text .. round(BPMs[1] * MusicRate) .. " - " .. round(BPMs[2] * MusicRate) .. " bpm"
					end
				end

				if MusicRate ~= 1 then
					text = text .. " (" .. tostring(MusicRate).."x Music Rate)"
				end

				self:settext(text)
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
		 		difficultyMeter = playerStats.difficultyMeter
		 		difficulty = playerStats.difficulty
		 		stepartist = playerStats.stepartist
		 		grade = playerStats.grade
		 		score = playerStats.score
			end
		end
	}

	--percent score
	PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("_wendy small")..{
		InitCommand=cmd(zoom,0.5; horizalign, align1; x,col1x; y,-24),
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

	-- difficulty meter
	PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("_wendy small")..{
		InitCommand=cmd(zoom,0.4; horizalign, align1; x,col1x; y,4),
		DrawStageCommand=function(self)
			if playerStats and difficultyMeter then
				if difficulty then
					local y_offset = GetYOffsetByDifficulty(difficulty)
					self:diffuse(DifficultyIndexColor(y_offset))
				end

				self:settext(difficultyMeter)
			else
				self:settext("")
			end
		end
	}

	-- stepartist
	PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("_miso")..{
		InitCommand=cmd(zoom,0.65; horizalign, align1; x,col1x; y,28),
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
			InitCommand=cmd(zoom,0.28; horizalign, align2; x,col2x; y,i*13 - 50),
			DrawStageCommand=function(self)
				if playerStats and playerStats.judgments then
					local val = playerStats.judgments[TNSTypes[i]]
					if val then self:settext(val) end
					local DecentsWayOffs = SL.Global.Stages.Stats[StageNum].DecentsWayOffs

					if SL.Global.GameMode == "StomperZ" then
						self:diffuse( colors.StomperZ[i] )
					elseif SL.Global.GameMode == "ECFA" then
						self:diffuse( colors.ECFA[i] )
					else
						self:diffuse( colors.Competitive[i] )
					end

					if DecentsWayOffs == "Decents Only" and i == 5 then
						self:visible(false)
					elseif DecentsWayOffs == "Off" and (i == 4 or i == 5) then
						self:visible(false)
					end

				else
					self:settext("")
				end
			end
		}
	end

	t[#t+1] = PlayerStatsAF
end

return t