-- dragons
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
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
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