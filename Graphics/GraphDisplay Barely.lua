local t = Def.ActorFrame{
	LoadFont("_misoreg hires")..{
		Text="Barely!";
		OnCommand=cmd(zoom,0.75;shadowlength,0;y,-4;diffusealpha,0;addy,-20;sleep,0.5;accelerate,.2;diffusealpha,1;addy,30;);
	};
	
	LoadActor(THEME:GetPathB("ScreenSelectMusic", "overlay/CustomStepsDisplayList/arrow.png"))..{
		InitCommand=cmd(rotationz,90; zoom,0.5; y,10; diffusealpha,0; addy,-20;);
		OnCommand=cmd(sleep,0.5;
 			accelerate,.2; diffusealpha,1; addy,30;
			diffuseshift; effectcolor1,1,1,1,1; effectcolor2,1,1,1,0.2;
			decelerate,.3; addy,-10; accelerate,.3; addy,10;
		);
	};

};

return t;