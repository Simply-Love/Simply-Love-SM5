local pn = ...;

return LoadFont("_misoreg hires")..{
	InitCommand=cmd(shadowlength,1;Stroke,color("0.2,0.2,0.2,0.35");zoom,0.8);
	BeginCommand=function(self)
		if not GAMESTATE:IsCourseMode() then return; end;

		-- visibility
		if not GAMESTATE:IsPlayerEnabled(pn) then
			self:visible(false);
		end;

		local text = "";
		local proxy = SCREENMAN:GetTopScreen():GetChild( 'SurvivedNumber'..pname(pn) );
		if proxy then
			text = proxy:GetText();
		end;
		local stageText = "stage"
		if text ~= "01" then
			stageText = stageText .."s"
		end
		self:settext( text .." ".. stageText );
	end;
};