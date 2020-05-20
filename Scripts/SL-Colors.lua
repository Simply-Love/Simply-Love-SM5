------------------------------------------------------------
-- global functions related to colors in Simply Love

function GetHexColor( n, decorative )
	-- if we were passed nil or a non-number, return white
	if n == nil or type(n) ~= "number" then return Color.White end

	local clrTbl = SL.Colors
	if decorative then
		clrTbl = SL.DecorativeColors
	end

	-- use the number passed in to lookup a color in the corresponding color table
	-- ensure the index is kept in bounds via modulo operation
	local clr = ((n - 1) % #clrTbl) + 1
	if clrTbl[clr] then
		return color(clrTbl[clr])
	end

	return Color.White
end

-- convenience function to return the current color from SL.Colors
function GetCurrentColor( decorative )
	return GetHexColor( SL.Global.ActiveColorIndex, decorative )
end

function PlayerColor( pn, decorative )
	if pn == PLAYER_1 then return GetHexColor(SL.Global.ActiveColorIndex+1, decorative) end
	if pn == PLAYER_2 then return GetHexColor(SL.Global.ActiveColorIndex-1, decorative) end
	return Color.White
end

function DifficultyColor( difficulty, decorative )
	if (difficulty == nil or difficulty == "Difficulty_Edit") then return color("#B4B7BA") end

	local index = GetDifficultyIndex(difficulty)
	local clr = SL.Global.ActiveColorIndex + (index-2)
	return GetHexColor(clr, decorative)
end