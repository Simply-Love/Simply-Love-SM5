local t = Def.ActorFrame{
	-- the content
	LoadActor( THEME:GetPathB("ScreenEvaluation","common") );
};

t[#t+1] = StandardDecorationFromFileOptional("Header","Header");

return t;