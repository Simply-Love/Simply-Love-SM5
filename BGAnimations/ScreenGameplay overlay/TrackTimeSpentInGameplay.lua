-- We want to be able to display the time spent in Gameplay across the entire set
-- for ScreenGameover.  We could call GAMESTATE:GetCurrentSong():MusicLengthSeconds(),
-- store that, and sum each value at ScreenGameover, but that wouldn't (easily) take
-- rate mods and quitting/backing out of songs into consideration.
--
-- So instead, calculate the duration of time actually spent in ScreenGameplay when its
-- OffCommand is called.

local player = ...
local start_time

local a = Def.Actor{
	OnCommand=function(self)
		start_time = GetTimeSinceStart()
	end,
	OffCommand=function(self)
		SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].duration = GetTimeSinceStart() - start_time
	end
}

return a