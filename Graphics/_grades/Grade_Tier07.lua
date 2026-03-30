if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/s-minus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/s-minus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end
