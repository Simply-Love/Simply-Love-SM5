-- Listening to the chord transitions in River by Alexandre Desplat, I can sense that
-- they are simple and un-extraordinary, yet I remain completely unable to articulate
-- what are they, how they work, and why they move me. How can I possibly ever yield
-- similar results?
--
-- This must be what the illiterate feel when they are told of a certain book's beauty,
-- able to believe but lacking the capacity to experience it firsthand.

local max_width = 350
local quote_bmt

local af = Def.ActorFrame{
	InitCommand=function(self) self:diffuse(0,0,0,1) end,
	OnCommand=function(self) self:smooth(1):diffuse(1,1,1,1) end,
	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text="There's no dragons in his books,\nonly metaphysical despair.\n\n-anon",
	InitCommand=function(self)
		quote_bmt = self
		self:wrapwidthpixels(max_width)
			:Center():addx(-self:GetWidth()/2):halign(0)
			:addy(-self:GetHeight()/2)
	end,
}

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0.5, 0.5, 0.5, 1) end,
	OnCommand=function(self)
		self:zoomto(2, quote_bmt:GetHeight()):Center()
			:addx(-quote_bmt:GetWidth()/2 - 14)
			:addy(-quote_bmt:GetHeight()/2)
	end
}

return af