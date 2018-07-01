-- if there is only one player, don't bother
if #GAMESTATE:GetHumanPlayers() < 2 then return end

-- if either of the two players have HideScore enabled, don't bother
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	if SL[ ToEnumShortString(player) ].ActiveModifiers.HideScore then
		return
	end
end

local p1_score, p2_score, p1_dp, p2_dp
local p1_pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
local p2_pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2)

return Def.Actor{
	OnCommand=function(self)
		p1_score = self:GetParent():GetChild("P1Score")
		p2_score = self:GetParent():GetChild("P2Score")
	end,
	JudgmentMessageCommand=function(self) self:queuecommand("Winning") end,
	WinningCommand=function(self)
		-- calculate the percentage DP manually rather than use GetPercentDancePoints.
		-- That function rounds to the nearest .01%, which is inaccurate on long songs.
		p1_dp = p1_pss:GetActualDancePoints() / p1_pss:GetPossibleDancePoints()
		p2_dp = p2_pss:GetActualDancePoints() / p2_pss:GetPossibleDancePoints()

		if p1_dp == p2_dp then
			p1_score:diffusealpha(1)
			p2_score:diffusealpha(1)
		elseif p1_dp > p2_dp then
			p1_score:diffusealpha(1)
			p2_score:diffusealpha(0.65)
		elseif p2_dp > p1_dp then
			p1_score:diffusealpha(0.65)
			p2_score:diffusealpha(1)
		end
	end
}
