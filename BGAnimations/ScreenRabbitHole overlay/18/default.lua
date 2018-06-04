-- a beige colored bookmark
local padding = 22
local max_width = 260
local max_height = 390
local font_zoom = 0.785

local pages = {}
local page = 1
local book = LoadActor("./a-beige-colored-bookmark.lua")

local left_page

-- initialize pages
local InitializePages = function()

	for _chapter in ivalues(book) do

		pages[#pages+1] = ""
		left_page:settext("")

		for _page in ivalues(_chapter) do

			for _word in _page:gmatch("%S*") do

				left_page:settext( pages[#pages] .. " " .. _word )

				-- if we haven't exceeded page height, add this word to the page
				if left_page:GetHeight() < max_height/font_zoom then
					pages[#pages] = pages[#pages] .. " " .. _word

				else
					pages[#pages+1] = _word
					left_page:settext( _word )
				end
			end

			pages[#pages] = pages[#pages] .. "\n\n"
		end
	end
end


local af = Def.ActorFrame{
	InitCommand=function(self) self:zoom(0.95):xy(20,12):diffuse(0,0,0,1) end,
	OnCommand=function(self) self:sleep(1):smooth(1):diffuse(1,1,1,1) end,
	CloseCommand=function(self) self:smooth(2):diffuse(0,0,0,1):queuecommand("Off"):queuecommand("Transition") end,
	TransitionCommand=function(self) SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen") end,

	InputEventCommand=function(self, event)

		if event.type == "InputEventType_FirstPress" then

			if event.GameButton=="Start" or event.GameButton=="Back" then
				SCREENMAN:GetTopScreen():playcommand("Off"):StartTransitioningScreen("SM_GoToNextScreen")

			elseif event.GameButton == "MenuRight" then
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
	end,

	Def.Sound{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/18/rain.ogg"),
		InitCommand=function(self)
			self:get():volume(0.65)
		end,
		OnCommand=function(self) self:stoptweening():stop():queuecommand("Play") end,
		PlayCommand=function(self)
			self:play():sleep(71):queuecommand("Play")
		end,
		OffCommand=function(self) self:stoptweening():stop() end
	},

	Def.Sound{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/18/rain.ogg"),
		InitCommand=function(self)
			self:get():volume(0.5)
		end,
		OnCommand=function(self) self:stoptweening():stop():sleep(45):queuecommand("Play") end,
		PlayCommand=function(self)
			self:play():sleep(71):queuecommand("Play")
		end,
		OffCommand=function(self) self:stoptweening():stop() end
	}
}

af[#af+1] =	Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/18/pages.png"),
	InitCommand=function(self) self:zoom(0.54):Center() end,
}


-- left
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/palatino/_palatino 20px.ini"),
	InitCommand=function(self)
		left_page = self

		self:zoom(font_zoom):wrapwidthpixels(max_width/font_zoom):vertspacing(-4)
			:xy(WideScale(padding*2, padding*6.5), padding*2):align(0,0):diffuse(color("#603e25"))

		InitializePages()
		self:settext(""):queuecommand("Refresh")
	end,
	RefreshCommand=function(self)
		self:settext(pages[page])
	end,
	CloseCommand=function(self) self:settext("") end
}

-- right
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/palatino/_palatino 20px.ini"),
	InitCommand=function(self)
		self:zoom(font_zoom):wrapwidthpixels(max_width/font_zoom):vertspacing(-4)
			:xy(_screen.cx + padding*1.25, padding*2):align(0,0):diffuse(color("#603e25"))
			:settext(""):queuecommand("Refresh")
	end,
	RefreshCommand=function(self)
		self:settext(pages[page+1])
	end,
	CloseCommand=function(self) self:settext("") end
}

return af