-- love letters

local delay = 0.0735
local filename = "28.txt"
local body = "The heavy snowfall today consumes the sounds, sights, and feelings that would otherwise cue spring's anticipated approach.  With the snow comes peace in the middle of the night during a long walk to nowhere, but I have walked alone so many times this winter.  It is spring that carries the hope of something new.\n\nGazing out my ice-crusted window into the remote distance, far beyond the confines of this apartment, or this city, or my mind, I wished to convey that my thoughts are with you, that I am with you.  That is to say:\n\nToday I love you as I love standing still amidst a silent snowfall until my hair is white and I appear old.\n\nTomorrow I love you as I love the anticipation of warm breezes gently kissing the skin of my arms.\n\nI love you as I love a month's worth of love letters.\n\nThank you for being my friend.\n\nBen"

local bgm_volume = 10

-- references to actors
local bmt, tildes, cursor

-- properties of the monaco font
local char_width = 12
local char_height = 26
-- how much we'll be zooming the monaco font
local font_zoom = 0.55

-- Ben's monitor
local monitor = { w=540, h=_screen.h-100, c=color("#202020") }

-- because monaco is a monospace font, we can (more easily) calculate
-- rows and columns for Ben's terminal window
local terminal = {}
terminal.rows = 23
terminal.cols = 60
-- padding in px
terminal.padding=6
-- width and height in px
terminal.w = terminal.cols*char_width*font_zoom + terminal.padding*2
terminal.h = terminal.rows*char_height*font_zoom + terminal.padding*2

terminal.x = _screen.cx-terminal.w/2
terminal.y = _screen.cy-terminal.h/2 + terminal.padding/2
-- the topbar for Ben's terminal window
local dragbar = { w=terminal.w, h=10 }

-- two flags used for managing viewer input
local accepting_input = false
local done = false

local CountNewlines = function( s )
	local n = 0
	for newline in s:gmatch("\n") do n = n + 1 end
	return n
end

-- ----------------------------------------------------

local af = Def.ActorFrame{
	StartSceneCommand=function(self) self:visible(true):sleep(0.5):smooth(1.5):diffuse(1,1,1,1) end,
	Ch4Sc3InputEventCommand=function(self, event)
		if accepting_input then
			if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
				accepting_input = false

				if not done then
					self:queuecommand("StopAudio")
					self:GetParent():GetChild("Proceed"):stoptweening():queuecommand("Ch4Sc3Hide")
					bmt:settext( "vim ./" .. filename ):sleep(2):queuecommand("CD")
					cursor:xy( (bmt:GetText():len()+1)*char_width*font_zoom, char_width*font_zoom )
						:queuecommand("Show"):sleep(2):queuecommand("Reset")
				else
					self:GetParent():queuecommand("TransitionScene")
				end
			end
		end
	end
}

af[#af+1] = LoadActor("./love-letters.ogg")..{
	StartSceneCommand=function(self) self:sleep(0):queuecommand("Play") end,
	PlayCommand=function(self) self:play() end,
	StopAudioCommand=function(self) self:stop() end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-1
			ragesound:volume(bgm_volume*0.1)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		end
	end
}

-- "heavy snowfall today"
af[#af+1] = LoadActor("./snow.lua")

-- "my ice-crusted window"
af[#af+1] = LoadActor("./frost.png")..{
	InitCommand=function(self) self:xy(_screen.cx,0):zoomto(_screen.w, _screen.h-30):valign(0) end,
}

-- blinds
af[#af+1] = LoadActor("./blind.png")..{
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy-100):zoomtoheight(_screen.h-40):zoomtowidth(_screen.w):customtexturerect(0,0,1,12) end,
}
-- blind strings - left
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:xy(30, 0):valign(0):zoomto(2, _screen.h-120):diffuse(color("#6a6664")) end
}
-- blind strings - right
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:xy(_screen.w-30, 0):valign(0):zoomto(2, _screen.h-120):diffuse(color("#6a6664")) end
}

-- desk
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:xy(_screen.cx, _screen.h):valign(1):zoomto(_screen.w, 30):diffuse(0.05,0.05,0.05,1):diffusetopedge(0.085,0.075,0.1,1) end
}

