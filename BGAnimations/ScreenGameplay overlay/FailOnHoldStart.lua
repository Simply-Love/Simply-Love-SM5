-- Check if the player gave up before the song properly ended.

local usedAutoplay = {
	[PLAYER_1] = false,
	[PLAYER_2] = false
}

local af = Def.ActorFrame{
	JudgmentMessageCommand=function(self, params)
		if params.Player == nil then return end
		
		if IsAutoplay(params.Player) then
			usedAutoplay[params.Player] = true
		end
	end,
	OffCommand=function(self)
		-- In OutFox and newer versions of SM 5.1 there is the GaveUp()
		-- function available. For SM 5.0.12 and older SM 5.1 versions
		-- we do the best we can by checking the song position. It
		-- doesn't look like the engine broadcasts any messages that
		-- would be helpful here.
		local stage_stats = STATSMAN:GetCurStageStats()
		local fail = false
		if stage_stats.GaveUp then
			fail = stage_stats:GaveUp()
		else
			fail = (GAMESTATE:GetCurMusicSeconds() < GAMESTATE:GetCurrentSong():GetLastSecond())
		end

		-- In course mode always fail if we're not already on the last
		-- song. If we are on the last song, then we fall back to the
		-- condition above.
		if GAMESTATE:IsCourseMode() then
			local course = GAMESTATE:GetCurrentCourse()
			if GAMESTATE:GetCourseSongIndex() + 1 < course:GetNumCourseEntries() then
				fail = true
			end
		end

		-- We have to fail both players as we stopped the song early.
		for player in ivalues( GAMESTATE:GetEnabledPlayers() ) do
			if fail or usedAutoplay[player] then
				local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
				pss:FailPlayer()
			end
		end
	end,
}

return af
