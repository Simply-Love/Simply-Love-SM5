-- if there is only one player, don't bother
if #GAMESTATE:GetHumanPlayers() < 2 then return end

local p1_score, p2_score, p1_dp, p2_dp
local p1_pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
local p2_pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2)

-- allow for HideScore, which outright removes score actors
local try_diffusealpha = function(af, alpha)
	if not af or not (af.diffusealpha) then return end
	af:diffusealpha(alpha)
end

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
			try_diffusealpha(p1_score, 1)
			try_diffusealpha(p2_score, 1)
		elseif p1_dp > p2_dp then
			try_diffusealpha(p1_score, 1)
			try_diffusealpha(p2_score, 0.65)
		elseif p2_dp > p1_dp then
			try_diffusealpha(p1_score, 0.65)
			try_diffusealpha(p2_score, 1)
		end
	end
}
