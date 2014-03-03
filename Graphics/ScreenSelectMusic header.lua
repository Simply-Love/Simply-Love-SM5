local curStage = string.sub(GAMESTATE:GetCurrentStage(), 7);
local s = THEME:GetString("Stage", curStage);

if string.match(curStage, '%d+') == tostring(PREFSMAN:GetPreference("SongsPerPlay")) then
	s = THEME:GetString("Stage", "Final");
end;

local t = Def.ActorFrame{
	
	Def.Quad{
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_TOP;zoomto,SCREEN_WIDTH,40; diffuse,color("0.65,0.65,0.65,1"));
	};
	
	LoadFont("_wendy small") .. {
		Name="HeaderText";
		InitCommand=cmd(zoom,WideScale(0.5, 0.6); x,16; horizalign,left; diffusealpha,0; settext,ScreenString("HeaderText"););
		OnCommand=cmd(decelerate,0.5; diffusealpha,1);
		OffCommand=cmd(accelerate,0.5;diffusealpha,0);
	};
	
	LoadFont("_wendy small")..{
		InitCommand=cmd(diffusealpha,0; zoom,WideScale(0.5,0.6); settext, s; xy,SCREEN_CENTER_X, SCREEN_TOP);
		OnCommand=cmd(decelerate,0.5; diffusealpha,1);
		OffCommand=cmd(accelerate,0.5;diffusealpha,0);
	};
};

return t;