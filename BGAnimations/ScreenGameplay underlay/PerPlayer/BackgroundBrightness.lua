local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- Don't do anything if brightness is 0%
if mods.BackgroundBrightness == "0%" then return end

local function actorWidth()
	-- If one player is playing on both sides use the whole screen width
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
		return _screen.w
	end
	-- Otherwise one player takes 50% of the screen width
	return _screen.w * 0.5
end

local function xPosition(playerNumber)
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
		return _screen.cx
	end

	if playerNumber == "P1" then
		return 0 + (actorWidth() * 0.5)
	end

	if playerNumber == "P2" then
		return _screen.cx + (actorWidth() * 0.5)
	end

	return 0
end

return Def.Quad{
	InitCommand=function(self)
		local percentage = mods.BackgroundBrightness:gsub("%%","") / 100
		local color = lerp_color(percentage, Color.Black, Color.White)

		self:xy(xPosition(pn), _screen.cy)
			:diffuse(color)
			:diffusealpha(1)
			:zoomto(actorWidth(), _screen.h)
	end
}
