-- juxaposition

local max_width = 350
local quote_bmt

local page = 1
local pages = {
   "She was partially undressed in the photo she sent me that night. Her face was obscured by the angle, but it was the first time I'd gotten any sense of what her body looked like.\n\nHer figure was slender and athletically toned, her bright pink underwear stood out in sharp contrast against her long, dark hair. If I'd been paying attention to and wanting her physical form more, I'm sure it would have checked all the boxes.\n\nBut in that moment, all I could focus on was the set of five fist-sized holes in the wall behind her. Even now, years later, when my mind scans the image it's all I can see.",
   "In that moment, I felt as though I knew where eternity, our hearts, and our souls all lay. I felt as though we had shared all the experiences of my years.\n\nAnd then, the next moment, I was filled with an insufferable sadness. Her warmth, her soul – how was I supposed to help them, and where could I take them? I did not know.\n\nI clearly saw from that point on that we would never be together.\n\n- 5cm Per Second",
}

local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			if page == 1 then
				self:queuecommand("Refresh")
			else
				SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
			end
		end
	end
}

af[#af+1] = Def.BitmapText{
	Font="_miso",
	Text=pages[1],
	InitCommand=function(self)
		quote_bmt = self
		self:wrapwidthpixels(max_width)
			:Center():addx(-self:GetWidth()/2):halign(0)
	end,
	RefreshCommand=function(self)
		self:settext( pages[2] )
		page = 2
	end
}

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(0,0):diffuse(0.5, 0.5, 0.5, 1) end,
	RefreshCommand=function(self)
		self:zoomto(2, quote_bmt:GetHeight()):Center():addx(-quote_bmt:GetWidth()/2 - 14)
	end
}

return af