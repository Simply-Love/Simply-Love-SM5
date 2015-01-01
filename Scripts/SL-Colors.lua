-- Stick the colors in a table, not an elseif chain, so the language can tell
-- you how many you have, and you can look them up more easily.
local SimplyColors= {
	hex= {
		color("#FF3C23"),
		color("#FF003C"),
		color("#C1006F"),
		color("#8200A1"),
		color("#413AD0"),
		color("#0073FF"),
		color("#00ADC0"),
		color("#5CE087"),
		color("#AEFA44"),
		color("#FFFF00"),
		color("#FFBE00"),
		color("#FF7D00"),
	},
	difficulty_index= {
		color("#FF7D00"),
		color("#FF3C23"),
		color("#FF003C"),
		color("#C1006F"),
		color("#8200A1"),
		color("#413AD0"),
		color("#0073FF"),
		color("#00ADC0"),
		color("#5CE087"),
		color("#AEFA44"),
		color("#FFFF00"),
		color("#FFBE00"),
	},
	rgb= {
		color("1,0.49,0,1"),
		color("1,0.24,0.14,1"),
		color("1,0,0.24,1"),
		color("0.76,0,0.44,1"),
		color("0.51,0,0.63,1"),
		color("0.25,0.23,0.82,1"),
		color("0,0.45,1,1"),
		color("0,0.68,0.75,1"),
		color("0.36,0.88,0.53,1"),
		color("0.68,0.98,0.27,1"),
		color("1,1,0,1"),
		color("1,0.75,0,1"),
	},
}

function PlayerColor( pn )
	if pn == PLAYER_1 then return DifficultyIndexColor(3) end
	if pn == PLAYER_2 then return DifficultyIndexColor(1) end
	return color("1,1,1,1")
end

function DefaultColor()
	local color = SimplyLoveColor()
	if color < 10 then
		color = "0"..color
	end
	
	return color
end

-- Fun scavenger hunt:  Find all the places that depend on the number of
-- colors and change them to actually use the number of colors.  Searching for
-- "12", "6", and "5" is a good start, but "4", and "3" are also possible
-- matches.  At a minimum, ScreenSelectColor probably won't let you pick newly
-- added colors until it's fixed. -Kyz
function NumSimplyLoveColors()
	return #SimplyColors.hex
end

function SimplyLoveColor()
	return SL_CustomPrefs:get_data().SimplyLoveColor
end

function SetSimplyLoveColor( c )
	SL_CustomPrefs:get_data().SimplyLoveColor= c
	SL_CustomPrefs:set_dirty()
	MESSAGEMAN:Broadcast("ColorSelected")
end

function GetCurrentColor()
	local n = (SimplyLoveColor()%(#SimplyColors.hex))+1
	return GetHexColor(n)
end


function GetHexColor( n )
	return SimplyColors.hex[n] or color("#ffffff")
end


	
function DifficultyColor( difficulty )
	
	if  difficulty  == "Difficulty_Edit" then return color("#B4B7BA") end
	local index = GetYOffsetByDifficulty(difficulty)
	
	return DifficultyIndexColor(index)
end


function DifficultyIndexColor( i )
	local clr = i + SimplyLoveColor() + 10
	clr = math.mod(clr-1,#SimplyColors.difficulty_index)+1
	return SimplyColors.difficulty_index[clr] or color("1,1,1,1")
end


function GetYOffsetByDifficulty(difficulty)
	if  difficulty  == "Difficulty_Beginner" then
		offset = 1
	elseif difficulty  == "Difficulty_Easy" then
		offset = 2
	elseif difficulty  == "Difficulty_Medium" then
		offset = 3
	elseif difficulty  == "Difficulty_Hard" then
		offset = 4
	elseif difficulty  == "Difficulty_Challenge" then
		offset = 5
	elseif difficulty  == "Difficulty_Edit" then
		offset = 5
	end
	
	return offset
end





function ColorRGB ( n )
	local clr = n + SimplyLoveColor() + 12
	clr = math.mod(clr-1,#SimplyColors.rgb)+1
	return SimplyColors.rgb[clr] or color("1,1,1,1")
end