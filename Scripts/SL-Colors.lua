function PlayerColor( pn )
	if pn == PLAYER_1 then return DifficultyIndexColor(3) end
	if pn == PLAYER_2 then return DifficultyIndexColor(1) end
	return color("1,1,1,1")
end

function GetHexColor( n )
	if SL.Colors[n] then
		return color(SL.Colors[n])

	-- if passed an index that returns nil, wrap the index using modulus
	elseif SL.Colors[(n % #SL.Colors) + 1] then
		return color( SL.Colors[(n % #SL.Colors) + 1] )

	end

	-- if we were passed nil or a non-integer, return white
	return Color.White
end


function GetCurrentColor()
	return GetHexColor( SL.Global.ActiveColorIndex )
end

function DifficultyColor( difficulty )

	if  difficulty  == "Difficulty_Edit" then return color("#B4B7BA") end
	local index = GetYOffsetByDifficulty(difficulty)

	return DifficultyIndexColor(index)
end


function GetYOffsetByDifficulty(difficulty)

	if difficulty == "Difficulty_Edit" then
		return 5
	else
		-- Use Enum's reverse lookup functionality to find difficulty by index
		-- note: this is 0 indexed, so Beginner is 0, Challenge is 4, and Edit is 5
		-- for our purposes, increment by one here
		return Difficulty:Reverse()[difficulty] + 1
	end

	return 1
end

-- These are almost certainly inflexible with regard to the total
-- number of available colors to chose from...
function DifficultyIndexColor( i )
	local clr = i + SL.Global.ActiveColorIndex + 9
	clr = clr % #SL.Colors + 1
	return GetHexColor(clr)
end

function ColorRGB ( n )
	local clr = n + SL.Global.ActiveColorIndex + #SL.Colors - 1
	clr = (clr % #SL.Colors) + 1
	return GetHexColor(clr)
end