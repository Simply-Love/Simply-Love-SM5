------------------------------------------------------------
-- global functions related to colors in Simply Love

function GetHexColor( n, decorative, ITGdiff )
	-- if we were passed nil or a non-number, return white
	if n == nil or type(n) ~= "number" then return Color.White end

	local style = ThemePrefs.Get("VisualStyle")
	local colorTable = SL.Colors
	if ITGdiff then 
		colorTable = SL.ITGDiffColors
	end
	if decorative then
		colorTable = SL.DecorativeColors
	end
	if style == "SRPG7" then
		colorTable = SL.SRPG7.Colors
	end

	-- use the number passed in to lookup a color in the corresponding color table
	-- ensure the index is kept in bounds via modulo operation
	local clr = ((n - 1) % #colorTable) + 1
	if colorTable[clr] then
		local c = color(colorTable[clr])
		if style == "SRPG7" and not decorative then
			c = LightenColor(c)
		end
		return c
	end

	return Color.White
end

-- convenience function to return the current color from SL.Colors
function GetCurrentColor( decorative )
	return GetHexColor( SL.Global.ActiveColorIndex, decorative )
end

function PlayerColor( pn, decorative )
	if pn == PLAYER_1 then return GetHexColor(SL.Global.ActiveColorIndex, decorative) end
	if pn == PLAYER_2 then return GetHexColor(SL.Global.ActiveColorIndex-2, decorative) end
	return Color.White
end

function DifficultyColor( difficulty, decorative )
	if (difficulty == nil or difficulty == "Difficulty_Edit") then return color("#B4B7BA") end
	local useITGcolors = ThemePrefs.Get("ITGDiffColors")

	-- use the reverse lookup functionality available to all SM enums
	-- to map a difficulty string to a number
	-- SM's enums are 0 indexed, so Beginner is 0, Challenge is 4, and Edit is 5
	local clr = SL.Global.ActiveColorIndex + (Difficulty:Reverse()[difficulty] - 4)
	if useITGcolors then
		clr = Difficulty:Reverse()[difficulty] - 4
	end
	return GetHexColor(clr, decorative, useITGcolors)
end

function LightenColor(c)
	return { c[1]*1.25, c[2]*1.25, c[3]*1.25, c[4] }
end
