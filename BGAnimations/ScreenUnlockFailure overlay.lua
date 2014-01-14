local t =  Def.ActorFrame{
	OnCommand=function(self)
		self:GetChild("songNotUnlocked"):play();
	end;
};


	
t[#t+1] = LoadFont("_misoreg hires")..{
	Name="FailureText";
	Text="Not quite...";
	InitCommand=cmd(xy, SCREEN_CENTER_X,SCREEN_CENTER_Y-50; zoom,1.4);
}


t[#t+1] = LoadActor( THEME:GetPathS("", "_unlockFail.ogg")	)..{ Name="songNotUnlocked"; };


return t;