local player = ...
local pn = ToEnumShortString(player)

if GAMESTATE:IsCourseMode() then return end

local width = 155

return LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
    Text="",
	InitCommand=function(self)
		local textZoom = 0.7
        self:maxwidth(width/textZoom):zoom(textZoom):xy(150,_screen.cy-95)
        if player == PLAYER_1 then
			self:x( self:GetX() * -1 )
			self:horizalign(left)
		else
			self:horizalign(right)
		end

        local textColor = Color.White
        if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
			textColor = Color.Black
		end
        self:diffuse(textColor)
    end,
	OnCommand=function(self)
        local textZoom = 0.7
        self:settext(GenerateBreakdownText(pn, 0))
        local minimization_level = 1
        while self:GetWidth() > (width/textZoom) and minimization_level < 4 do
            self:settext(GenerateBreakdownText(pn, minimization_level))
            minimization_level = minimization_level + 1
        end
    end,
}