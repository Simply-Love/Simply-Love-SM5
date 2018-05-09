-- sometimes, I think I have it bad

local max_width = 380
local quote_bmt

local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
}

af[#af+1] = Def.BitmapText{
	Font="_miso",
	Text="Sometimes I think I have it bad. Difficult classes, angry professors, a turbulent past, a present full of self-hate, a propensity to hurt people through selfish decisions, an out of control mind.\n\nSometimes I walk past the man who lies sprawled on the sidewalk outside the Rite Aid pharmacy all year round, in the sun and rain and wind and snow alike. A warm bed to sleep in, an insulated apartment to exist in, new shoes to walk in.\n\n\"You have it pretty fucking good, buddy,\" is what I hear in my head, but he only smiles sincerely as I pass by each time.",
	InitCommand=function(self)
		quote_bmt = self
		self:wrapwidthpixels(max_width)
			:Center():addx(-self:GetWidth()/2):halign(0)
	end,
}

return af