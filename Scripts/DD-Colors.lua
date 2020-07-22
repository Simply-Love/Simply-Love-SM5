------------------------------------------------------------
-- global functions related to colors in Digital Dance

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
	if pn == PLAYER_1 then return color("#7623ba") end
	if pn == PLAYER_2 then return color("#00b5af") end
	return color("1,1,1,1")
end

function DifficultyColor( difficulty, decorative )
	if difficulty  == "Difficulty_Edit" then return color("#B4B7BA") end
	if difficulty  == "Difficulty_Challenge" then return color("#54a2ff") end
	if difficulty  == "Difficulty_Hard" then return color("#ff8080") end
	if difficulty  == "Difficulty_Medium" then return color("#fffd7d") end
	if difficulty  == "Difficulty_Easy" then return color("#78f772") end
	if difficulty  == "Difficulty_Beginner" then return color("#d48fff") end

	-- use the reverse lookup functionality available to all SM enums
	-- to map a difficulty string to a number
	-- SM's enums are 0 indexed, so Beginner is 0, Challenge is 4, and Edit is 5
	local clr = SL.Global.ActiveColorIndex + (Difficulty:Reverse()[difficulty] - 1)
	return GetHexColor(clr, decorative)
end