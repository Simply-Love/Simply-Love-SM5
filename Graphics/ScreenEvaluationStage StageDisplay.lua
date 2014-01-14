-- eval stage
local event = PREFSMAN:GetPreference("EventMode")
local mode = GAMESTATE:GetPlayMode()
local showStage = (not event) and (mode == 'PlayMode_Regular' or mode == 'PlayMode_Rave' or mode == 'PlayMode_Battle')

return LoadFont("_wendy small")..{
	InitCommand=cmd(diffuse,color("1,1,1,1");shadowlength,0;zoom,0.6;NoStroke; draworder, 1000;);
	BeginCommand=cmd(visible,showStage);
	OnCommand=cmd(playcommand,"Set");
	OffCommand=cmd(linear,0.2;diffusealpha,0);
	SetCommand=function(self)
		local curStage = GAMESTATE:GetCurrentStage()
		local screen = SCREENMAN:GetTopScreen();

		if screen and screen.GetStageStats then
			local stageStats = screen:GetStageStats();
			curStage = stageStats:GetStage();
		end

		local text = THEME:GetString("Stage",string.sub(curStage,7));
		self:settext(text)
	end;
};