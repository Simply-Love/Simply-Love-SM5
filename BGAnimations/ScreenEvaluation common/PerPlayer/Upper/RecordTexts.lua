if SL.Global.GameMode == "Casual" then return end

local player = ...
local pn = ToEnumShortString(player)
-- No records in DoNotJudgeMe mode.
if SL[pn].ActiveModifiers.DoNotJudgeMe then return end

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local HighScoreIndex = {
	Machine =  pss:GetMachineHighScoreIndex(),
	Personal = pss:GetPersonalHighScoreIndex()
}

-- ---------------------------------------------
-- GetMachineHighScoreIndex() will always return -1 in EventMode, so...

local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

local MaxMachineHighScores = PREFSMAN:GetPreference("MaxHighScoresPerListForMachine")
local MachineHighScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(SongOrCourse,StepsOrTrail):GetHighScores()

local EarnedMachineHighScoreInEventMode = function()
	-- if no DancePoints were earned, it's not a HighScore
	if pss:GetPercentDancePoints() <= 0.01 then return false end
	-- if DancePoints were earned, and no MachineHighScores exist, it's a HighScore
	if #MachineHighScores < 1 then return true end
	-- otherwise, check if this score is better than the worst current HighScore retrieved from MachineProfile
	return pss:GetHighScore():GetPercentDP() >= MachineHighScores[math.min(MaxMachineHighScores, #MachineHighScores)]:GetPercentDP()
end

-- FIXME: This approach is bizarre and heavily flawed + limited.
--        GetMachineHighScoreIndex() should really be patched in the SM5 engine.
local MachineHighScoreIndexInEventMode = function()
	local index = -1

	for i, highscore in ipairs(MachineHighScores) do
		local name
	 	if  pss:GetHighScore():GetScore() == highscore:GetScore()
		and pss:GetHighScore():GetDate()  == highscore:GetDate()
		and
		(
			name == PROFILEMAN:GetProfile(player):GetLastUsedHighScoreName()
			or
			(
				(#GAMESTATE:GetHumanPlayers()==1 and name=="EVNT")
				or (highscore:GetScore() ~= STATSMAN:GetPlayedStageStats(1):GetPlayerStageStats(OtherPlayer[player]):GetHighScore():GetScore())
			)
		)
		then
			index = i-1
			break
		end
	end

	return index
end

if GAMESTATE:IsEventMode() then
	HighScoreIndex.Machine = MachineHighScoreIndexInEventMode()
end

-- ---------------------------------------------

local EarnedMachineRecord  = GAMESTATE:IsEventMode() and EarnedMachineHighScoreInEventMode() or ((HighScoreIndex.Machine ~= -1) and pss:GetPercentDancePoints() >= 0.01)
local EarnedPersonalRecord = ( HighScoreIndex.Personal ~= -1 ) and pss:GetPercentDancePoints() >= 0.01

-- ---------------------------------------------

if EarnedMachineRecord or EarnedPersonalRecord then

	-- this player earned some record and the ability to enter a high score name
	-- we'll check for this flag later in ./BGAnimations/ScreenNameEntryTradtional underlay/default.lua
	SL[pn].HighScores.EnteringName = true

	local t = Def.ActorFrame{
		InitCommand=function(self) self:zoom(0.225) end,
		OnCommand=function(self)
			self:x( player == PLAYER_1 and -45 or 95 )
			self:y( 54 )
		end
	}

	if HighScoreIndex.Machine+1 > 0 then
		t[#t+1] = LoadFont("Common Bold")..{
			Text=(ScreenString("MachineRecord")):format(HighScoreIndex.Machine+1),
			InitCommand=function(self) self:xy(-110,-18):diffuse(PlayerColor(player)) end,
		}
	end

	if HighScoreIndex.Personal+1 > 0 then
		t[#t+1] = LoadFont("Common Bold")..{
			Text=(ScreenString("PersonalRecord")):format(HighScoreIndex.Personal+1),
			InitCommand=function(self) self:xy(-110,24):diffuse(PlayerColor(player)) end,
		}
	end

	return t
end
