local P1 = GAMESTATE:IsHumanPlayer(PLAYER_1)
local P2 = GAMESTATE:IsHumanPlayer(PLAYER_2)
local SongsInSet = SL.Global.Stages.PlayedThisGame
local name1 = PROFILEMAN:GetPlayerName(0)
local name2 = PROFILEMAN:GetPlayerName(1)
local Guest1 = ""
local Guest2 = ""

if name1 == "" then
	Guest1 = true
	else
	Guest1 = false
end

if name2 == "" then
	Guest2 = true
	else
	Guest2 = false
end


if SongsInSet == 0 then
	TotalGuestStepsP1 = 0
	TotalGuestStepsP2 = 0
end


local TapTypes = { 'W1', 'W2', 'W3', 'W4', 'W5' }

local TapPoints = { 1, 1, 1, 1, 1 }

if not GAMESTATE:IsCourseMode() then
	ScoreP1 = 0
	ScoreP2 = 0
	
	local StatsP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
	local StatsP2 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2)
	
	for index, window in ipairs(TapTypes) do
		local number1 = StatsP1:GetTapNoteScores( "TapNoteScore_"..window )
		local number2 = StatsP2:GetTapNoteScores( "TapNoteScore_"..window )
		
		ScoreP1 = ScoreP1 + number1
		ScoreP2 = ScoreP2 + number2
		
	end
	
	
	TotalGuestStepsP1 = ScoreP1 + TotalGuestStepsP1
	TotalGuestStepsP2 = ScoreP2 + TotalGuestStepsP2
	
	
end