-- if we're in CourseMode or MusicWheel grades are unwanted, return an empty Actor now
if GAMESTATE:IsCourseMode() or not ThemePrefs.Get("ShowGradesInMusicWheel") then
	return Def.Actor{ InitCommand=function(self) self:visible(false) end }
end


-- how many GradeTiers are defined in Metrics.ini?
local num_grade_tiers = THEME:GetMetric("PlayerStageStats", "NumGradeTiersUsed")

-- make a grades table, and dynamically fill it with key/value pairs that we'll use in the
-- Def.Sprite below to set the Sprite to the appropriate state on the spritesheet of grades provided
--
-- keys will be in the format of "Grade_Tier01", "Grade_Tier02", "Grade_Tier03", etc.
-- values will start at 0 and go to (num_grade_tiers-1)
local grades = {}
for i=1,num_grade_tiers do
	grades[ "Grade_Tier"..string.format("%02d",i) ] = i-1
end
-- assign the "Grade_Failed" key a value equal to num_grade_tiers
grades["Grade_Failed"] = num_grade_tiers

local state

return Def.Sprite{
	Texture=THEME:GetPathG("MusicWheelItem","Grades/grades 1x18.png"),
	InitCommand=function(self) self:zoom( WideScale(0.18, 0.3) ):animate(0) end,
	SetGradeCommand=function(self, params)
		state = grades[params.Grade]

		if state == nil then
			self:visible(false)
		else
			self:visible(true):setstate(state)
		end
	end
}