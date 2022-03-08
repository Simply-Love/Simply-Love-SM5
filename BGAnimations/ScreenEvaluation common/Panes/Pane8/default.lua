-- Pane8 displays the FA+ centric score out of a possible 100.00
-- aggregate judgment counts (overall W1, overall W2, overall miss, etc.)
-- and judgment counts on holds, mines, rolls

-- We only want to use this in ITG mode.
-- In FA+ mode this is handled by Pane 1
-- We don't want this version n casual mode at all.
if SL.Global.GameMode ~= "ITG" then
	return
end

return Def.ActorFrame{

	-- score displayed as a percentage
	LoadActor("./Percentage.lua", ...),

	-- labels like "FANTASTIC", "MISS", "holds", "rolls", etc.
	LoadActor("./JudgmentLabels.lua", ...),

	-- numbers (How many Fantastics? How many Misses? etc.)
	LoadActor("./JudgmentNumbers.lua", ...),
}