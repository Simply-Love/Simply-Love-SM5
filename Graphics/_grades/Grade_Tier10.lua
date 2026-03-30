if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/a-minus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/a-minus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end