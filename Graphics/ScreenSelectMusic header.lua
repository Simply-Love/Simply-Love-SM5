local StageText = ""
local SongsPerPlay = PREFSMAN:GetPreference("SongsPerPlay")

-- assume that a song, by default, has a cost of 1
-- if long, cost is 1 additional song; if marathon, cost if 2 additional songs
local AdditionalSongs = 0

-- if a rate mod would transform a normally long song to be within normal length, add a stage!
-- if a rate mod would transform a normally marathon song to be within long length, add a stage
-- if a rate mode would transform a normally marathon song to be within normal legnth, add two stages
local StagesToAdd = 0

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

						local Duration = song:GetLastSecond()
						local DurationWithRate = Duration / SL.Global.ActiveModifiers.MusicRate

						local LongCutoff = PREFSMAN:GetPreference("LongVerSongSeconds")
						local MarathonCutoff = PREFSMAN:GetPreference("MarathonVerSongSeconds")

						local IsMarathonWithRate = DurationWithRate/MarathonCutoff > 1 and true or false
						local IsLongWithRate 	 = DurationWithRate/LongCutoff > 1 and true or false

						if SL.Global.ActiveModifiers.MusicRate ~= 1 then

							if song:IsMarathon() and not IsLongWithRate then
								StagesToAdd = 2
							elseif song:IsMarathon() and IsLongWithRate and not IsMarathonWithRate then
								StagesToAdd = 1
							elseif song:IsLong() and not IsLongWithRate and not IsMarathonWithRate then
								StagesToAdd = 1
							end
						end
						
					end
				end
			end
			
			
			if SL.Global.Stages.Remaining - AdditionalSongs + StagesToAdd <= 1 then
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