-- Pane1 displays the player's score out of a possible 100.00
-- aggregate judgment counts (overall W1, overall W2, overall miss, etc.)
-- and judgment counts on holds, mines, hands, rolls
--
-- Pane1 is the what the original Simply Love for SM3.95 shipped with.

local player = ...

return Def.ActorFrame{
	Name="Pane1",

	-- labels like "FANTASTIC", "MISS", "holds", "rolls", etc.
	LoadActor("./JudgmentLabels.lua", player),

	-- score displayed as a percentage
	LoadActor("./Percentage.lua", player),

	-- numbers (How many Fantastics? How many Misses? etc.)
	LoadActor("./JudgmentNumbers.lua", player),
}