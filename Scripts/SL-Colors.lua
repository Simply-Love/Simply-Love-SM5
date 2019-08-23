------------------------------------------------------------
-- global functions related to colors in Simply Love

function GetHexColor( n )
	-- if we were passed nil or a non-number, return white
	if n == nil or type(n) ~= "number" then return Color.White end

	-- use the number passed in to lookup a color in the SL.Colors
	-- ensure the index is kept in bounds via modulo operation
	local clr = ((n - 1) % #SL.Colors) + 1
	if SL.Colors[clr] then
		return color(SL.Colors[clr])
	end

	return Color.White
end

-- convenience function to return the current color from SL.Colors
function GetCurrentColor()
	return GetHexColor( SL.Global.ActiveColorIndex )
end

function PlayerColor( pn )
	if pn == PLAYER_1 then return GetHexColor(SL.Global.ActiveColorIndex+1) end
	if pn == PLAYER_2 then return GetHexColor(SL.Global.ActiveColorIndex-1) end
	return Color.White
end

function DifficultyColor( difficulty )
	if (difficulty == nil or difficulty == "Difficulty_Edit") then return color("#B4B7BA") end

	local index = GetDifficultyIndex(difficulty)
	local clr = SL.Global.ActiveColorIndex + (index-2)
	return GetHexColor(clr)
end