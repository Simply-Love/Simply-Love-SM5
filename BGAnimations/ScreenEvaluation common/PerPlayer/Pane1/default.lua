local player = ...

return Def.ActorFrame{
	Name="Pane1",

	-- labels (like "FANTASTIC, MISS, holds, rolls, etc.")
	LoadActor("./JudgmentLabels.lua", player),

	-- DP score displayed as a percentage
	LoadActor("./Percentage.lua", player),

	-- numbers (how many Fantastics? How many misses? etc.)
	LoadActor("./JudgmentNumbers.lua", player),
}