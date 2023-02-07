local player = ...
local pn = ToEnumShortString(player)
local streamMeasures, breakMeasures, totalMeasures

if not GAMESTATE:IsCourseMode() then
	streamMeasures, breakMeasures = GetTotalStreamAndBreakMeasures(pn)
	totalMeasures = streamMeasures + breakMeasures
	
	if streamMeasures/totalMeasures < 0.2 or streamMeasures == 0 then return end
end

return Def.ActorFrame {
	Def.Quad{
		Name="StreamBG",
		InitCommand=function(self)
			self:vertalign("VertAlign_Bottom")
			if player == PLAYER_1 then
				self:x( self:GetX() * -1 )
				self:horizalign(left)
			else
				self:horizalign(right)
			end
			self:zoomto(10,10)
			self:xy(-150,_screen.cy-95.5)

			self:diffuse( Color.Black )
			if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
				textColor = Color.White
			end
			self:diffusealpha(0.7)
		end
	},
	LoadFont("Common Normal")..{
		InitCommand=function(self) self:zoom(0.7):xy(148,_screen.cy-97):vertalign("VertAlign_Bottom") end,
		OnCommand=function(self)
			local textColor = Color.White
			local shadowLength = 1
			self:maxwidth(SCREEN_WIDTH * 26 / 100)
			if not GAMESTATE:IsCourseMode() then
				local mini = 1
				self:settext(GenerateBreakdownText(pn, mini))
				
				while self:GetWidth() > SCREEN_WIDTH * 3 / 10 do
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
			
			local w = self:GetWidth()
			local h = self:GetHeight()
			self:GetParent():GetChild("StreamBG"):SetWidth(math.min((SCREEN_WIDTH * 26 / 100),w+10)):SetHeight(h+4):zoom(0.7)
			if player == PLAYER_1 then
				self:GetParent():GetChild("StreamBG"):faderight(0.1)
			else
				self:GetParent():GetChild("StreamBG"):fadeleft(0.1)
				self:GetParent():GetChild("StreamBG"):x( self:GetParent():GetChild("StreamBG"):GetX() * -1 )
			end
		end
	}
}
