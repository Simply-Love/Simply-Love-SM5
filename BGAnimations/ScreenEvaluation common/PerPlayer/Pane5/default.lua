local player = ...

local qrcode_size = 168
local url = "https://www.youtube.com/watch?v=FMABVVk4Ge4"

-- local urls = {
-- 	"https://www.youtube.com/watch?v=M0U73NRSIkw",
-- 	"https://www.youtube.com/watch?v=b1FqZCtc_W8",
-- 	"https://www.youtube.com/watch?v=9ZX_XCYokQo",
-- 	"https://www.youtube.com/watch?v=Q6Qa93JQxg4",
-- 	"https://www.youtube.com/watch?v=YmQKsHJxE-o",
-- 	"https://www.youtube.com/watch?v=2fA54tY7hO8",
-- 	"https://www.youtube.com/watch?v=TrJYUJp3veo",
-- 	"https://www.youtube.com/watch?v=FB0ycTd2U-0",
-- 	"https://www.youtube.com/watch?v=F56so48ChtM",
-- 	"http://www.lettersofnote.com/2009/12/we-have-message-from-another-world.html",
-- 	"http://www.lettersofnote.com/2012/03/i-am-very-real.html",
-- 	"http://www.lettersofnote.com/2012/11/our-differences-unite-us.html",
-- 	"https://en.wikipedia.org/wiki/David_Hilbert#The_23_problems",
-- }
-- local url = urls[math.random(#urls)]


-- ------------------------------------------

local pane = Def.ActorFrame{
	Name="Pane5",
	InitCommand=function(self)
		self:visible(false)
	end
}

pane[#pane+1] = qrcode_amv( url, qrcode_size )..{
	OnCommand=function(self)
		self:xy(-28,190)
	end
}

pane[#pane+1] = LoadActor("../Pane2/Percentage.lua", player)

pane[#pane+1] = LoadFont("_miso")..{
	Text="GrooveStats QR",
	InitCommand=function(self) self:xy(-140, 222):align(0,0) end
}

pane[#pane+1] = Def.Quad{
	InitCommand=function(self) self:xy(-140, 245):zoomto(96,1):align(0,0):diffuse(1,1,1,0.33) end
}

pane[#pane+1] = LoadFont("_miso")..{
	Text="Scan with your phone to upload this score to your GrooveStats account.",
	InitCommand=function(self) self:zoom(0.8):xy(-140,255):wrapwidthpixels(96/0.8):align(0,0):vertspacing(-4) end
}

pane[#pane+1] = LoadFont("_miso")..{
	Text="Coming Soon!",
	InitCommand=function(self) self:zoom(0.85):xy(-140,344):wrapwidthpixels(145/0.85):align(0,0):vertspacing(-4) end
}

return pane