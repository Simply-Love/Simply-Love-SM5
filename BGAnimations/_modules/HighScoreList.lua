local af = Def.ActorFrame{Name="HighScoreList"}

-- ---------------------------------------------
-- setup involving optional arguments that might have been passed in via a key/value table

local args = ...

-- a player object, indexed by "Player"; default to GAMESTATE's MasterPlayer if none is provided
local player = args.Player or GAMESTATE:GetMasterPlayerNumber()
if not player then return af end

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

local Font = args.Font or ThemePrefs.Get("ThemeFont") .. " Normal"
local row_height = args.RowHeight or 22

-- ---------------------------------------------
-- setup that can occur now that the arguments have been handled

local HighScoreList = profile:GetHighScoreList(SongOrCourse,StepsOrTrail)
local HighScores = HighScoreList:GetHighScores()
if not HighScores then return af end

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
-- performance to the overall list of highscores.  if so, highscoreindex will (might) contain the index
-- of the recent performance in the overall list. (This gets complicated in EventMode, but we'll Try Our Best™.)
local highscoreindex

-- ---------------------------------------------
-- providing a RoundsAgo argument signals that we wish to compare a player performance against
-- the list of HighScores being retrieved; for example, on ScreenEvaluation or ScreenEvaluationSummary

-- for the sake of STATSMAN:GetPlayedStageStats(), RoundsAgo should be 1 for the current round, 2 for the previous round, etc.
-- if no RoundsAgo argument is provided, leave it as nil and no comparison will be attempted

if args.RoundsAgo then
	local pss = STATSMAN:GetPlayedStageStats(args.RoundsAgo):GetPlayerStageStats(player)
	highscoreindex = (profile==PROFILEMAN:GetMachineProfile() and pss:GetMachineHighScoreIndex() or pss:GetPersonalHighScoreIndex())
	-- +1 because HighScoreIndex values are 0-indexed
	highscoreindex = highscoreindex + 1

	-- HighScoreIndex values from GetMachineHighScoreIndex and GetPersonalHighScoreIndex will always be -1
	-- in EventMode. (Why?)  We can still use some stupidly convoluted checks to try to find it, regardless.
	--
	-- This won't return any false positives, but will return false negatives in extreme circumstances,
	-- resulting in no HighScore rows lighting up.  Oh well.  (That is, if we're in EventMode and both
	-- players earn a HighScore and they are both tied in score and neither is using a profile.)

	if highscoreindex <= 0 then
		for i, highscore in ipairs(HighScores) do
			local name
		 	if  pss:GetHighScore():GetScore() == highscore:GetScore()
			and pss:GetHighScore():GetDate()  == highscore:GetDate()
			and
			(
				name == PROFILEMAN:GetProfile(player):GetLastUsedHighScoreName()
				or
				(
					(#GAMESTATE:GetHumanPlayers()==1 and name=="EVNT")
					or (highscore:GetScore() ~= STATSMAN:GetPlayedStageStats(args.RoundsAgo):GetPlayerStageStats(OtherPlayer[player]):GetHighScore():GetScore())
				)
			)
			then
				highscoreindex = i
				break
			end
		end
	end

	-- if a RoundsAgo argument is not provided, we'll just return the best highscores
	-- available starting at 1. For example, highscores [1,2,3,4,5]
	-- if a RoundsAgo argument *is* provided, we may need to shift the start and end points
	-- to retrieve, for example, highscores [3,4,5,6,7]
	if highscoreindex > upper then
		lower = lower + highscoreindex - upper
		upper = highscoreindex
	end
end

-- ---------------------------------------------

for i=lower,upper do

	local row_index = i-lower
	local score, name, date
	local numbers = {}

	if HighScores[i] and not args.HideScores then
		score = FormatPercentScore(HighScores[i]:GetPercentDP())
		name = HighScores[i]:GetName()
		date = HighScores[i]:GetDate()

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

	local row = Def.ActorFrame{Name="HighScoreEntry"..(row_index+1)}

	-- if we wanted to compare a player's performance against the list of highscores we are returning
	if args.RoundsAgo then
		-- then specify and OnCommand that will check if this row represents the player's performance for this round
		row.OnCommand=function(self)
			if i == highscoreindex then
				-- apply a diffuseshift effect to draw attentiont to this row
				self:diffuseshift():effectperiod(4/3)
				self:effectcolor1( PlayerColor(player) )
				self:effectcolor2( Color.White )
			end
		end
	end

	row[#row+1] = LoadFont(Font)..{
		Name="Rank",
		Text=i..". ",
		InitCommand=function(self) self:horizalign(right):xy(-130, row_index*row_height):maxwidth(55) end,
	}

	row[#row+1] = LoadFont(Font)..{
		Name="Name",
		Text=name,
		InitCommand=function(self) self:horizalign(left):xy(-120, row_index*row_height):maxwidth(130) end,
	}

	row[#row+1] = LoadFont(Font)..{
		Name="Score",
		Text=score,
		InitCommand=function(self) self:horizalign(left):xy(16, row_index*row_height) end,
	}

	row[#row+1] = LoadFont(Font)..{
		Name="Date",
		Text=date,
		InitCommand=function(self) self:horizalign(left):xy(72, row_index*row_height) end,
	}

	af[#af+1] = row

	row_index = row_index + 1
end


return af
