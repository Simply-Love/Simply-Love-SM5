local player = ...

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local grade = playerStats:GetGrade()

-- only run in modified ITGmania build
if SYNCMAN and SYNCMAN:IsEnabled() then
    local ex_counts = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts
    local ExScore, ActualPoints, ActualPossible = CalculateExScore(player)
	local ExScoreStr = ("%.2f"):format(ExScore)

	-- Broadcast final score for each player, used by syncstart-web to save scores
	if GAMESTATE:IsCourseMode() then
		SYNCMAN:BroadcastFinalCourseScore(playerStats, ex_counts.W0, ex_counts.W1, ex_counts.W2, ex_counts.W3, ex_counts.W4, ex_counts.W5, ex_counts.Miss, ActualPoints, ActualPossible, ExScoreStr)
	else
		SYNCMAN:BroadcastFinalScore(playerStats, ex_counts.W0, ex_counts.W1, ex_counts.W2, ex_counts.W3, ex_counts.W4, ex_counts.W5, ex_counts.Miss, ActualPoints, ActualPossible, ExScoreStr)
	end
end

-- "I passd with a q though."
local title = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
if title == "D" then grade = "Grade_Tier99" end

-- QUINT
local ex = CalculateExScore(player)
if ex == 100 then grade = "Grade_Tier00" end

local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(70 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-134)
	end,
	OnCommand=function(self) self:zoom(0.4) end
}

return t
