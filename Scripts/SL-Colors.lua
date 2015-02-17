function PlayerColor( pn )
	if pn == PLAYER_1 then return DifficultyIndexColor(3) end
	if pn == PLAYER_2 then return DifficultyIndexColor(1) end
	return color("1,1,1,1")
end

function SimplyLoveColor()
	local slc = ThemePrefs.Get("SimplyLoveColor") or 1
	return tonumber(slc)
end

function SetSimplyLoveColor( c )
	ThemePrefs.Set("SimplyLoveColor", c)
	MESSAGEMAN:Broadcast("ColorSelected")
end

function GetHexColor( n )
	if SL.Colors[n] then return color(SL.Colors[n]) end
	return color("#ffffff")
end


function GetCurrentColor()
	local n = (SimplyLoveColor() % #SL.Colors)+1
	return GetHexColor(n)
end

function DifficultyColor( difficulty )

	if  difficulty  == "Difficulty_Edit" then return color("#B4B7BA") end
	local index = GetYOffsetByDifficulty(difficulty)

	return DifficultyIndexColor(index)
end


function GetYOffsetByDifficulty(difficulty)
	-- Use Enum's reverse lookup functionality to find difficulty by index
	-- note: this is 0 indexed, so Beginner is 0, Challenge is 4, and Edit is 5
	-- for our purposes, increment by one here
	local offset = Difficulty:Reverse()[difficulty] + 1

	if difficulty  == "Difficulty_Edit" then
		offset = 5
	end

	return offset
end

-- These are almost certainly inflexible with regard to the total
-- number of available colors to chose from...
function DifficultyIndexColor( i )
	local clr = i + SimplyLoveColor() + 9
	clr = clr % #SL.Colors + 1
	return GetHexColor(clr)
end

function ColorRGB ( n )
	local clr = n + SimplyLoveColor() + #SL.Colors - 1
	clr = (clr % #SL.Colors) + 1
	return GetHexColor(clr)
end