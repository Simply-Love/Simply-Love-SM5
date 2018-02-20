local SongsPerPlay = PREFSMAN:GetPreference("SongsPerPlay")
local SongCost = 1

local StageText = function()

	-- if the continue system is enabled, don't worry about determining "Final Stage"
	if ThemePrefs.Get("NumberOfContinuesAllowed") > 0 then
		return THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)
	end

	local topscreen = SCREENMAN:GetTopScreen()
	if topscreen then

		-- if we're on ScreenEval for normal gameplay
		-- we might want to display the text for StageFinal, or we might want to
		-- increment the Stages.PlayedThisGame by the cost of the song that was just played
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
				return THEME:GetString("Stage", "Final")
			else
				return THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + SongCost)
			end

		-- if we're on ScreenEval within Marathon Mode, generic text will suffice
		elseif topscreen:GetName() == "ScreenEvaluationNonstop" then
			return THEME:GetString("ScreenSelectPlayMode", "Marathon")

		-- if we're on ScreenSelectMusic, display the number of Stages.PlayedThisGame + 1
		-- the song the player actually selects may cost more than 1, but we cannot know that now
		else
			return THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)
		end
	end
end

local bmt_actor

local Update = function(af, dt)
	local seconds = GetTimeSinceStart() - SL.Global.TimeAtSessionStart

	-- if this game session is less than 1 hour in duration so far
	if seconds < 3600 then
		bmt_actor:settext( SecondsToMMSS(seconds) )
	else
		bmt_actor:settext( SecondsToHHMMSS(seconds) )
	end
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		if PREFSMAN:GetPreference("EventMode") then
			-- TimeAtSessionStart will be reset to nil between game sesssions
			-- thus, if it's currently nil, we're loading ScreenSelectMusic
			-- for the first time this particular game session
			if SL.Global.TimeAtSessionStart == nil then
				SL.Global.TimeAtSessionStart = GetTimeSinceStart()
			end

			self:SetUpdateFunction( Update )
		end
	end,
	OffCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
			if topscreen:GetName() == "ScreenEvaluationStage" or topscreen:GetName() == "ScreenEvaluationNonstop" then
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
		InitCommand=function(self)
			bmt_actor = self
			self:diffusealpha(0):zoom( WideScale(0.5,0.6) ):xy(_screen.cx, 15)
		end,
		OnCommand=function(self)
			if not PREFSMAN:GetPreference("EventMode") then
				self:settext( StageText() )
			end

			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	},

	Def.BitmapText{
		Name="GameModeText",
		Font="_wendy small",
		InitCommand=function(self)
			self:diffusealpha(0):zoom( WideScale(0.5,0.6)):xy(_screen.w-70, 15):halign(1)
			if not PREFSMAN:GetPreference("MenuTimer") then
				self:x(_screen.w-10)
			end
		end,
		OnCommand=function(self)
			self:settext(THEME:GetString("ScreenSelectPlayMode", SL.Global.GameMode))
				:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
		UpdateHeaderTextCommand=function(self)
			self:settext(THEME:GetString("ScreenSelectPlayMode", SL.Global.GameMode))
		end
	}
}

return t