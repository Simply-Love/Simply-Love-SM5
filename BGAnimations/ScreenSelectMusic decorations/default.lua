local t = LoadFallbackB();

if not GAMESTATE:IsCourseMode() then
	t[#t+1] = StandardDecorationFromFileOptional("StageDisplay","StageDisplay");
end

return t
