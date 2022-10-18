local file

if GAMESTATE:IsCourseMode() then
	file = LoadActor("./CourseContentsList.lua")
elseif ThemePrefs.Get("SelectMusicDisplayStyle") == "ITG+" and GAMESTATE:GetCurrentGame():GetName() == "dance"  then
	file = LoadActor("./Grid.lua")
else
	file = LoadActor("./Grid-Classic.lua")

end

return file