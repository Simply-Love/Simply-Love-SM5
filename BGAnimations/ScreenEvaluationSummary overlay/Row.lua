local position_on_screen = ...

local SongOrCourse, StageNum

local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualStyle")
local banner_directory = FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")

-- -----------------------------------------------------------------------
-- this ActorFrame contains elements shared by both players
-- like the background Quad, song banner, and song title

local t = Def.ActorFrame{
	DrawPageCommand=function(self, params)
		self:finishtweening():sleep(position_on_screen*0.05):linear(0.15):diffusealpha(0)

		StageNum = ((params.Page-1)*4) + position_on_screen
		local stage = SL.Global.Stages.Stats[StageNum]
		SongOrCourse = stage ~= nil and stage.song or nil

		self:playcommand("DrawStage", {StageNum=StageNum})
	end,
	DrawStageCommand=function(self)
		if SongOrCourse == nil then
			self:visible(false)
		else
			self:finishtweening():queuecommand("Show"):visible(true)
		end
	end
}

-- black quad
t[#t+1] = Def.Quad{
	Name="BackgroundQuad",
	InitCommand=function(self) self:zoomto( _screen.w-40, 94):diffuse(0,0,0,0.5):y(-6) end
}

--fallback banner
t[#t+1] = LoadActor(banner_directory.."/banner"..SL.Global.ActiveColorIndex.." (doubleres).png")..{
	Name="FallbackBanner",
	InitCommand=function(self) self:y(-6):zoom(0.333) end,
	DrawStageCommand=function(self) self:visible(SongOrCourse ~= nil and not SongOrCourse:HasBanner()) end
}

-- the banner, if there is one
t[#t+1] = Def.Banner{
	Name="Banner",
	InitCommand=function(self) self:y(-6) end,
	DrawStageCommand=function(self)
		if SongOrCourse then
			if GAMESTATE:IsCourseMode() then
				self:LoadFromCourse(SongOrCourse)
			else
				self:LoadFromSong(SongOrCourse)
			end
			self:setsize(418,164):zoom(0.333)
		end
	end
}

-- the title of the song
t[#t+1] = LoadFont("Common Normal")..{
	Name="SongTitle",
	InitCommand=function(self) self:zoom(0.8):y(-43):maxwidth(350) end,
	DrawStageCommand=function(self)
		if SongOrCourse then self:settext(SongOrCourse:GetDisplayFullTitle()) end
	end
}

-- the BPM(s) of the song
-- FIXME: the current layout of ScreenEvaluationSummary doesn't accommodate split BPMs
--        so this is currently hardcoded to use the MasterPlayer's BPM values
t[#t+1] = LoadFont("Common Normal")..{
	Name="SongBPM",
	InitCommand=function(self) self:zoom(0.65):y(32):maxwidth(350) end,
	DrawStageCommand=function(self)
		if SongOrCourse then
			local MusicRate = SL.Global.Stages.Stats[StageNum].MusicRate
			local mpn = GAMESTATE:GetMasterPlayerNumber()
			local StepsOrTrail = SL[ToEnumShortString(mpn)].Stages.Stats[StageNum].steps
			local bpms = StringifyDisplayBPMs(mpn, StepsOrTrail, MusicRate)
			if MusicRate ~= 1 then
				-- format a string like "150 - 300 bpm (1.5x Music Rate)"
				self:settext( ("%s bpm (%gx %s)"):format(bpms, MusicRate, THEME:GetString("OptionTitles", "MusicRate")) )
			else
				-- format a string like "100 - 200 bpm"
				self:settext( ("%s bpm"):format(bpms))
			end
		end
	end
}

-- -----------------------------------------------------------------------
-- Loop through the PlayerNumber enum provided by the engine.
-- This is basically a hardcoded { "PlayerNumber_P1", "PlayerNumber_P2" }
-- and that is what we want here.
--
-- We shouldn't use something like GAMESTATE:GetHumanPlayers() because players
-- can late-join (and late-unjoin, and switch) and GetHumanPlayers() would return
-- whichever players were currently joined at the time of ScreenEvalSummary.


-- Before we get to actually populating the per-player stats, check whether we
-- should also display the name of the profile that was used to play a specific
-- song.
--
-- The rationale is that this should only be done if it helps avoid confusion.
-- If P1 and P2 were each consistently using a single profile the whole time,
-- there is no added value in displaying it. On the other hand, if either P1 or
-- P2 switched profiles over the course of the session, let's make it clear who
-- obtained which score.
local displayProfileNames = false
for player in ivalues( PlayerNumber ) do
	if #uniqueProfilesUsedForPlayer(ToEnumShortString(player)) > 1 then
		displayProfileNames = true
		break
	end
end


-- Finally, load the actors that will populate the actual player-specific stats.
for player in ivalues( PlayerNumber ) do
	-- PlayerStageStats.lua handles player-specific things
	-- like stepchart difficulty, stepartist, letter grade, and judgment breakdown
	t[#t+1] = LoadActor("./PlayerStageStats.lua", {player, displayProfileNames})
end

return t
