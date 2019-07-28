local pss = ...

return Def.ActorFrame{
	OnCommand=cmd(zoom,0.8;pulse;effectmagnitude,1,0.9,0);
	LoadActor("star.lua", pss);
};
