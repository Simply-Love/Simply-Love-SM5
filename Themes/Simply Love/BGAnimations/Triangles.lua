if SL.Global.GameMode == "StomperZ" then
	return LoadActor( THEME:GetPathG("", "Triangles.png") )..{
		InitCommand=function(self) self:Center():zoom(0.666) end,
	}
end