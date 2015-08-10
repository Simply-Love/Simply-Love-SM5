local t = Def.ActorFrame{
	ChangeStepsMessageCommand=function(self, params)
		self:playcommand("StepsHaveChanged", {Direction=params.Direction, Player=params.Player})
	end
}

-- - - - - - - - - - - - - - - - - - - - - - - -
-- Shard screen elements

-- make the MusicWheel appear to cascade down
t[#t+1] = LoadActor("MusicWheelAnimation.lua")

-- Apply player modifiers from profile
t[#t+1] = LoadActor("PlayerModifiers.lua")

-- Banner
t[#t+1] = LoadActor("Banner.lua")

-- Song Description (Artist, BPM, Duration)
t[#t+1] = LoadActor("SongDescription.lua")

-- Difficulty Blocks
t[#t+1] = LoadActor("StepsDisplayList/Grid.lua")


-- - - - - - - - - - - - - - - - - - - - - - - -
-- Per-player screen elements

for player in ivalues({PLAYER_1, PLAYER_2}) do

	-- StepArtist Box
	t[#t+1] = LoadActor("StepArtist.lua", player)

	-- bouncing Cursor inside the Grid of difficulty blocks
	t[#t+1] = LoadActor("PerPlayer/Cursor.lua", player)

	-- Step Data (Number of steps, jumps, holds, etc.)
	t[#t+1] = LoadActor("PerPlayer/PaneDisplay.lua", player)
end
-- - - - - - - - - - - - - - - - - - - - - - - -

-- the fadeout that informs users to press START if they want options
t[#t+1] = LoadActor("fadeOut.lua")

return t