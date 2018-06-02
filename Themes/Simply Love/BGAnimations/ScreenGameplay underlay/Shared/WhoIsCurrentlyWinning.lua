-- if there is only one player, don't bother
if #GAMESTATE:GetHumanPlayers() < 2 then
	return Def.Actor{}
end

-- if either of the two players have HideScore enabled, don't bother
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	if SL[ ToEnumShortString(player) ].ActiveModifiers.HideScore then
		return Def.Actor{}
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
		p1_dp = p1_pss:GetPercentDancePoints()
		p2_dp = p2_pss:GetPercentDancePoints()

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