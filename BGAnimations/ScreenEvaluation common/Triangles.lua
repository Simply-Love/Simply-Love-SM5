if SL.Global.GameMode == "StomperZ" then
	return LoadActor( THEME:GetPathG("", "Triangles.png") )..{
		-- fullscreen the triangles
		InitCommand=function(self) self:FullScreen() end,

		-- HACK: change the header text
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():GetChild("Header"):GetChild("HeaderText"):settext("STOMPERZ")
		end
	}
end