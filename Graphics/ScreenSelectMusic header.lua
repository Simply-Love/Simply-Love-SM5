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

					elseif topscreen:GetName() == "ScreenEvaluationNonstop" then
						StageText = THEME:GetString("ScreenSelectPlayMode", "Marathon")

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

	LoadActor( THEME:GetPathG("", "_header.lua") ),

	LoadFont("_wendy small")..{
		Name="Stage Number",
		InitCommand=cmd(diffusealpha,0; zoom,WideScale(0.5,0.6); xy,_screen.cx, 16 ),
		TextCommand=cmd(settext, StageText),
		OnCommand=cmd(sleep,0.1; decelerate,0.33; diffusealpha,1),
	},

	Def.BitmapText{
		Name="GameModeText",
		Font="_wendy small",
		InitCommand=function(self)
			self:diffusealpha(0):zoom( WideScale(0.5,0.6)):xy(_screen.w-70, 16):halign(1)
			if not PREFSMAN:GetPreference("MenuTimer") then
				self:x(_screen.w-10)
			end
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
				:settext(THEME:GetString("ScreenSelectPlayMode", SL.Global.GameMode))
		end,
		UpdateHeaderTextCommand=function(self)
			self:settext(THEME:GetString("ScreenSelectPlayMode", SL.Global.GameMode))
		end
	},

	LoadFont("_wendy small") .. {
		InitCommand=cmd(zoom,WideScale(0.4, 0.5); xy, _screen.cx, SCREEN_BOTTOM-13; horizalign,center; diffusealpha,0; queuecommand,"TextSet"),
		TextSetCommand=function(self)
		--we only want the date to show on the evaluation stage, so we're going to restrict settext to only work on that screen
			local topscreen = SCREENMAN:GetTopScreen()
			if topscreen then
				if topscreen:GetName() == "ScreenEvaluationStage" or topscreen:GetName() == ScreenEvaluationCourse then
					self:settext( string.format('%s %02i %04i', MonthToString(MonthOfYear()), DayOfMonth(), Year()) )
				end
			end
		end,
		OnCommand=cmd(decelerate,0.5; diffusealpha,1),
		OffCommand=cmd(accelerate,0.5;diffusealpha,0)
	},
}

return t
