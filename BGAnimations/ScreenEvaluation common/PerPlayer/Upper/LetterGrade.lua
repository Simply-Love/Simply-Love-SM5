local player = ...

local AwardMap = {
	["StageAward_FullComboW1"] = 1,
	["StageAward_FullComboW2"] = 2,
	["StageAward_SingleDigitW2"] = 2,
	["StageAward_OneW2"] = 2,
	["StageAward_FullComboW3"] = 3,
	["StageAward_SingleDigitW3"] = 3,
	["StageAward_OneW3"] = 3,
	["StageAward_100PercentW3"] = 3,
	-- FullComboW4 technically doesn't exist, but we create it on the fly below.
	["StageAward_FullComboW4"] = 4,
}

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local grade = playerStats:GetGrade()
local award = AwardMap[playerStats:GetStageAward()]
local hasStream = false

-- "I passd with a q though."
local title = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
if title == "D" then grade = "Grade_Tier99" end

-- QUINT
local ex = CalculateExScore(player, GetExJudgmentCounts(player))
if ex == 100 then grade = "Grade_Tier00" end

if award == 1 and playerStats:GetScore() == 0 then
	award = 0
end

if not GAMESTATE:IsCourseMode() then
	streamMeasures, breakMeasures = GetTotalStreamAndBreakMeasures(ToEnumShortString(player))
	totalMeasures = streamMeasures + breakMeasures
	
	if streamMeasures/totalMeasures >= 0.2 then hasStream = true end
end

local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(70 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-144)
	end,
	OnCommand=function(self)
		self:zoom(0.3)
		
		if not hasStream then
			self:zoom(0.4)
			self:y(_screen.cy-136)
		end
		
		if ThemePrefs.Get("GradeCombo") and award ~= nil then
			self:diffuseshift():effectperiod(0.8)
			if award == 0 then
				-- FBFC, use a special color
				local ItlPink = color("1,0.2,0.406,1")
				self:effectcolor1(ItlPink)
				self:effectcolor2(lerp_color(0.70, color("#ffffff"), ItlPink))
			elseif award < 4 then
				self:effectcolor1(SL.JudgmentColors["ITG"][award])
				self:effectcolor2(lerp_color(0.70, color("#ffffff"), SL.JudgmentColors["ITG"][award]))
			end
		end
	end
}

return t