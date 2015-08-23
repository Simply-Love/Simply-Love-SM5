local Player = ...

-- machineProfile contains the overall high scores per song
local machineProfile = PROFILEMAN:GetMachineProfile()

-- get the number of stages that were played
local numStages = GAMESTATE:IsCourseMode() and 1 or SL.Global.Stages.PlayedThisGame
local durationPerSong = 4

local months = {}
for i=1,12 do
	months[#months+1] = THEME:GetString("ScreenNameEntryActual", "Month"..i)
end


local t = Def.ActorFrame{}
local currentStage = 1

for i=numStages,1,-1 do

	local stageStats = STATSMAN:GetPlayedStageStats(i)
	local playerStageStats = stageStats:GetPlayerStageStats(Player)

	local highscoreList, highscores, StepsOrTrail
	local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or SL.Global.Stages.Stats[currentStage].song
	local stats = SL[ToEnumShortString(Player)].Stages.Stats[currentStage]

	if GAMESTATE:IsCourseMode() then
		StepsOrTrail = GAMESTATE:GetCurrentTrail(Player)
	else
		--stats might exist for one player but not the other due to latejoin
		if stats then StepsOrTrail = stats.steps end
	end

	currentStage = currentStage + 1

	-- +1 because GetMachineHighScoreIndex is 0-indexed
	local index = playerStageStats:GetMachineHighScoreIndex() + 1
	local text = ""

	if SongOrCourse and StepsOrTrail then
		highscoreList = machineProfile:GetHighScoreList(SongOrCourse,StepsOrTrail)
	end

	if highscoreList then
		highscores = highscoreList:GetHighScores()
	end

	if highscores then

		local MaxHighScores = PREFSMAN:GetPreference("MaxHighScoresPerListForMachine")

		-- this screen can display up to five highscores at once
		-- below, we'll loop from (lower to higher) to only display the five scores that are relevant
		-- if the new highscore is first or second place record, show 1, 2, 3, 4, 5
		-- if the new highscore is sixth, show 2, 3, 4, 5, 6
		-- if the new highscore is ninth, show 5, 6, 7, 8, 9
		local lower = 1
		local upper = 5


		if MaxHighScores > 5 then
			-- if the new highscore is 1st or 2nd place
			if index < 3 then
				lower = 1
				upper = 5

			-- elseif the new highscore is second to last
			elseif index == MaxHighScores-1 then
				lower = MaxHighScores - 5
				upper = lower + 4

			-- elseif the new highscore the last allowed by MaxHighScoresPerListForMachine
			elseif index == MaxHighScores then
				lower = MaxHighScores - 4
				upper = MaxHighScores

			-- else the new highscore is somewhere in the middle
			elseif index > 4 and index < MaxHighScores -1 then
				lower = index - 4
				upper = index
			end
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
				Name="HighScore" .. i .. "Row" .. s .. ToEnumShortString(Player),
				InitCommand=function(self)
					self:diffusealpha(0)
					self:zoom(0.95)
					if Player == PLAYER_1 then
						self:x(_screen.cx-160)
					elseif Player == PLAYER_2 then
						self:x(_screen.cx+160)
					end
					self:y(_screen.cy+60)
				end,
				OnCommand=function(self)
					self:sleep(durationPerSong * (math.abs(i-numStages)) )
					self:queuecommand("Display")

					--if this row represents the new highscore, highlight it
					if s == index then
						self:diffuseshift()
						self:effectperiod(durationPerSong/3)
						self:effectcolor1(GetHexColor((SL.Global.ActiveColorIndex - 4)%12 + 1))
						self:effectcolor2(Color.White)
					end
				end,
				DisplayCommand=function(self)
					self:diffusealpha(1)
					self:sleep(durationPerSong)
					self:diffusealpha(0)
					self:queuecommand("Wait")
				end,
				WaitCommand=function(self)
					self:sleep(durationPerSong * (numStages-1))
					self:queuecommand("Display")
				end
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