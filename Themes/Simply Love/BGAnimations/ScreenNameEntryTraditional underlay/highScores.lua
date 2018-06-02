local player = ...

-- machineProfile contains the overall high scores per song
local machineProfile = PROFILEMAN:GetMachineProfile()

-- get the number of stages that were played
local NumStages = SL.Global.Stages.PlayedThisGame
local durationPerSong = 4

local months = {}
for i=1,12 do
	months[#months+1] = ScreenString("Month"..i)
end

local t = Def.ActorFrame{}

local CurrentStage = 1
for i=NumStages,1,-1 do

	local stageStats = STATSMAN:GetPlayedStageStats(i)
	local pss = stageStats:GetPlayerStageStats(player)
	-- +1 because GetMachineHighScoreIndex is 0-indexed
	local index = pss:GetMachineHighScoreIndex() + 1

	local highscoreList, highscores, StepsOrTrail
	local SongOrCourse = SL.Global.Stages.Stats[CurrentStage].song
	local stats = SL[ToEnumShortString(player)].Stages.Stats[CurrentStage]

	--stats might exist for one player but not the other due to latejoin
	if stats then StepsOrTrail = stats.steps end

	local text = ""

	if SongOrCourse and StepsOrTrail then
		highscoreList = machineProfile:GetHighScoreList(SongOrCourse,StepsOrTrail)
	end

	if highscoreList then
		highscores = highscoreList:GetHighScores()
	end
	CurrentStage = CurrentStage+1

	if highscores then

		local MaxHighScores = PREFSMAN:GetPreference("MaxHighScoresPerListForMachine")

		-- this screen can display up to five highscores at once
		-- below, we'll loop from (lower to higher) to only display the five scores that are relevant
		-- if the new highscore is first or second place record, show 1, 2, 3, 4, 5
		-- if the new highscore is sixth, show 2, 3, 4, 5, 6
		-- if the new highscore is ninth, show 5, 6, 7, 8, 9
		local lower = 1
		local upper = 5

		if MaxHighScores > upper and index > upper then
			lower = lower + (index-upper)
			upper = index
		end

		for s=lower,upper do

			local score, name, date
			local numbers = {}

			if highscores[s] then
				score = FormatPercentScore(highscores[s]:GetPercentDP())
				name = highscores[s]:GetName()
				date = highscores[s]:GetDate()

				-- make the date look nice
				for number in string.gmatch(date, "%d+") do
					numbers[#numbers+1] = number
			    end
				date = months[tonumber(numbers[2])] .. " " ..  numbers[3] ..  ", " .. numbers[1]
			else
				name	= "----"
				score	= "------"
				date	= "----------"
			end

			local row = Def.ActorFrame{
				Name="HighScore" .. i .. "Row" .. s .. ToEnumShortString(player),
				InitCommand=function(self)
					self:zoom(0.95)
						:x( (player == PLAYER_1 and _screen.cx-160) or (_screen.cx+160))
						:y(_screen.cy+60)
					--if this row represents the new highscore, highlight it
					if (PREFSMAN:GetPreference("EventMode") and highscores[s] and pss:GetHighScore():GetPercentDP() == highscores[s]:GetPercentDP() )
					or s == index then
						self:diffuseshift():effectperiod(durationPerSong/3)
							:effectcolor1( PlayerColor(player) )
							:effectcolor2( Color.White )
					end
				end,
				OnCommand=function(self)
					self:visible(false)
						:sleep(durationPerSong * math.abs(i-NumStages)):queuecommand("Display")
				end,
				WaitCommand=function(self)
					self:visible(false)
					self:sleep(durationPerSong * (NumStages-1)):queuecommand("Display")
				end,
				DisplayCommand=function(self)
					self:visible(true)
					self:sleep(durationPerSong):queuecommand("Wait")
				end,
			}

			row[#row+1] = LoadFont("_miso")..{
				Text=s..". ",
				InitCommand=cmd(horizalign,right; xy, -120, (s-(lower-1))*22 )
			}

			row[#row+1] = LoadFont("_miso")..{
				Text=name,
				InitCommand=cmd(horizalign,left; xy, -110, (s-(lower-1))*22 )
			}

			row[#row+1] = LoadFont("_miso")..{
				Text=score,
				InitCommand=cmd(horizalign,left; xy, -24, (s-(lower-1))*22 )
			}

			row[#row+1] = LoadFont("_miso")..{
				Text=date,
				InitCommand=cmd(horizalign,left; xy, 50, (s-(lower-1))*22 )
			}

			t[#t+1] = row
		end
	end
end

return t