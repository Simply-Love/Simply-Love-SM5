-- if we're in CourseMode, return a blank Actor now
if GAMESTATE:IsCourseMode() then return NullActor end


-- how many GradeTiers are defined in Metrics.ini?
local num_tiers = THEME:GetMetric("PlayerStageStats", "NumGradeTiersUsed")

-- make a grades table, and dynamically fill it with key/value pairs that we'll use in the
-- Def.Sprite below to set the Sprite to the appropriate state on the spritesheet of grades provided
--
-- keys will be in the format of "Grade_Tier01", "Grade_Tier02", "Grade_Tier03", etc.
-- values will start at 0 and go to (num_tiers-1)
local grades = {}
for i=1,num_tiers do
	grades[ ("Grade_Tier%02d"):format(i) ] = i-1
end
-- assign the "Grade_Failed" key a value equal to num_tiers
grades["Grade_Failed"] = num_tiers

-- SetGrade command has no access to player number, so the grades can only be
-- shown or hidden for both players. If one of the players wants them hidden,
-- do it.
local shouldHideGrades = function()
	local hideGrades = false
	local Players = GAMESTATE:GetHumanPlayers()
	for player in ivalues(Players) do
		if SL[ToEnumShortString(player)].ActiveModifiers.DoNotJudgeMe then
			hideGrades = true
			break
		end
	end
	return hideGrades
end

return Def.Sprite{
	Texture=THEME:GetPathG("MusicWheelItem","Grades/grades 1x18.png"),
	InitCommand=function(self) self:zoom( SL_WideScale(0.18, 0.3) ):animate(false) end,

	-- "SetGrade" is broadcast by the engine with two parameters:
	--    Grade (GradeTier as number)
	--    NumTimesPlayed (number)
	SetGradeCommand=function(self, params)
		if not (params.Grade and grades[params.Grade]) or shouldHideGrades() then
			self:visible(false)
			return
		end

		self:visible(true):setstate(grades[params.Grade])
	end
}
