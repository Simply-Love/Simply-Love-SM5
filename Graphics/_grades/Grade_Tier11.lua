if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/b-plus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/b-plus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end
