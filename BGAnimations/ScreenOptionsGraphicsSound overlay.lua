local t = Def.ActorFrame{
	InitCommand=cmd(queuecommand,"Capture");
	CaptureCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen();
		
		if topscreen then
			
		else
			self:queuecommand("Capture");
		end
	end;
};

return t;