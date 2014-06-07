local number = SimplyLoveColor();
if number < 10 then number = "0"..tostring(number) end

return Def.Sprite {
	InitCommand=function(self)
		self:Load( THEME:GetPathG("", "_ComboGraphs/ComboGraph" .. number ) );	
	end;
};