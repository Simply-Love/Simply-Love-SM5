-- for ScreenTitleJoin (home/pay mode) there is only option, Dance Mode
-- which we are only interested in hiding here

return Def.ActorFrame{
	LoadFont("_wendy small")..{	
		InitCommand=cmd(visible, false);
	};
};