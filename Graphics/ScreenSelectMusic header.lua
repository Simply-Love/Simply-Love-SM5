local StageText = ""
local SongsPerPlay = PREFSMAN:GetPreference("SongsPerPlay")
local AdditionalSongs = 0

local t = Def.ActorFrame{
	InitCommand=cmd(queuecommand,"FigureStuffOut");
	FigureStuffOutCommand=function(self)
	
		if not GAMESTATE:IsEventMode() then
		
			StageText = THEME:GetString("Stage", "Stage") .. " " .. tostring(SongsPerPlay - SL.Global.Stages.Remaining + 1)
			local topscreen = SCREENMAN:GetTopScreen()
			
			if topscreen then
				if topscreen:GetName() == "ScreenEvaluationStage" then
					local song = GAMESTATE:GetCurrentSong()
					if song then
						if song:IsLong() then AdditionalSongs = 1 end
						if song:IsMarathon() then AdditionalSongs = 2 end
					end
				end
			end
			
			if SL.Global.Stages.Remaining - AdditionalSongs <= 1 then
				StageText = THEME:GetString("Stage", "Final")
			end
		else
			StageText = THEME:GetString("Stage", "Event")
		end
		
		self:GetChild("Stage Number"):playcommand("Text")
	end,

	
	Def.Quad{
		InitCommand=cmd(xy,_screen.cx,SCREEN_TOP;zoomto,_screen.w,40; diffuse,color("0.65,0.65,0.65,1"))
	},
	
	LoadFont("_wendy small") .. {
		Name="HeaderText",
		InitCommand=cmd(zoom,WideScale(0.5, 0.6); x,16; horizalign,left; diffusealpha,0; settext,ScreenString("HeaderText");),
		OnCommand=cmd(decelerate,0.5; diffusealpha,1),
		OffCommand=cmd(accelerate,0.5;diffusealpha,0)
	},
	
	LoadFont("_wendy small")..{
		Name="Stage Number",
		InitCommand=cmd(diffusealpha,0; zoom,WideScale(0.5,0.6); xy,_screen.cx, SCREEN_TOP),
		TextCommand=cmd(settext, StageText),
		OnCommand=cmd(decelerate,0.5; diffusealpha,1),
		OffCommand=cmd(accelerate,0.5;diffusealpha,0)
	}
}

return t