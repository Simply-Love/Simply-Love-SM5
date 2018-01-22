local player = ...

local pane = Def.ActorFrame{
	Name="Pane3",
	InitCommand=function(self)
		self:visible(false)
	end
}


-- machineProfile contains the overall high scores per song
local machineProfile = PROFILEMAN:GetMachineProfile()

-- get the number of stages that were played
local StageNumber = GAMESTATE:IsCourseMode() and 1 or SL.Global.Stages.PlayedThisGame+1

local months = {}
for i=1,12 do
	months[#months+1] = THEME:GetString("ScreenNameEntryTraditional", "Month"..i)
end

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
-- +1 because GetMachineHighScoreIndex is 0-indexed
local index = pss:GetMachineHighScoreIndex() + 1

local highscoreList, highscores
local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)


local text = ""

highscoreList = (SongOrCourse and StepsOrTrail) and machineProfile:GetHighScoreList(SongOrCourse,StepsOrTrail)
highscores = highscoreList and highscoreList:GetHighScores()

if highscores then

	local MaxHighScores = PREFSMAN:GetPreference("MaxHighScoresPerListForMachine")

	-- this pane displays ten highscores from the MachineProfile
	local lower = 1
	local upper = 10

	if MaxHighScores > upper then
		if index > upper then
			lower = lower + (index-upper)
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
			Name="Row" .. s .. ToEnumShortString(player),
			InitCommand=function(self)
				self:zoom(0.8)
					:y(_screen.cy-62)
			end,
			OnCommand=function(self)
				--if this row represents the new highscore, highlight it
				if s == index then
					self:diffuseshift()
					self:effectperiod(4/3)
					self:effectcolor1( PlayerColor(player) )
					self:effectcolor2(Color.White)
				end
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
			InitCommand=cmd(horizalign,right; xy, 24, (s-(lower-1))*22 )
		}

		row[#row+1] = LoadFont("_miso")..{
			Text=date,
			InitCommand=cmd(horizalign,left; xy, 50, (s-(lower-1))*22 )
		}

		pane[#pane+1] = row
	end
end


return pane