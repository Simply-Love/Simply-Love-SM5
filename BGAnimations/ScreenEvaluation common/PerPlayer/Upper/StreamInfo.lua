local player = ...
local pn = ToEnumShortString(player)
local streamMeasures, breakMeasures, totalMeasures

if not GAMESTATE:IsCourseMode() then
	streamMeasures, breakMeasures = GetTotalStreamAndBreakMeasures(pn)
	totalMeasures = streamMeasures + breakMeasures
end

local marquee_index = 0

return LoadFont("Common Normal")..{
	InitCommand=function(self) self:zoom(0.7):xy(150,_screen.cy-95) end,
	OnCommand=function(self)
		local textColor = Color.White
		local shadowLength = 1
		if not GAMESTATE:IsCourseMode() and streamMeasures/breakMeasures >= 0.2 then
			local mini = 1
			self:settext(GenerateBreakdownText(pn, mini))
			
			while self:GetWidth() > SCREEN_WIDTH * 2 / 5 do
				mini = mini + 1
				self:settext(GenerateBreakdownText(pn, mini))
			end
			
			if mini == 3 then
				self:settext(GenerateBreakdownText(pn, 3) .. string.format(" (%0.2f%%)", streamMeasures/totalMeasures*100))
			end
		end
		if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
			textColor = Color.Black
		end
		self:diffuse(textColor)
		self:shadowlength(shadowLength)

		if player == PLAYER_1 then
			self:x( self:GetX() * -1 )
			self:horizalign(left)
		else
			self:horizalign(right)
		end
	end
}
