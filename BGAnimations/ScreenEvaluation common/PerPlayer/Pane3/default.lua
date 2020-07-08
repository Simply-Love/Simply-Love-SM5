-- Pane3 displays a list of HighScores for the stepchart that was played.

local player = ...

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local HighScoreIndex = {
	Machine =  pss:GetMachineHighScoreIndex(),
	Personal = pss:GetPersonalHighScoreIndex()
}
local NumHighScores = math.min(10, PREFSMAN:GetPreference("MaxHighScoresPerListForMachine"))
local EarnedMachineRecord = HighScoreIndex.Machine  >= 0
local EarnedTop2Personal  = (HighScoreIndex.Personal >= 0 and HighScoreIndex.Personal < 2)

-- -----------------------------------------------------------------------

local pane = Def.ActorFrame{
	Name="Pane3",
	InitCommand=function(self)
		self:visible(false)
		self:y(_screen.cy - 62):zoom(0.8)
	end
}

-- row_height of a HighScore line
local rh
local args = { Player=player, RoundsAgo=1, RowHeight=rh}


-- Novice players frequently improve their own score while struggling to
-- break into an overall leaderboard.  The lack of *visible* leaderboard
-- progress can be frustrating/demoralizing, so let's do what we can to
-- alleviate that.
--
-- If this score is not high enough to be a machine record, but it *is*
-- good enough to be a top-2 personal record, show two HighScore lists:
-- 1-8 machine HighScores, then 1-2 personal HighScores
--
-- If the player isn't using a profile (local or USB), there won't be any
-- personal HighScores to compare against.
--
-- Also, this 8+2 shouldn't show up on privately owned machines where only
-- one person plays, which is a common scenario in 2020.
--
-- This idea of showing both machine and personal HighScores to help new players
-- track progress is based on my experiences maintaining a heavily-used
-- public SM5 machine for several years while away at school.


if (not EarnedMachineRecord and EarnedTop2Personal) then

	-- less line spacing between HighScore rows to fit the horizontal line
	rh = 20.25
	args.RowHeight = rh

	-- top 7 machine HighScores
	args.NumHighScores = 8
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)

	-- horizontal line visually separating machine HighScores from player HighScores
	pane[#pane+1] = Def.Quad{ InitCommand=function(self) self:zoomto(100, 1):y(rh*9):diffuse(1,1,1,0.33) end }

	-- top 2 player HighScores
	args.NumHighScores = 2
	args.Profile = PROFILEMAN:GetProfile(player)
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)..{
		InitCommand=function(self) self:y(rh*9) end
	}


-- the player did not meet the conditions to show the 8+2 HighScores
-- just show top 10 machine HighScores
else

	-- more breathing room between HighScore rows
	rh = 22
	args.RowHeight = rh

	-- top 10 machine HighScores
	args.NumHighScores = 10
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)
end

return pane