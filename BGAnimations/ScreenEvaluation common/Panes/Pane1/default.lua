-- Pane1 displays the player's score out of a possible 100.00
-- aggregate judgment counts (overall W1, overall W2, overall miss, etc.)
-- and judgment counts on holds, mines, hands, rolls
--
-- Pane1 is the what the original Simply Love for SM3.95 shipped with.
local player, side = unpack(...)
local mods = SL[ToEnumShortString(player)].ActiveModifiers
-- Replace the entire pane with an encouraging picture.
if mods.DoNotJudgeMe then
	image = ThemePrefs.Get("RainbowMode") and "birbs/blue.png" or "birbs/yellow.png"
  return Def.ActorFrame{
		LoadActor(image)..{ OnCommand=function(self) self:y(_screen.cy+45):zoom(0.4) end }
	}
end

return Def.ActorFrame{

	-- labels like "FANTASTIC", "MISS", "holds", "rolls", etc.
	LoadActor("./JudgmentLabels.lua", ...),

	-- score displayed as a percentage
	LoadActor("./Percentage.lua", ...),

	-- numbers (How many Fantastics? How many Misses? etc.)
	LoadActor("./JudgmentNumbers.lua", ...),
}
