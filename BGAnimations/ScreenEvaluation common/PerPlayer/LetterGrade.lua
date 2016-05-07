if SL.Global.GameMode ~= "StomperZ" then
	local pn = ...

	local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local grade = playerStats:GetGrade()

	-- "I passd with a q though."
	local title = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
	if title == "D" then grade = "Grade_Tier99" end

	return LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"), playerStats)..{
		InitCommand=cmd(xy, 70, _screen.cy-134),
		OnCommand=function(self)
			self:zoom(0.4)
			if pn == PLAYER_1 then
				self:x( self:GetX() * -1 )
			end
		end
	}
end