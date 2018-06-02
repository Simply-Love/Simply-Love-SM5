if SL.Global.GameMode ~= "Casual" then
	local pn = ...

	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local disqualified = stats:IsDisqualified()

	return LoadFont("_wendy small")..{
		Name="Disqualified"..ToEnumShortString(pn),
		InitCommand=cmd(diffusealpha,0.7; zoom,0.23; y, _screen.cy+138 ),
		OnCommand=function(self)
			if disqualified then
				self:settext(THEME:GetString("ScreenEvaluation","Disqualified"))
			end
		end
	}
end