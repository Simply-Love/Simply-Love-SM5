local af = Def.ActorFrame{}

-- ---------------------------------------------
-- setup involving optional arguments that might have been passed in via a key/value table

local args = ...

-- a player object, indexed by "Player"; default to GAMESTATE's MasterPlayer if none is provided
local player = args.Player or GAMESTATE:GetMasterPlayerNumber()
if not player then return af end
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
-- the number of HighScores to retrieve, indexed by "NumHighScores"; default to 5 if none is provided
local NumHighScores = args.NumHighScores or 5

-- optionally provide a player profile; if none is provided, default to retrieving HighScores from
-- the MachineProfile for this stepchart; this is typically what we want
local profile = args.Profile or PROFILEMAN:GetMachineProfile()

-- optionally provide Song/Course and Steps/Trail objects; if none are provided
-- default to using whatever GAMESTATE currently thinks they are
local SongOrCourse = args.SongOrCourse or (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong())
local StepsOrTrail = args.StepsOrTrail or ((args.RoundsAgo==nil or args.RoundsAgo==1) and (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)))
if not (SongOrCourse and StepsOrTrail) then return af end

local Font = args.Font or "Common Normal"
local row_height = 22 -- sigh

-- ---------------------------------------------
-- setup that can occur now that the arguments have been handled

local experimentHighScores = GetScores(player,GetHash(player))
--add our current song to the list of scores and mark it so we know which one it is
local currentScore = {current=true,score=pss:GetPercentDancePoints(),dateTime=GetCurrentDateTime(),rate=SL.Global.ActiveModifiers.MusicRate,grade=pss:GetFailed() and "Failed" or ""}
if not experimentHighScores then experimentHighScores = {} experimentHighScores[1]= currentScore
else
    table.insert(experimentHighScores,currentScore)
    table.sort(experimentHighScores,function(k1,k2) return tonumber(k1.score) > tonumber(k2.score) end)
end
-- don't attempt to retrieve more HighScores than are actually saved to the desired Profile (machine or player)
local MaxHighScores = PREFSMAN:GetPreference("MaxHighScoresPerListFor" .. (profile==PROFILEMAN:GetMachineProfile() and "Machine" or "Player"))
NumHighScores = math.min(NumHighScores, MaxHighScores)

local months = {}
for i=1,12 do
	table.insert(months, THEME:GetString("HighScoreList", "Month"..i))
end

-- ---------------------------------------------
-- lower and upper will be used as loop start and end points
-- we'll loop through the the list of highscores from lower to upper indices
-- initialize them to 1 and NumHighScores now; they may change later
local lower = 1
local upper = NumHighScores

-- If the we're on Evaluation or EvaluationSummary, we might want to compare the player's recent
-- performance to the overall list of highscores.
-- ---------------------------------------------

for i=lower,upper do

	local row_index = i-lower
	local score, rate, date
	local numbers = {}
    if experimentHighScores[i] then
        score = FormatPercentScore(experimentHighScores[i].score)
        if experimentHighScores[i].grade == 'Failed' then score = score.." (F)" end
		rate = experimentHighScores[i].rate
		date = experimentHighScores[i].dateTime

		-- make the date look nice
		for number in string.gmatch(date, "%d+") do
			numbers[#numbers+1] = number
	    end
		date = months[tonumber(numbers[2])] .. " " ..  numbers[3] ..  ", " .. numbers[1]
	else
		rate	= "----"
		score	= "------"
		date	= "----------"
	end

	local row = Def.ActorFrame{}

	-- if we wanted to compare a player's performance against the list of highscores we are returning
	if args.RoundsAgo then
		-- then specify and OnCommand that will check if this row represents the player's performance for this round
		row.OnCommand=function(self)
			if experimentHighScores[i] and experimentHighScores[i].current then
				-- apply a diffuseshift effect to draw attentiont to this row
				self:diffuseshift():effectperiod(4/3)
				self:effectcolor1( PlayerColor(player) )
				self:effectcolor2( Color.White )
			end
		end
	end

	row[#row+1] = LoadFont(Font)..{
		Text=i..". ",
		InitCommand=function(self) self:horizalign(right):xy(-120, row_index*row_height) end
	}

	row[#row+1] = LoadFont(Font)..{
		Text=score,
		InitCommand=function(self) self:horizalign(left):xy(-110, row_index*row_height) end
	}

	row[#row+1] = LoadFont(Font)..{
		Text=rate,
		InitCommand=function(self) self:horizalign(left):xy(-24, row_index*row_height) end
	}

	row[#row+1] = LoadFont(Font)..{
		Text=date,
		InitCommand=function(self) self:horizalign(left):xy(50, row_index*row_height) end
	}

	af[#af+1] = row

	row_index = row_index + 1
end


return af