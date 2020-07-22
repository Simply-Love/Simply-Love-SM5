--- THIS IS JUST TO GET THE STEPS PER SET TO WORK IF A SECOND PERSON JOINS IN LATE UGH WOW ---

local P1 = GAMESTATE:IsHumanPlayer(PLAYER_1)
local P2 = GAMESTATE:IsHumanPlayer(PLAYER_2)

local p1profile = PROFILEMAN:GetProfile(0)
local p2profile = PROFILEMAN:GetProfile(1)

local P1numSongsPlayed = p1profile:GetNumTotalSongsPlayed()
local P1numRollsHit = p1profile:GetTotalRolls()
local P1numStepsHit = p1profile:GetTotalTapsAndHolds()
local P1numTotalSteps = ""

local P2numSongsPlayed = p2profile:GetNumTotalSongsPlayed()
local P2numRollsHit = p2profile:GetTotalRolls()
local P2numStepsHit = p2profile:GetTotalTapsAndHolds()
local P2numTotalSteps = ""

-- Stepmania doesn't have a way to count steps, holds, and rolls at once so we have to do it manually
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

if P1 and P1SongsInSet == 0 then
	Player1StartingSteps = P1numTotalSteps
end

if P2 and P2SongsInSet == 0 then
	Player2StartingSteps = P2numTotalSteps
end


return Def.ActorFrame { }