if SL.Global.GameMode == "Casual" then return end

local player = ...
local pn = ToEnumShortString(player)

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

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
	return pss:GetHighScore():GetScore() >= MachineHighScores[math.min(MaxMachineHighScores, #MachineHighScores)]:GetScore()
end

-- ---------------------------------------------

local HighScoreIndex = {
	Machine =  pss:GetMachineHighScoreIndex(),
	Personal = pss:GetPersonalHighScoreIndex()
}

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
		t[#t+1] = LoadFont("_wendy small")..{
			Text=string.format("Machine Record %i", HighScoreIndex.Machine+1),
			InitCommand=function(self) self:xy(-110,-18):diffuse(PlayerColor(player)) end,
		}
	end

	if HighScoreIndex.Personal+1 > 0 then
		t[#t+1] = LoadFont("_wendy small")..{
			Text=string.format("Personal Record %i", HighScoreIndex.Personal+1),
			InitCommand=function(self) self:xy(-110,24):diffuse(PlayerColor(player)) end,
		}
	end

	return t
end