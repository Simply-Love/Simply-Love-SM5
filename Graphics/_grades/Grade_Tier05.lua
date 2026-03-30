if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/s-plus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/s-plus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end