local stageNum = ...

local Players = GAMESTATE:GetHumanPlayers()
local song = SL.Global.Stages.Stats[stageNum].song

local colors = {
	Competitive = {
		color("#21CCE8"),	-- blue
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#5b2b8e"),	-- purple
		color("#c9855e"),	-- peach?
		color("#ff0000")	--red
	},
	StomperZ = {
		color("#21CCE8"),	-- blue
		color("#FFFFFF"),	-- white
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#9e00f7"),	-- purple
		color("#ff0000")	-- red
	}
}

--
local t = Def.ActorFrame{

	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/banner"..SL.Global.ActiveColorIndex.." (doubleres).png"))..{
		InitCommand=cmd(y,-6; zoom, 0.333)
	},

	-- the banner, if there is one
	Def.Banner{
		Name="Banner",
		InitCommand=function(self)
			self:y(-6)

			if song then
				self:LoadFromSong(song)
				self:setsize(418,164)
				self:zoom(0.333)
			end
		end
	},

	-- the title of the song
	LoadFont("_miso")..{
		InitCommand=cmd(zoom,0.8; y,-40; maxwidth, 350),
		OnCommand=function(self)
			if song then
				self:settext(song:GetDisplayFullTitle())
			end
		end
	},

	-- the BPM(s) of the song
	LoadFont("_miso")..{
		InitCommand=cmd(zoom,0.6; y,30; maxwidth, 350),
		OnCommand=function(self)
			if song then
				local text = ""
				local BPMs = song:GetDisplayBpms()
				local MusicRate = SL.Global.Stages.MusicRate[stageNum]

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


for pn in ivalues(Players) do

	local playerStats = SL[ToEnumShortString(pn)].Stages.Stats[stageNum]

	if playerStats then

		local difficultyMeter = playerStats.difficultyMeter
		local difficulty = playerStats.difficulty
		local stepartist = playerStats.stepartist
		local grade = playerStats.grade
		local score = playerStats.score

		local TNSTypes = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }

		-- variables for positioning and horizalign, dependent on playernumber
		local col1x, col2x, gradex, align1, align2

		if pn == PLAYER_1 then
			col1x =  -90
			col2x =  -_screen.w/2.5
			gradex = -_screen.w/3.33
			align1 = right
			align2 = left
		elseif pn == PLAYER_2 then
			col1x = 90
			col2x = _screen.w/2.5
			gradex = _screen.w/3.33
			align1= left
			align2 = right
		end

		--percent score
		t[#t+1] = LoadFont("_wendy small")..{
			InitCommand=cmd(zoom,0.5; horizalign, align1; x,col1x; y,-24),
			OnCommand=function(self)
				if score then

					-- trim off the % symbol
					local score = string.sub(FormatPercentScore(score),1,-2)

					-- If the score is < 10.00% there will be leading whitespace, like " 9.45"
					-- trim that too, so PLAYER_2's scores align properly.
					score = string.gsub(score, " ", "")
					self:settext(score)
				end
			end
		}

		-- difficulty meter
		t[#t+1] = LoadFont("_wendy small")..{
			InitCommand=cmd(zoom,0.4; horizalign, align1; x,col1x; y,4),
			OnCommand=function(self)
				if difficultyMeter then
					if difficulty then
						local y_offset = GetYOffsetByDifficulty(difficulty)
						self:diffuse(DifficultyIndexColor(y_offset))
					end

					self:settext(difficultyMeter)
				end
			end
		}

		-- stepartist
		t[#t+1] = LoadFont("_miso")..{
			InitCommand=cmd(zoom,0.65; horizalign, align1; x,col1x; y,28),
			OnCommand=function(self)
				if stepartist then
					self:settext(stepartist)
				end
			end
		}

		if SL.Global.GameMode ~= "StomperZ" then
			-- letter grade
			t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"), STATSMAN:GetPlayedStageStats(STATSMAN:GetStagesPlayed()-stageNum+1):GetPlayerStageStats(pn))..{
				OnCommand=cmd(zoom,0.2; x, gradex)
			}
		end

		-- numbers
		for i=1,#TNSTypes do

			t[#t+1] = LoadFont("_wendy small")..{
				InitCommand=cmd(zoom,0.28; horizalign, align2; x,col2x; y,i*13 - 50),
				OnCommand=function(self)

					local val = playerStats.judgments[TNSTypes[i]]
					if val then self:settext(val) end

					if SL.Global.GameMode == "StomperZ" then
						self:diffuse( colors.StomperZ[i] )
					else
						self:diffuse( colors.Competitive[i] )
					end
				end
			}
		end
	end
end

return t