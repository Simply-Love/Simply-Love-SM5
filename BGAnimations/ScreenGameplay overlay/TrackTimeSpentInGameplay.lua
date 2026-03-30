-- We want to be able to display the time spent in gameplay across the entire set
-- for ScreenGameover.  We could call GAMESTATE:GetCurrentSong():MusicLengthSeconds(),
-- store that, and sum each value at ScreenGameover, but that wouldn't (easily) handle
-- early quitting/escaping out of songs accurately.
--
-- So instead, calculate the duration of time actually spent in ScreenGameplay when its
-- OffCommand is called.
------------------------------------------------------------

local player = ...

local actor = Def.Actor{
	OnCommand=function(self)
		if not start_time or start_time == -1 then
			start_time = GetTimeSinceStart()
		end
	end,
	OffCommand=function(self)
		SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].duration = GetTimeSinceStart() - start_time
		start_time = -1
	end
}

return actor