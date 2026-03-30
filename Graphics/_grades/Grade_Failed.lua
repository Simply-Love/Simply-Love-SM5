if ThemePrefs.Get("OutlineGrade") then
	return LoadActor("./assets/outlined/f.png")..{ OnCommand=function(self) self:zoom(0.85) end }
else
	return LoadActor("./assets/f.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end
