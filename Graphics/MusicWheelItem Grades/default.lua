-- if we're in CourseMode, return a blank Actor now
if GAMESTATE:IsCourseMode() then return NullActor end

-- how many GradeTiers are defined in Metrics.ini?
local num_tiers = THEME:GetMetric("PlayerStageStats", "NumGradeTiersUsed")

-- make a grades table, and dynamically fill it with key/value pairs that we'll use in the
-- Def.Sprite below to set the Sprite to the appropriate state on the spritesheet of grades provided
--
-- keys will be in the format of "Grade_Tier01", "Grade_Tier02", "Grade_Tier03", etc.
-- values will start at 0 and go to (num_tiers-1)
local grades = {
	["Grade_Tier00"] = 0  -- Manually add a key for Quints
}
for i=1,num_tiers do
	grades[ ("Grade_Tier%02d"):format(i) ] = i
end
-- assign the "Grade_Failed" key a value equal to num_tiers
grades["Grade_Failed"] = num_tiers + 1

-- This is a quick way to check if a score is a quint.
-- Technically a hack until we actually get engine support for quints/tracking
-- W0 but this is good enough for now.
-- We do this by checking if:
--  1. Any score exists that has a percentDP of 1.0 (they've quadded)
--  2. The high score tracked whites (by determining if score < #Fantastics)
--  3. The number of whites is actually 0
local function IsQuint(hsl)
	if hsl == nil then return false end

	for hs in ivalues(hsl:GetHighScores()) do
		if (hs:GetPercentDP() == 1.0 and
					hs:GetScore() < hs:GetTapNoteScore("TapNoteScore_W1")
					and hs:GetScore() == 0) then
			return true
		end
	end

	return false
end

local af = Def.ActorFrame {
	Def.Sprite{
		Texture=THEME:GetPathG("MusicWheelItem","Grades/grades 1x19.png"),
		InitCommand=function(self) self:zoom( SL_WideScale(0.18, 0.3) ):animate(false) end,

		-- "SetGrade" is broadcast by the engine in MusicWheelItem.cpp.
		-- It will be passed a table with, at minimum, one parameter:
		--     PlayerNumber (PlayerNumber enum as string)
		--
		-- and potentially three more if the current song/course and steps/trail have a non-null HighScoreList
		--     Grade (GradeTier as number)
		--     NumTimesPlayed (number)
		--     HighScoreList (as of ITGmania 1.0.1 -- NOTE: can be removed in a future version)
		SetGradeCommand=function(self, params)
			if not params.Grade or ThemePrefs.Get("MusicWheelScore") == MusicWheelScore_ReplaceGrade then
				self:visible(false)
				return
			end

			local grade = params.Grade
			if grade == "Grade_Tier01" and IsQuint(params.HighScoreList) then
				grade = "Grade_Tier00"
			end

			local state = grades[grade]
			if not state then
				self:visible(false)
				return
			end

			self:visible(true):setstate(state)
		end
	},
}

if not ThemePrefs.Get("MusicWheelScore") == MusicWheelScore_ReplaceGrade then
	af[#af + 1] = LoadActor("GetLamp.lua")
end

return af
