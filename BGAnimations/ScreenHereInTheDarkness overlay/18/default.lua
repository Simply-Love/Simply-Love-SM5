-- 31 March 2018
-- A Beige Colored Bookmark

local padding = 22
local max_width = 260
local max_height = 390
local font_zoom = 0.785

local time_at_start, rain
local rain_loops = 1
local rain_duration = (5*60) + 47.01575

local pages = {}
local page = 1
local book = LoadActor("./a-beige-colored-bookmark.lua")

-- initialize pages data structure
local InitializePages = function(page_bmt)

	for chapter in ivalues(book) do

		pages[#pages+1] = ""
		page_bmt:settext("")

		for page in ivalues(chapter) do
			for word in page:gmatch("%S*") do

				page_bmt:settext( pages[#pages] .. " " .. word )

				-- if we haven't exceeded page height, add this word to the page
				if page_bmt:GetHeight() < max_height/font_zoom then
					pages[#pages] = pages[#pages] .. " " .. word

				else
					pages[#pages+1] = word
					page_bmt:settext( word )
				end
			end

			pages[#pages] = pages[#pages] .. "\n\n"
		end
	end
end

local update = function(af, dt)
	-- loop rain.ogg while needed
	if type(time_at_start) == "number" then
		if (GetTimeSinceStart() - time_at_start) > (rain_duration * rain_loops) then
			rain:queuecommand("On")
			rain_loops = rain_loops + 1
		end
	end
end

-- ---------------------------------------------------------------
local af = Def.ActorFrame{}

af.InitCommand=function(self) self:zoom(0.95):xy(20,12):diffuse(0,0,0,1):SetUpdateFunction( update ) end
af.OnCommand=function(self)
	time_at_start = GetTimeSinceStart()
	self:sleep(1):smooth(1):diffuse(1,1,1,1)
end

af.CloseCommand=function(self) self:smooth(2):diffuse(0,0,0,1):queuecommand("Off"):queuecommand("NextScreen") end
af.NextScreenCommand=function(self)
	rain:stop()
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

af.InputEventCommand=function(self, event)
	if type(event) ~= "table" then return end

	if event.type == "InputEventType_FirstPress" then

		if event.GameButton=="Back" or event.GameButton=="Select" then
			self:queuecommand("NextScreen")

		elseif event.GameButton=="Start" or event.GameButton == "MenuRight" then
			if page + 2 < #pages then
				page = page + 2
				self:queuecommand("Refresh")
			else
				self:queuecommand("Close")
			end

		elseif event.GameButton == "MenuLeft" then
			if page - 2 > 0 then
				page = page - 2
				self:queuecommand("Refresh")
			end
		end
	end
end
-- ---------------------------------------------------------------

af[#af+1] = LoadActor("./rain.ogg")..{
	InitCommand=function(self) rain = self end,
	OnCommand=function(self)   self:stop():queuecommand("Play") end,
	PlayCommand=function(self) self:play() end
}

af[#af+1] =	LoadActor("./pages.png")..{
	InitCommand=function(self) self:zoom(0.54):Center() end,
}


-- left
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/palatino/_palatino 20px.ini"),
	InitCommand=function(self)
		self:zoom(font_zoom):wrapwidthpixels(max_width/font_zoom):vertspacing(-4)
		self:xy(WideScale(padding*2, padding*6.5), padding*2):align(0,0):diffuse(color("#603e25"))

		InitializePages(self)
		self:settext(""):queuecommand("Refresh")
	end,
	RefreshCommand=function(self)
		self:settext(pages[page])
	end,
}

-- right
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/palatino/_palatino 20px.ini"),
	InitCommand=function(self)
		self:zoom(font_zoom):wrapwidthpixels(max_width/font_zoom):vertspacing(-4)
		self:xy(_screen.cx + padding*1.25, padding*2):align(0,0):diffuse(color("#603e25"))
		self:settext(""):queuecommand("Refresh")
	end,
	RefreshCommand=function(self)
		self:settext(pages[page+1])
	end,
}

return af