local player = ...

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local grade = playerStats:GetGrade()

-- only run in modified ITGmania build
if SYNCMAN and SYNCMAN:IsEnabled() then
    local ex_counts = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts
    local white_count = ex_counts["W1"]
    local ExScore, ActualPoints, ActualPossible = CalculateExScore(player)

	-- Broadcast final score for each player, used by syncstart-web to save scores
	if GAMESTATE:IsCourseMode() then
		SYNCMAN:BroadcastFinalCourseScore(playerStats, white_count, ActualPoints, ActualPossible)
	else
		SYNCMAN:BroadcastFinalScore(playerStats, white_count, ActualPoints, ActualPossible)
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
