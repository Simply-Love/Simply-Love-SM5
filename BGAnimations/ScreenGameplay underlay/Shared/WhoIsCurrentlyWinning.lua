return Def.Actor{
	JudgmentMessageCommand=cmd(queuecommand, "Winning"),
	WinningCommand=function(self)
		local dpP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetPercentDancePoints()
		local dpP2 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2):GetPercentDancePoints()

		local p1_score = self:GetParent():GetChild("P1Score")
		local p2_score = self:GetParent():GetChild("P2Score")

		if dpP1 == dpP2 then
			p1_score:diffusealpha(1)
			p2_score:diffusealpha(1)
		elseif dpP1 > dpP2 then
			p1_score:diffusealpha(1)
			p2_score:diffusealpha(0.65)
		elseif dpP2 > dpP1 then
			p1_score:diffusealpha(0.65)
			p2_score:diffusealpha(1)
		end
	end
}