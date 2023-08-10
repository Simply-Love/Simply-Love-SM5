local t = LoadFallbackB();

if not GAMESTATE:IsCourseMode() then
	local function CDTitleUpdate(self)
		local song = GAMESTATE:GetCurrentSong();
		local cdtitle = self:GetChild("CDTitle");
		local height = cdtitle:GetHeight();
		
		if song then
			if song:HasCDTitle() then
				cdtitle:visible(true);
				cdtitle:Load(song:GetCDTitlePath());
			else
				cdtitle:visible(false);
			end;
		else
			cdtitle:visible(false);
		end;
		
		self:zoom(scale(height,32,480,1,32/480))
	end;
	t[#t+1] = Def.ActorFrame {
		OnCommand=cmd(draworder,105;x,SCREEN_CENTER_X-380;y,SCREEN_CENTER_Y+40;zoom,0;sleep,0.5;decelerate,0.25;zoom,1;SetUpdateFunction,CDTitleUpdate);
		OffCommand=cmd(bouncebegin,0.15;zoomx,0);
		Def.Sprite {
			Name="CDTitle";
			OnCommand=cmd(draworder,106;shadowlength,1;zoom,0.75;diffusealpha,1;zoom,0;bounceend,0.35;zoom,0.75;spin;effectperiod,2;effectmagnitude,0,180,0);
			BackCullCommand=cmd(diffuse,color("0.5,0.5,0.5,1"));
		};	
	};
	t[#t+1] = StandardDecorationFromFileOptional("StageDisplay","StageDisplay");
end;

return t
