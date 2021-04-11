-- We need a way to check if the player gave up before the song properly ended.
-- It doesn't look like the engine broadcasts any messages that would be helpful here,
-- so we do the best we can by toggling a flag when the player presses START.
--
-- If the screen's OffCommand occurs while START is being held, we assume they gave up early.
-- It's certainly not foolproof, but I'm unsure how else to handle this.

local startIsBeingHeld = false

local HoldStartInputHandler = function(event)
	if event.GameButton == "Start" then
		startIsBeingHeld = event.type ~= "InputEventType_Release"
	end
end

local af = Def.ActorFrame{
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(HoldStartInputHandler)
	end,
	OffCommand=function(self)
		-- It doesn't matter who held start button, we have to fail both players as we
		-- stopped the song early.
		if startIsBeingHeld then
			-- Let's fail the bots as well.
			for player in ivalues( GAMESTATE:GetEnabledPlayers() ) do
				local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
				pss:FailPlayer()
			end
		end
	end,
}

return af