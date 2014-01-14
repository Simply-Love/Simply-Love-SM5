function TextBannerAfterSet(self)

	local Title = self:GetChild("Title");
	local Subtitle = self:GetChild("Subtitle");	
	
	if Subtitle:GetText() ~= "" then
		( cmd(zoom,0.85; y,-6; x, WideScale(-85, -100); maxwidth, WideScale(300,400); ))(Title);
		( cmd(zoom,0.7;  y, 6; x, WideScale(-85, -100); maxwidth, WideScale(300,400); ))(Subtitle);
	else                      
		( cmd(zoom,0.85; y, 0; x, WideScale(-85, -100); maxwidth, WideScale(300,400); ))(Title);
	end
	
end