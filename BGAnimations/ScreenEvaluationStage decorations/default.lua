local t = Def.ActorFrame{

	-- hack this into the middle of the header
	LoadActor(THEME:GetPathG("ScreenEvaluationStage","StageDisplay"))..{
		InitCommand=cmd(CenterX;y,16);
	};

	-- the content
	LoadActor( THEME:GetPathB("ScreenEvaluation","common") );

};

t[#t+1] = StandardDecorationFromFileOptional("Header","Header");

return t;