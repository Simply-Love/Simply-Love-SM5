local P1 = GAMESTATE:IsHumanPlayer(PLAYER_1)
local P2 = GAMESTATE:IsHumanPlayer(PLAYER_2)

local p1profile = PROFILEMAN:GetProfile(0)
local p2profile = PROFILEMAN:GetProfile(1)

local P1numRollsHit = p1profile:GetTotalRolls()
local P1numStepsHit = p1profile:GetTotalTapsAndHolds()
local P1numTotalSteps = ""

local P2numRollsHit = p2profile:GetTotalRolls()
local P2numStepsHit = p2profile:GetTotalTapsAndHolds()
local P2numTotalSteps = ""

if P1numRollsHit == 0 then
	P1numTotalSteps = P1numStepsHit
else
	P1numTotalSteps = P1numRollsHit + P1numStepsHit
end

if P2numRollsHit == 0 then
	P2numTotalSteps = P2numStepsHit
else
	P2numTotalSteps = P2numRollsHit + P2numStepsHit
end

Player1StartingSteps = P1numTotalSteps
Player2StartingSteps = P2numTotalSteps



TotalBPM = 0
P1REALStepsPerSet = 0
P2REALStepsPerSet = 0

return Def.ActorFrame { }