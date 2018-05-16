-- love letters
local args = ...
local delay = args.delay
local filename = args.filename
local initial_text = args.initial_text
local body = args.body

local bgm_volume = 10

local bmt, tildes, cursor
local char_width = 12
local chars_per_line = 60
local font_zoom = 0.55
local font_height = 26

local monitor = { w=540, h=_screen.h-100, c=color("#202020") }
local terminal = { w=char_width*font_zoom*chars_per_line + char_width, h=monitor.h-50 }
local dragbar = { w=terminal.w, h=10 }

local accepting_input = false
local done = false

local CountNewlines = function( s )
	local n = 0
	for newline in s:gmatch("\n") do n = n + 1 end
	return n
end


local af = Def.ActorFrame{
	StartSceneCommand=function(self) self:visible(true):smooth(1):diffuse(1,1,1,1) end,
	Ch4Sc3InputEventCommand=function(self, event)
		if accepting_input then
			if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
				accepting_input = false

				if not done then
					bmt:settext( "vim ./" .. filename ):sleep(2):queuecommand("CD")
					cursor:xy( (bmt:GetText():len()+1)*char_width*font_zoom, char_width*font_zoom ):sleep(2):queuecommand("Reset")
				else
					self:GetParent():queuecommand("TransitionScene")
				end
			end
		end
	end
}

af[#af+1] = LoadActor( THEME:GetPathB("", "_shared background normal/snow.lua") )
af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/frost.png"),
	InitCommand=function(self) self:xy(_screen.cx,0):zoomto(_screen.w, _screen.h-80):valign(0) end,
}

-- af[#af+1] = Def.Sound{
-- 	File=THEME:GetPathB("ScreenRabbitHole", "overlay/17/Since.ogg"),
-- 	StartSceneCommand=function(self) self:play() end,
-- 	FadeOutAudioCommand=function(self)
-- 		if bgm_volume >= 0 then
-- 			local ragesound = self:get()
-- 			bgm_volume = bgm_volume-1
-- 			ragesound:volume(bgm_volume*0.1)
-- 			self:sleep(0.1):queuecommand("FadeOutAudio")
-- 		end
-- 	end
-- }


-- blinds
af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/blind.png"),
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy-100):zoomtoheight(_screen.h-100):zoomtowidth(_screen.w):customtexturerect(0,0,1,12) end,
}
-- blind strings
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:xy(30, 0):valign(0):zoomto(2, _screen.h-150):diffuse(color("#6a6664")) end
}
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:xy(_screen.w-30, 0):valign(0):zoomto(2, _screen.h-150):diffuse(color("#6a6664")) end
}

-- desk?
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:xy(_screen.cx, _screen.h):valign(1):zoomto(_screen.w, 80):diffuse(0.05,0.05,0.05,1):diffusetopedge(0,0,0,1) end
}

-- monitor
af[#af+1] = Def.ActorFrame{

	-- InitCommand=function(self) self:fov(90):rotationy(-1) end,

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
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/space.png"),
		InitCommand=function(self) self:zoomto(monitor.w-24, monitor.h-24):Center() end,
	},

	--  terminal window
	Def.ActorFrame{
		InitCommand=function(self) self:xy(_screen.cx-dragbar.w/2, (_screen.h-monitor.h)/2+26) end,

		Def.Quad{
			InitCommand=function(self) self:align(0,0):zoomto(terminal.w, monitor.h-50):diffuse(0,0,0,0.75) end
		},

		-- dragbar texture
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/14/dragbar.png"),
			InitCommand=function(self) self:zoomto(dragbar.w, dragbar.h):halign(0) end
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
					:zoom(font_zoom):wrapwidthpixels(terminal.w/font_zoom)
			end,
			StartSceneCommand=function(self)
				if initial_text == "" then
					self:sleep(2.5):queuecommand("TypeFilename")
				else
					self:settext(initial_text):sleep(1.333):queuecommand("Clear")
					cursor:queuecommand("Init")
				end
			end,
			ResetCommand=function(self)
				self:settext("")
				cursor:queuecommand("Reset")
			end,
			ClearCommand=function(self)
				local s = initial_text .. "clear"
				if s:len() > self:GetText():len() then
					self:settext( s:sub(0,self:GetText():len()+1) ):sleep( delay ):queuecommand("Clear")
					cursor:queuecommand("Move")
				else
					self:sleep(0.8):queuecommand("Reset"):sleep(1.5):queuecommand("TypeFilename")
				end
			end,
			TypeFilenameCommand=function(self)
				local s = "vim ./" .. filename
				if s:len() > self:GetText():len() then
					self:settext( s:sub(0,self:GetText():len()+1) ):sleep( delay ):queuecommand("TypeFilename")
					cursor:queuecommand("Move")
				else
					self:sleep(1.5):queuecommand("Reset"):sleep(1.5):queuecommand("Type")
					cursor:sleep(1.5):queuecommand("Hide")
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
				self:xy(char_width/2,terminal.h + char_width*1.15):align(0,1)
					:zoom(font_zoom):diffuse(color("#593ced"))
			end,
			ShowCommand=function(self)
				accepting_input = true
				cursor:queuecommand("Hide")
				while ( self:GetHeight()*font_zoom < terminal.h-char_width*font_zoom*2 ) do
					self:settext( self:GetText() .. "~\n" )
				end
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
			HideCommand=function(self) self:visible( false ) end
		},


	}
}


return af
