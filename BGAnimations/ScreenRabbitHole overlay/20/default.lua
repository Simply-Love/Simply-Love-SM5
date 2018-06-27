local page = 1
local pages = {
	{
		header="Credits",
		body="Rabbit Hole #1\nfeatures audio from the film 5cm Per Second\n\nRabbit Hole #3\nfeatures a photograph of Earth that I can no longer track down the source of :(\n\nRabbit Hole #6\nfeatures video from YouTube user maxxlover's channel\n\nRabbit Hole #8\nfeatures visual art from xkcd#1190, \"Time\"\n\nRabbit Hole #10\nfeatures the song \"13 Ghosts II\" by nine inch nails\n\nRabbit Hole #12\nfeatures a melody inspired The Antikythera Mechanism by bt"
	},
	{
		header="Credits: Rabbit Holes #14-17 (Connection)",
		body="luizsan – contributed primary visual art\n\nmahendor – composed Connection's main theme\n\nLumisauVA - voice acted in Chapter 4\n\nkbts – contributed visual art to Chapter 3\n\nEvocait - contrbuted visual art to Chapter 4"
	},
	{
		header="Thanks",
		body=""
	}
}


local af = Def.ActorFrame{

	InitCommand=function(self) self:diffuse(0,0,0,1) end,
	OnCommand=function(self) self:smooth(1):diffuse(1,1,1,1) end,

	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			if pages[page+1] then
				page = page + 1
				self:GetChild("Header"):finishtweening():smooth(0.25):diffuse(0,0,0,1):sleep(0.25):queuecommand("Refresh")
				self:GetChild("Body"):finishtweening():smooth(0.25):diffuse(0,0,0,1):sleep(0.25):queuecommand("Refresh")
			else
				self:finishtweening():smooth(0.5):diffuse(0,0,0,1):queuecommand("Transition")
			end
		end
	end,
	TransitionCommand=function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}


af[#af+1] = Def.BitmapText{
	Name="Header",
	Text=pages[1].header,
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	InitCommand=function(self) self:vertalign(top):xy(_screen.cx, 20):zoom(1.2) end,
	RefreshCommand=function(self) self:settext(pages[page].header):smooth(0.25):diffuse(1,1,1,1) end
}

af[#af+1] = Def.BitmapText{
	Name="Body",
	Text=pages[1].body,
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	InitCommand=function(self) self:align(0,0):xy(_screen.cx-240, 60):wrapwidthpixels(480/0.9):zoom(0.85) end,
	RefreshCommand=function(self) self:settext(pages[page].body):smooth(0.25):diffuse(1,1,1,1) end
}


return af