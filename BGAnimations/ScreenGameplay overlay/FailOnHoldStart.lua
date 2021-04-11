-- We need a way to check if the player gave up before the song properly ended.
-- It doesn't look like the engine broadcasts any messages that would be helpful here,
-- so we do the best we can by checking the song position.

local af = Def.ActorFrame{
	OffCommand=function(self)
		local fail = (GAMESTATE:GetCurMusicSeconds() < GAMESTATE:GetCurrentSong():GetLastSecond())

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
		if fail then
			-- Let's fail the bots as well.
			for player in ivalues( GAMESTATE:GetEnabledPlayers() ) do
				local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
				pss:FailPlayer()
			end
		end
	end,
}

return af
