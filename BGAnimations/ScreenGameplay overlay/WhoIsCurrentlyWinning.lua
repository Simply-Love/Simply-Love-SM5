-- If both players are joined, change the opacity of their score BitmapText actors to
-- visually indicate who is winning at a given moment during gameplay.
------------------------------------------------------------

-- if there is only one player, don't bother
if #GAMESTATE:GetHumanPlayers() < 2 then return end

-- if displaying different scoring mechanisms, don't bother.
if SL["P1"].ActiveModifiers.ShowEXScore ~= SL["P2"].ActiveModifiers.ShowEXScore then return end

local p1_score, p2_score
local p1_dp = 0
local p2_dp = 0
local p1_pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
local p2_pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2)
local IsEX = SL["P1"].ActiveModifiers.ShowEXScore

-- allow for HideScore, which outright removes score actors
local try_diffusealpha = function(af, alpha)
	if not af or not (af.diffusealpha) then return end
	af:diffusealpha(alpha)
end

return Def.Actor{
	OnCommand=function(self)
		local underlay = SCREENMAN:GetTopScreen():GetChild("Underlay")
		p1_score = underlay:GetChild("P1Score")
		p2_score = underlay:GetChild("P2Score")
	end,
	JudgmentMessageCommand=function(self, params)
		if not IsEX then
			-- calculate the percentage DP manually rather than use GetPercentDancePoints.
			-- That function rounds to the nearest .01%, which is inaccurate on long songs.
			if params.Player == PLAYER_1 then
				p1_dp = p1_pss:GetActualDancePoints() / p1_pss:GetPossibleDancePoints()
			elseif params.Player == PLAYER_2 then
				p2_dp = p2_pss:GetActualDancePoints() / p2_pss:GetPossibleDancePoints()
			end
			self:queuecommand("Winning")
		end
	end,
	ExCountsChangedMessageCommand=function(self, params)
		if IsEX then
			if params.Player == PLAYER_1 then
				p1_dp = params.ExScore
			elseif params.Player == PLAYER_2 then
				p2_dp = params.ExScore
			end
			self:queuecommand("Winning")
		end
	end,
	WinningCommand=function(self)
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
