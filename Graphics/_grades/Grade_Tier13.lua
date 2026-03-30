if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/b-minus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/b-minus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end
