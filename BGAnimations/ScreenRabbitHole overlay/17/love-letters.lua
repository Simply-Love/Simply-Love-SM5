-- love letters
local args = ...
local delay = args.delay
local filename = args.filename
local body = args.body

local bgm_volume = 10

local bmt, tildes
local char_width = 12
local chars_per_line = 60
local font_zoom = 0.55

local monitor = { w=540, h=_screen.h-100, c=color("#202020") }
local terminal = { w=char_width*font_zoom*chars_per_line + char_width, h=monitor.h-50 }
local dragbar = { w=terminal.w, h=10 }



local af = Def.ActorFrame{
	StartSceneCommand=function(self)
		self:visible(true)
	end,
}

af[#af+1] = LoadActor( THEME:GetPathB("", "_shared background normal/snow.lua") )

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
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy-100):zoomtoheight(_screen.h-100):zoomtowidth(_screen.w):customtexturerect(0,0,1,16) end,
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
		InitCommand=function(self) self:xy(_screen.cx, monitor.h):valign(0):zoomto(102, 100):diffuse(monitor.c) end
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
			InitCommand=function(self)
				bmt = self
				self:xy(char_width/2,char_width):align(0,0)
					:zoom(font_zoom):wrapwidthpixels(terminal.w/font_zoom)
			end,
			StartSceneCommand=function(self)
				self:sleep(1.5):queuecommand("TypeFilename")
			end,
			TypeFilenameCommand=function(self)
				local s = "vim ./" .. filename
				if s:len() > self:GetText():len() then
					self:settext( s:sub(0,self:GetText():len()+1) ):sleep( delay ):queuecommand("TypeFilename")
				else
					self:sleep(1.5):queuecommand("Reset")
					tildes:sleep(1.5):queuecommand("Show")
				end
			end,
			ResetCommand=function(self) self:settext(""):sleep(1.5):queuecommand("Type") end,
			TypeCommand=function(self)
				if body:len() > self:GetText():len() then
					local old_height = self:GetHeight()*font_zoom
					self:settext( body:sub(0,self:GetText():len()+1) ):sleep( delay ):queuecommand("Type")

					if old_height < self:GetHeight()*font_zoom then
						tildes:queuecommand("NewLine")
					end
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
				while ( self:GetHeight()*font_zoom < terminal.h-char_width*font_zoom*2 ) do
					self:settext( self:GetText() .. "~\n" )
				end
			end,
			NewLineCommand=function(self)
				self:settext( self:GetText():sub(1, self:GetText():len()-2 ) )
			end
		}
	}
}


return af
