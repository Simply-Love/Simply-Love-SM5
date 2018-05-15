-- doubts

local bgm_volume = 10
local time_in_scene, old_time = 0, 0
local scene_duration = 30

local bmt, cursor
local char_width = 12
local chars_per_line = 60
local font_zoom = 0.55
local terminal_width = char_width*font_zoom*chars_per_line + char_width

local monitor = { w=540, h=_screen.h-100, c=color("#202020") }
local dragbar = { w=terminal_width, h=10 }

local UpdateRainfall

-- me, an intellectual: "fewer ./butterflies"
local command = "less ./butterflies"
local smitten = "QW5kIHNvLCBzdWRkZW5seSwgYWZ0ZXIgbmVhcmx5IGZpdmUgeWVhcnMgb2Ygb25seSBlbWFpbHMgYW5kIGluc3RhbnQgbWVzc2FnZXMsIHdlIHdlcmUgYWJsZSB0byBTa3lwZSBiZWNhdXNlIHRoZSBzdGF0ZSBvZiB0ZWNobm9sb2d5IHBlcm1pdHRlZCBpdCwgYW5kIEkgaGFkIGEgdm9pY2UgYW5kIGZhY2UgdG8gYXNzb2NpYXRlIHdpdGggYSBwZXJzb25hbHR5LiAgT3VyIGZyaWVuZHNoaXAgZXhwYW5kZWQgaW50byBuZXcgZGltZW5zaW9ucyBhdCB0aGF0IG1vbWVudC4KCkl0IHN0cmlrZXMgbWUgbm93LCB5ZWFycyBsYXRlciwgaG93IHBhdGllbnQgd2Ugd2VyZSwgaGF2aW5nIGV4Y2hhbmdlZCB3b3JkcyBvdmVyIHRoZSBpbnRlcm5ldCBmb3IgeWVhcnMgd2l0aG91dCBldmVyIGFza2luZyB0byBzZWUgb3IgaGVhciB0aGUgcGVyc29uIG9uIHRoZSBvdGhlciBlbmQuICBUaGVzZSBkYXlzLCBwZW9wbGUgZ2V0IGFuZ3J5IHdpdGggeW91IGZvciBub3QgaGF2aW5nIGFuIE9rQ3VwaWQgcGhvdG8gZGVtb25zdHJhYmx5IHJldmVhbGluZyB5b3VyIGN1cCBzaXplLgoKIldlcmUgeW91IGluc3RhbnRseSBzbWl0dGVuIGJ5IGhlciBiZWF1dHksIGJlaW5nIGZpbmFsbHkgYWJsZSB0byBzZWUgaGVyPyIKCkkgZG9uJ3Qga25vdy4gIEkgZGlkbid0IHJlYWxseSB0aGluayBvZiBpdCBsaWtlIHRoYXQgYXQgdGhlIHRpbWUsIGJlY2F1c2UgSSdkIGFscmVhZHkgYmVlbiBzbWl0dGVuIGJ5IGhlciB3b3JkcyBsb25nIGJlZm9yZSB0aGF0LiAgU2hlJ2QgZGVtb25zdHJhdGVkIGFuIHV0dGVybHkgY2FwdGl2YXRpbmcgY29tbWFuZCBvZiBsYW5ndWFnZSBmcm9tIHRoZSBzdGFydCwgYWJsZSB0byBiZSBwbGF5ZnVsIGFuZCB3aXR0eSBhbmQgZGVlcGx5IGluY2lzaXZlIGFsbCBhdCBvbmNlIGluIGEgc2luZ2xlIHNlbnRlbmNlLiAgSSBzd2VhciwgaGVyIHdvcmRzIGtlcHQgbWUgYWxpdmUgc29tZSBuaWdodHMu"

local Update = function(af, delta)
	if old_time <= 0 then
		old_time = GetTimeSinceStart()
	else
		time_in_scene = GetTimeSinceStart() - old_time
	end

	UpdateRainfall(af, delta)
end

local af = Def.ActorFrame{
	StartSceneCommand=function(self)
		self:visible(true):SetUpdateFunction(Update)
	end,
	Ch4Sc3InputCommand=function(self, event)
		if (time_in_scene >= scene_duration) or (bmt:GetText():len() >= smitten:len()) then
			if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
				self:GetParent():queuecommand("TransitionScene")
			end
		elseif time_in_scene > 0 and time_in_scene < scene_duration then
			if event.type == "InputEventType_FirstPress" then
				bmt:playcommand("Type")
			end
		end
	end
}

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:Center():FullScreen():diffuse(0, 0, 0, 1) end
}

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/17/Since.ogg"),
	StartSceneCommand=function(self) self:play() end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-1
			ragesound:volume(bgm_volume*0.1)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		end
	end
}


-- rainfall
----------------------------------------------
-- variables you might want to configure to your liking
local num_particles = 500
-- particle length in pixels
local min_length = 80
local max_length = 100
-- particle velocity in pixels per second
local min_vy = 1000
local max_vy = 1050

