-- humor keeps me going
local max_width = 440
local font_zoom = 0.9
local quote_bmt

local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text="At 15:30:08 UTC on Sun, 4 December 292277026596, 64-bit versions of the Unix time stamp will cease to work, as it will overflow the largest value that can be held in a signed 64-bit number.\n\nThis is not anticipated to pose a problem, as it is considerably longer than the time it would take the Sun to theoretically expand to a red giant and swallow the Earth.\n\n-Wikipedia",
	InitCommand=function(self)
		quote_bmt = self
		self:zoom(font_zoom):wrapwidthpixels(max_width/font_zoom)
			:Center():addx(-self:GetWidth()/2):halign(0)
	end,
}

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0.5, 0.5, 0.5, 1) end,
	OnCommand=function(self)
		self:zoomto(2, quote_bmt:GetHeight()*font_zoom):Center():addx(-quote_bmt:GetWidth()/2 - 14)
	end
}

return af