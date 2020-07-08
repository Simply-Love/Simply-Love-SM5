local page = 1
local pages = {
	{
		header="Credits",
		body="darkness #1\nfeatures audio from the film 5 Centimeters per Second\n\ndarkness #3\nfeatures a photograph of Earth that I can no longer track down the source of :(\n\ndarkness #6\nfeatures video from YouTube user maxxlover's channel\n\ndarkness #8\nfeatures visual art from xkcd#1190, \"Time\"\n\ndarkness #10\nfeatures the song \"13 Ghosts II\" by nine inch nails\n\ndarkness #12\nfeatures a melody inspired by bt's \"The Antikythera Mechanism\""
	},
	{
		header="Credits: darknesss #14–17 (Connection)",
		body="Luizsan – contributed primary visual art\n\nMahendor – composed Connection's main theme\n\nLumisauVA – voice acted in Chapter 4\n\nkbts87 – contributed visual art to Chapter 3\n\nEvocait – contributed visual art to Chapter 4"
	},
	{
		header="Credits: darkness #19 (Your Drifting Mind)",
		body="Evocait – contributed primary visual art\n\nanairis_q – provided voice acting"
	},
	{
		header="Thanks",
		body="I wish to thank the many creative humans whose works have shaped my human outlook and my artistic output, including:\n\nMakoto Shinkai, Charlie Kaufman, Greta Gerwig, Wong Kar-wai\n\nSylvia Plath, Kazuo Ishiguro, Milan Kundera,\nMark Z. Danielewski, _why\n\nBill Watterson, Randall Munroe\n\nbt, Benn Jordan, Laura Shigihara, Trent Reznor, Frédéric Chopin\n\nMeine Meinung, Caliko, Mahendor\n\nGiant Sparrow, Kojima Productions, Unburnt Witch,\nRyan and Amy Green"
	},
	{
		header="Thanks",
		body="If you've made it this far, thanks for staying with me,\nhere in the darkness, for a while.\n\nIt means the world to me."
	}
}

local Cancel = function(self)
	self:finishtweening():smooth(0.5):diffuse(0,0,0,1):queuecommand("Transition")
end
local ChangePage = function(self)
	self:GetChild("Header"):finishtweening():smooth(0.2):diffuse(0,0,0,1):sleep(0.2):queuecommand("Refresh")
	self:GetChild("Body"):finishtweening():smooth(0.2):diffuse(0,0,0,1):sleep(0.2):queuecommand("Refresh")
end

local af = Def.ActorFrame{

	InitCommand=function(self) self:diffuse(0,0,0,1) end,
	OnCommand=function(self) self:smooth(1):diffuse(1,1,1,1) end,

	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" then
			if event.GameButton=="Start" or event.GameButton=="MenuRight" then
				if pages[page+1] then
					page = page + 1
					ChangePage(self)
				else
					Cancel(self)
				end

			elseif event.GameButton=="MenuLeft" then
				if pages[page-1] then
					page = page - 1
					ChangePage(self)
				end

			elseif event.GameButton=="Back" then
				Cancel(self)
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
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	InitCommand=function(self) self:vertalign(top):xy(_screen.cx, 30):zoom(1.2) end,
	RefreshCommand=function(self) self:settext(pages[page].header):smooth(0.25):diffuse(1,1,1,1) end
}

af[#af+1] = Def.BitmapText{
	Name="Body",
	Text=pages[1].body,
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	InitCommand=function(self) self:align(0,0):xy(_screen.cx-240, 80):wrapwidthpixels(480/0.85):zoom(0.85) end,
	RefreshCommand=function(self) self:settext(pages[page].body):smooth(0.25):diffuse(1,1,1,1) end
}


return af