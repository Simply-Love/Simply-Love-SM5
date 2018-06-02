local file

if GAMESTATE:IsCourseMode() then
	file = LoadActor("./CourseContentsList.lua")
else
	file = LoadActor("./Grid.lua")
end

return file