-- monitor
af[#af+1] = Def.ActorFrame{

	-- stand
	Def.Quad{
		InitCommand=function(self) self:xy(_screen.cx, monitor.h):valign(0):zoomto(103, 100):diffuse(monitor.c) end
	},
	Def.Quad{
		InitCommand=function(self) self:xy(_screen.cx, monitor.h):valign(0):zoomto(100, 100):diffuse(monitor.c):diffusetopedge(0.05,0.05,0.05,1) end
	},

	-- bezel
	Def.Quad{
		InitCommand=function(self) self:Center():zoomto(monitor.w, monitor.h):diffuse(monitor.c) end
	},

	-- inner bezel
	Def.Quad{
		InitCommand=function(self) self:Center():zoomto(monitor.w-20, monitor.h-20):diffuse(0.1,0.1,0.1,1) end
	},

	-- wallpaper
	LoadActor("./space.png")..{
		InitCommand=function(self) self:zoomto(monitor.w-24, monitor.h-24):Center() end,
	},

	--  terminal window
	Def.ActorFrame{
		InitCommand=function(self) self:xy(terminal.x, terminal.y) end,

		Def.Quad{
			InitCommand=function(self) self:align(0,0):zoomto(terminal.w+terminal.padding, terminal.h):diffuse(0,0,0,0.75) end
		},

		-- dragbar texture
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/14/dragbar.png"),
			InitCommand=function(self) self:zoomto(dragbar.w+terminal.padding, dragbar.h):halign(0) end
		},
		-- close
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/14/circle.png"),
			InitCommand=function(self) self:zoomto(dragbar.h-4,dragbar.h-4):diffuse(color("#fc615d")):x(dragbar.h-2):halign(1) end
		},
		-- minimize
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/14/circle.png"),
			InitCommand=function(self) self:zoomto(dragbar.h-4,dragbar.h-4):diffuse(color("#fdbc40")):x((dragbar.h-2)*2):halign(1) end
		},
		-- maximize
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/14/circle.png"),
			InitCommand=function(self) self:zoomto(dragbar.h-4,dragbar.h-4):diffuse(color("#34c84a")):x((dragbar.h-2)*3):halign(1) end
		},

		-- main text
		Def.BitmapText{
			File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/monaco/_monaco 20px.ini"),
			Text="",
			InitCommand=function(self)
				bmt = self
				self:xy(char_width/2,char_width):align(0,0)
					:zoom(font_zoom):wrapwidthpixels(terminal.w/font_zoom - terminal.padding)
			end,
			StartSceneCommand=function(self)
				self:sleep(2.5):queuecommand("TypeFilename")
				cursor:queuecommand("Init")
			end,
			ResetCommand=function(self)
				self:settext("")
				cursor:queuecommand("Reset")
			end,
			TypeFilenameCommand=function(self)
				local s = "vim ./" .. filename
				if s:len() > self:GetText():len() then
					self:settext( s:sub(0,self:GetText():len()+1) ):sleep( delay ):queuecommand("TypeFilename")
					cursor:queuecommand("Move")
				else
					self:sleep(1.5):queuecommand("Reset"):sleep(1.5):queuecommand("Type")
					tildes:sleep(1.5):queuecommand("Show")
				end
			end,
			CDCommand=function(self)
				local s = "vim ./" .. filename .. "\ncd .."
				if s:len() > self:GetText():len() then
					self:settext(s:sub(0,self:GetText():len()+1) ):sleep( delay ):queuecommand("CD")
					cursor:queuecommand("Move")
				else
					self:sleep(1.5):queuecommand("RM")
					cursor:sleep(1.5):queuecommand("Reset")
				end
			end,
			RMCommand=function(self)
				local s = "vim ./" .. filename .. "\ncd ..\nrm -rf ./letters"
				if s:len() > self:GetText():len() then
					self:settext(s:sub(0,self:GetText():len()+1) ):sleep( delay ):queuecommand("RM")
					cursor:queuecommand("Move")
				else
					self:sleep(1.5):queuecommand("Enter")
					cursor:sleep(1.5):queuecommand("Reset")
				end
			end,
			EnterCommand=function(self)
				accepting_input = true
				done = true
				self:settext( self:GetText().."\n" )
				cursor:queuecommand("Reset")
			end,
			TypeCommand=function(self)
				if accepting_input then
					if body:len() > self:GetText():len() then
						local old_height = self:GetHeight()*font_zoom
						self:settext( body:sub(0,self:GetText():len()+1) ):sleep( delay ):queuecommand("Type")

						if old_height < self:GetHeight()*font_zoom then
							tildes:queuecommand("NewLine")
						end
					end
				else
					cursor:visible(true)
					tildes:visible(false)
				end
			end
		},

		-- vim tildes
		Def.BitmapText{
			File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/monaco/_monaco 20px.ini"),
			InitCommand=function(self)
				tildes = self
				self:x(14)
					:y(terminal.y+(terminal.h-char_height*4.6*font_zoom))
					:align(1,1)
					:zoom(font_zoom):diffuse(color("#593ced"))
			end,
			ShowCommand=function(self)
				cursor:queuecommand("Hide")
				accepting_input = true
				local s = ""
				for i=1, terminal.rows-1 do
					s = s .. "~\n"
				end
				self:settext(s)
			end,
			NewLineCommand=function(self)
				self:settext( self:GetText():sub(1, self:GetText():len()-2 ) )
			end
		},

		-- cursor
		Def.Quad{
			InitCommand=function(self)
				cursor = self
				self:align(0,0):xy(char_width*font_zoom+2, (CountNewlines(bmt:GetText())+1)*char_width):zoomto(1,15)
					:diffuseblink():effectperiod(1):effectcolor1(0,0,0,1):effectcolor2(0.9,0.9,0.9,1)
					:visible(true)
			end,
			ResetCommand=function(self) self:xy(char_width*font_zoom, (CountNewlines(bmt:GetText())+1)*char_width + char_width/2) end,
			MoveCommand=function(self)
				self:y( bmt:GetHeight()*font_zoom )
				self:addx( char_width*font_zoom)
			end,
			ShowCommand=function(self) self:visible( true ) end,
			HideCommand=function(self) self:visible( false ) end
		},
	}
}


return af
