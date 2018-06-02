local pss = ...

return Def.ActorFrame{
	LoadActor("star.lua", pss)..{
		OnCommand=cmd(x,-45;y,40;zoom,0.5;pulse;effectmagnitude,1,0.9,0);
	};
	LoadActor("star.lua", pss)..{
		OnCommand=cmd(x,0;y,-40;zoom,0.5;effectoffset,0.2;pulse;effectmagnitude,0.9,1,0);
	};
	LoadActor("star.lua", pss)..{
		OnCommand=cmd(x,45;y,40;zoom,0.5;effectoffset,0.4;pulse;effectmagnitude,0.9,1,0);
	};
};
