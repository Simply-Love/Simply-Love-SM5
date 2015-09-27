local StageText = ""
local SongsPerPlay = PREFSMAN:GetPreference("SongsPerPlay")
local SongCost = 1

local t = Def.ActorFrame{

	InitCommand=cmd(queuecommand,"FigureStuffOut"),
	FigureStuffOutCommand=function(self)

		if PREFSMAN:GetPreference("EventMode") then
			StageText = THEME:GetString("Stage", "Event")

		else

			-- if the continue system is enabled, don't worry about determining "Final Stage"
			if ThemePrefs.Get("NumberOfContinuesAllowed") > 0 then
				StageText = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)

			else
				local topscreen = SCREENMAN:GetTopScreen()

				if topscreen then

					-- if we're on ScreenEval
					if topscreen:GetName() == "ScreenEvaluationStage" then
						local song = GAMESTATE:GetCurrentSong()
						local Duration = song:GetLastSecond()
						local DurationWithRate = Duration / SL.Global.ActiveModifiers.MusicRate

						local LongCutoff = PREFSMAN:GetPreference("LongVerSongSeconds")
						local MarathonCutoff = PREFSMAN:GetPreference("MarathonVerSongSeconds")

						local IsMarathon = DurationWithRate/MarathonCutoff > 1 and true or false
						local IsLong 	 = DurationWithRate/LongCutoff > 1 and true or false

						local SongCost = IsLong and 2 or IsMarathon and 3 or 1

						if SL.Global.Stages.PlayedThisGame + SongCost >= SongsPerPlay then
							StageText = THEME:GetString("Stage", "Final")
						else
							StageText = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + SongCost)
						end

					-- else if we're on ScreenSelectMusic
					else
						StageText = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)
					end
				end

			end
		end

		self:GetChild("Stage Number"):playcommand("Text")
	end,
	OffCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
			if topscreen:GetName() == "ScreenEvaluationStage" then
				SL.Global.Stages.PlayedThisGame = SL.Global.Stages.PlayedThisGame + SongCost
			else
				self:linear(0.1)
				self:diffusealpha(0)
			end
		end
	end,

	Def.Quad{
		InitCommand=cmd(zoomto, _screen.w, 32; vertalign, top; diffuse,0.65,0.65,0.65,1; x, _screen.cx),
	},

	LoadFont("_wendy small")..{
		Name="HeaderText",
		InitCommand=cmd(zoom,WideScale(0.5, 0.6); xy, 10, 15;  horizalign,left; diffusealpha,0; settext,ScreenString("HeaderText")),
		OnCommand=cmd(sleep,0.1; decelerate,0.33; diffusealpha,1),
	},

	LoadFont("_wendy small")..{
		Name="Stage Number",
		InitCommand=cmd(diffusealpha,0; zoom,WideScale(0.5,0.6); xy,_screen.cx, 15 ),
		TextCommand=cmd(settext, StageText),
		OnCommand=cmd(sleep,0.1; decelerate,0.33; diffusealpha,1),
	}
}

return t