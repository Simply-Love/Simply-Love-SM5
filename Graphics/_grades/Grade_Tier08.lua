if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/a-plus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/a-plus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end
