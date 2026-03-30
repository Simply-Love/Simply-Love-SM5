if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/q.png")..{ 	OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/q.png")..{ 	OnCommand=function(self) self:zoom(0.85) end }
end