-- -----------------------------------
local verts = {}
local velocities = {}
local x, y, length, alpha, index
local amv

UpdateRainfall = function(self, delta)

	-- each particle is a quadrilateral comprised of four vertices (with a texture applied)
	-- we want to update each of those four vertices for each of the quadrilaterals
	for i=1, num_particles*4, 4 do
		index = math.floor(i/4)+1

		-- update y coordinates
		verts[i+0][1][2] = verts[i+0][1][2] + velocities[index][1]*delta
		verts[i+1][1][2] = verts[i+1][1][2] + velocities[index][1]*delta
		verts[i+2][1][2] = verts[i+2][1][2] + velocities[index][1]*delta
		verts[i+3][1][2] = verts[i+3][1][2] + velocities[index][1]*delta
		-- update x coordinates
		-- verts[i+0][1][1] = verts[i+0][1][1] + velocities[index][2]*delta
		-- verts[i+1][1][1] = verts[i+1][1][1] + velocities[index][2]*delta
		-- verts[i+2][1][1] = verts[i+2][1][1] + velocities[index][2]*delta
		-- verts[i+3][1][1] = verts[i+3][1][1] + velocities[index][2]*delta

		-- if the top of this particular quadrilateral within the AMV has gone off
		-- the bottom of the screen, re-randomize its x and y velocities, length, and
		-- starting x position, and reset its starting y position to be just above
		-- the top of the screen
		if (verts[i+0][1][2] > _screen.h+(verts[i+2][1][2]-verts[i+0][1][2])) then
			velocities[index] = {math.random(min_vy,max_vy), 0}
			length = math.random(min_length, max_length)
			x = math.random(_screen.w + length*2)

			verts[i+0][1] = {x-1, -length, 0}
			verts[i+1][1] = {x, -length, 0}
			verts[i+2][1] = {x, 0, 0}
			verts[i+3][1] = {x-1, 0, 0}
		end
	end

	amv:SetVertices(verts)
end

-- initialize the verts table
for i=1, num_particles do
	length = math.random(min_length, max_length)
	x = math.random(_screen.w + length*2)
	y = math.random(_screen.h + length*2)
	velocities[i] = {math.random(min_vy,max_vy), 0}
	alpha = math.random(6, 10)/10

	table.insert( verts, {{x-1, y-length, 0}, 	{0.2,0.2,0.2,alpha} } )
	table.insert( verts, {{x, y-length, 0}, 	{0.2,0.2,0.2,alpha} } )
	table.insert( verts, {{x, y, 0}, 			{0.2,0.2,0.2,alpha} } )
	table.insert( verts, {{x-1, y, 0}, 			{0.2,0.2,0.2,alpha} } )
end


af[#af+1] = Def.ActorMultiVertex{
	InitCommand=function(self)
		self:SetDrawState( {Mode="DrawMode_Quads"} )
			:SetVertices( verts )
			:rotationz(3)
		amv = self
	end
}
----------------------------------------------

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
	InitCommand=function(self) self:xy(_screen.cx, _screen.h):valign(1):zoomto(_screen.w, 80):diffuse(0.15,0.15,0.15,1):diffusetopedge(0,0,0,1) end
}

-- monitor
af[#af+1] = Def.ActorFrame{

	-- InitCommand=function(self) self:fov(90):rotationy(-1) end,

	-- stand
	Def.Quad{
		InitCommand=function(self) self:xy(_screen.cx, _screen.cy):valign(0):zoomto(100, _screen.h):diffuse(0.1,0.1,0.1,1) end
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
			InitCommand=function(self) self:align(0,0):zoomto(terminal_width, monitor.h-50):diffuse(0,0,0,0.75) end
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

		-- cursor
		Def.Quad{
			InitCommand=function(self)
				cursor = self
				self:align(0,0):xy(char_width/2 + 2,char_width/2):zoomto(1,15)
					:diffuseblink():effectperiod(1):effectcolor1(0,0,0,1):effectcolor2(0.9,0.9,0.9,1)
			end,
			MoveCommand=function(self) self:addx( char_width*font_zoom) end,
			HideCommand=function(self) self:visible( false ) end
		},

		Def.BitmapText{
			File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/monaco/_monaco 20px.ini"),
			InitCommand=function(self)
				bmt = self
				self:xy(char_width/2,char_width):align(0,0)
					:zoom(font_zoom)
			end,
			TypeCommand=function(self)
				if self:GetText():len() < command:len() then
					cursor:playcommand("Move")
					self:settext( command:sub(1, self:GetText():len()+1) )
				else
					local s = ""
					cursor:playcommand("Hide")
					for i=0, math.ceil(smitten:len()/chars_per_line) do
						s = s .. smitten:sub(i*chars_per_line+1, i*chars_per_line+chars_per_line) .. "\n"
					end
					self:settext( s )
				end
			end
		}

	}
}


return af
