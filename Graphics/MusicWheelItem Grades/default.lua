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


return Def.Sprite{
	Texture=THEME:GetPathG("MusicWheelItem","Grades/grades 1x18.png"),
	InitCommand=function(self) self:zoom( SL_WideScale(0.18, 0.3) ):animate(false) end,

	-- "SetGrade" is broadcast by the engine with two parameters:
	--    Grade (GradeTier as number)
	--    NumTimesPlayed (number)
	SetGradeCommand=function(self, params)
		if not (params.Grade and grades[params.Grade]) then
			self:visible(false)
			return
		end

		self:visible(true):setstate(grades[params.Grade])
	end
}