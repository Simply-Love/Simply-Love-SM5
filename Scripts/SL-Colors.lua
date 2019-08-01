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
	--
	if (difficulty == nil or difficulty == "Difficulty_Edit") then return color("#B4B7BA") end

	local index = GetYOffsetByDifficulty(difficulty)
	local clr = SL.Global.ActiveColorIndex + (index-2)
	return GetHexColor(clr)
end

-- FIXME: this should probably reside somewhere more sensible than SL-Colors.lua
function GetYOffsetByDifficulty(difficulty)

	-- FIXME: Why is this hardcoded to 5?  I need to look into this and either change
	-- it or leave a note explaining why it's this way.
	if difficulty == "Difficulty_Edit" then return 5 end

	-- Use Enum's reverse lookup functionality to find difficulty by index
	-- note: this is 0 indexed, so Beginner is 0, Challenge is 4, and Edit is 5
	-- for our purposes, increment by one here
	return Difficulty:Reverse()[difficulty] + 1
end