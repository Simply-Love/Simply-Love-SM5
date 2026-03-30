local curScreen = Var "LoadingScreen";
local curStage = GAMESTATE:GetCurrentStage();
local curStageIndex = GAMESTATE:GetCurrentStageIndex();
local t = Def.ActorFrame {};

t[#t+1] = Def.ActorFrame {
		Def.Quad{
			InitCommand=cmd(diffuse,color("#000000");zoomto,100,30;);
			OnCommand=cmd(diffusealpha,0.4;fadeleft,0.2;faderight,0.2;);
		};
	LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal") .. {
		InitCommand=cmd(y,-1;shadowlength,1;zoom,1;strokecolor,color("#000000"));
		BeginCommand=function(self)
			local top = SCREENMAN:GetTopScreen()
			if top then
				if not string.find(top:GetName(),"ScreenEvaluation") then
					curStageIndex = curStageIndex + 1
				end
			end
			self:playcommand("Set")
		end;
		SetCommand=function(self)
			if GAMESTATE:GetCurrentCourse() then
				self:settext( curStageIndex+1 .. " / " .. GAMESTATE:GetCurrentCourse():GetEstimatedNumStages() );
			elseif GAMESTATE:IsEventMode() then
				self:settextf("Stage %s", curStageIndex);
			else
				self:settextf("%s Stage", ToEnumShortString(curStage));
				self:zoom(1);
			end;
			-- StepMania is being stupid so we have to do this here;
			self:diffuse(StageToColor(curStage));
			self:diffusetopedge(ColorLightTone(StageToColor(curStage)));
		end;
	};
};
return t