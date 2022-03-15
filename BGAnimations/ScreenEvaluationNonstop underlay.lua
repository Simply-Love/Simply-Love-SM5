if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	local PlayerOneChart = GAMESTATE:GetCurrentTrail(0)
	DDStats.SetStat(PLAYER_1, 'LastCourse', GAMESTATE:GetCurrentCourse():GetCourseDir())
	DDStats.SetStat(PLAYER_1, 'LastCourseDifficulty', PlayerOneChart:GetDifficulty())
	DDStats.Save(PLAYER_1)
end

if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	local PlayerTwoChart = GAMESTATE:GetCurrentTrail(1)
	DDStats.SetStat(PLAYER_2, 'LastCourse', GAMESTATE:GetCurrentCourse():GetCourseDir())
	DDStats.SetStat(PLAYER_2, 'LastCourseDifficulty', PlayerTwoChart:GetDifficulty())
	DDStats.Save(PLAYER_2)
end





return Def.ActorFrame { }