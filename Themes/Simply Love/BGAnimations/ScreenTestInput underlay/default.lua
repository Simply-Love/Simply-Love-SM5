local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end
	
	local state = "Off"
	if event.type ~= "InputEventType_Release" then
		state = "On"		
	end
		
	MESSAGEMAN:Broadcast(ToEnumShortString(event.PlayerNumber) .. event.button .. state)
	return false
end



return Def.ActorFrame {
	InitCommand=cmd(queuecommand,"Capture");
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end;
	OffCommand=cmd(sleep,0.4);
	
	Def.DeviceList {
		Font=THEME:GetPathF("","_miso");
		InitCommand=cmd(xy,_screen.cx,_screen.h-60; zoom,0.8; NoStroke);	
	};
		
	LoadActor("visuals");
};