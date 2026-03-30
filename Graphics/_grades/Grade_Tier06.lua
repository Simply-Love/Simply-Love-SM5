if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/s.png")..{ OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/s.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end
