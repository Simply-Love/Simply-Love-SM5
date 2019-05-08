local player = ...

local pane = Def.ActorFrame{
	Name="Pane3",
	InitCommand=function(self)
		self:visible(false)
	end
}


-- machineProfile contains the overall high scores per song
local machineProfile = PROFILEMAN:GetMachineProfile()

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

local row_height = 22

highscoreList = (SongOrCourse and StepsOrTrail) and machineProfile:GetHighScoreList(SongOrCourse,StepsOrTrail)
highscores = highscoreList and highscoreList:GetHighScores()

if highscores then

	local MaxHighScores = PREFSMAN:GetPreference("MaxHighScoresPerListForMachine")

	-- this pane displays ten highscores from the MachineProfile
	local lower = 1
	local upper = 10

	if MaxHighScores > upper and index > upper then
		lower = lower + (index-upper)
		upper = index
	end

	-- calling GetMachineHighScoreIndex() on a PlayerStageStats object in EventMode always returns -1
	-- so a wildly roundabout check is needed
	-- This won't return any false positives, but will return false negatives in extreme circumstances,
	-- resulting in no HighScore rows lighting up.  Oh well.
	-- (if we're in EventMode and both players earn a HighScore and they are both tied in score and neither is using a profile)
	local HighScoreIndexInEventMode = function(s)
		if GAMESTATE:IsEventMode()
		and highscores[s] ~= nil
		and pss:GetHighScore():GetScore() == highscores[s]:GetScore()
		and pss:GetHighScore():GetDate() == highscores[s]:GetDate()
		and (name==PROFILEMAN:GetProfile(player):GetLastUsedHighScoreName()
			or ((#GAMESTATE:GetHumanPlayers()==1 and name=="EVNT") or (highscores[s]:GetScore() ~= STATSMAN:GetCurStageStats():GetPlayerStageStats(OtherPlayer[player]):GetHighScore():GetScore()))
		)
		then return true end

		return false
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
				if (s == index) or HighScoreIndexInEventMode(s) then
					self:diffuseshift()
					self:effectperiod(4/3)
					self:effectcolor1( PlayerColor(player) )
					self:effectcolor2(Color.White)
				end
			end
		}

		row[#row+1] = LoadFont("_miso")..{
			Text=s..". ",
			InitCommand=cmd(horizalign,right; xy, -120, (s-(lower-1))*row_height )
		}

		row[#row+1] = LoadFont("_miso")..{
			Text=name,
			InitCommand=cmd(horizalign,left; xy, -110, (s-(lower-1))*row_height )
		}

		row[#row+1] = LoadFont("_miso")..{
			Text=score,
			InitCommand=cmd(horizalign,right; xy, 24, (s-(lower-1))*row_height )
		}

		row[#row+1] = LoadFont("_miso")..{
			Text=date,
			InitCommand=cmd(horizalign,left; xy, 50, (s-(lower-1))*row_height )
		}

		pane[#pane+1] = row
	end
end


return pane