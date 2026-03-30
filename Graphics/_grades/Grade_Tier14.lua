if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/c-plus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/c-plus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end
