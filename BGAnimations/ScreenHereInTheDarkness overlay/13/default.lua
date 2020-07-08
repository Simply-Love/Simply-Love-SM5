-- There are many ways I could describe the differences between other places I've
-- lived and Pittsburgh, but the one that impacts me the most is the number of
-- homeless people I observe in a given day.
--
-- There's a routine to most of it. There are specific locations I expect to see
-- specific people – outside the Forbes Ave. McDonald's, or under the Birmingham
-- bridge – and I expect them to hold up a cup as I pass by and ask if I can spare
-- "a buck or three? I just need to get home. Three dollars is all I need for the bus."
--
-- The stories they don't tell me – the ones I see in their sunburn and torn clothing –
-- tug at my heart, and I carry one dollar bills with me everywhere, going through
-- twenty-five or so a week.
--
-- There is one homeless man who half-reclines outside of the local Rite Aid every day,
-- in sun and rain and snow alike. He looks sixty given his beard and facial creases,
-- but is probably more like fifty. He has a cup for money, but I've never seen him say
-- anything to anyone or even acknowledge a passerby's existence. When I pass by him,
-- his stare is fixed calmly on a point slightly above the horizon, his lips forming a
-- half-smile. I often wonder what occupies his mind.
--
-- A small, makeshift cardboard sign is typically in front of him with a handwritten
-- message that changes every few days. Last week it said something about North Korea.
-- Yesterday it read "President Trump wants to feed our children to crocodiles."
--
-- Today, as I approached from a block away, I could see him in his expected position –
-- back leaning against Rite Aid's brick exterior, legs inside his sleeping bag, left
-- hip and elbow supporting him against the concrete sidewalk. A young mother and her
-- four-year-old daughter were approaching from the opposite direction. Their clasped
-- hands were swinging blithely back and forth and I slowed my pace to let them pass
-- the homeless man first.
--
-- At that moment, a passing bus discharged its air brake pressure in a loud, pneumatic
-- tsssssss, causing the young girl to jump and exclaim in surprise. Her mother looked
-- down and asked, "are you okay?"
--
-- The girl was already fine; she smiled and giggled, "it was loud!"
--
-- "Yeah, it caught you off-guard, didn't it?" her mother responded, smiling as well.
--
-- From a quarter block away, I observed the homeless man's gaze turn to meet the mother
-- and daughter and their exchange, a pure smile breaking across his lips.


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
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text="Sometimes I think I have it bad. Difficult classes, angry professors, a turbulent past, a present full of self-hate, a propensity to hurt people through selfish decisions, an out of control mind.\n\nSometimes I walk past the man who lies sprawled on the sidewalk outside the Rite Aid pharmacy all year round, in the sun and rain and wind and snow alike. A warm bed to sleep in, an insulated apartment to exist in, new shoes to walk in.\n\n\"You have it pretty fucking good, buddy,\" is what I hear in my head, but he only smiles sincerely as I pass by each time.",
	InitCommand=function(self)
		quote_bmt = self
		self:wrapwidthpixels(max_width)
			:Center():addx(-self:GetWidth()/2):halign(0)
			:diffusealpha(0)
	end,
	OnCommand=function(self) self:sleep(0.25):smooth(0.75):diffusealpha(1) end
}

return af