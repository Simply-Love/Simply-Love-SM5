local choices = {
	{
		Value = "Regular",
		Text = ScreenString("Regular"),
		ZoomWidth = 0.55
	},
	{
		Value = "Marathon",
		Text = ScreenString("Marathon"),
		ZoomWidth = 0.65
	}
}

local game = GAMESTATE:GetCurrentGame():GetName()
local cursor, description_text

local cursor_index = 0

local viewport 	= { w = 200, h = 150}
local arrow	= {
	w = 12,
	h = 20,
	rotation = {
		center = 0,
		up = 45,
		upright = 90,
		right = 135,
		downright= 180,
		down = 225,
		downleft = 270,
		left = 315,
		upleft = 0,
	},
	x = {
		pump = { downleft=-48, upleft=-24, center=0, upright=24, downright=48 },
		techno = { downleft=-84, left=-60, upleft=-36, down=-12, up=12, upright=36, right=60, downright=84 },
		dance = { left=-36, down=-12, up=12, right=36 }
	},
	columns = {
		pump = { "downleft", "upleft", "center", "upright", "downright" },
		techno = { "downleft", "left", "upleft", "down", "up", "upright", "right", "downright" },
		dance = { "left", "down", "up", "right" }
	}
 }


local timePerArrow = 0.2
local pattern = {
	dance =	{"left", "down", "left", "up", "down", "right", "up", "right", "down", "up", "left", "down", "up", "right" },
	pump = 	{"upleft", "upright", "center", "downright", "upright", "center", "upleft", "upright", "center", "downright", "downleft", "center"},
	techno = {"upleft", "upright", "down", "downright", "downleft", "up", "down", "right", "left", "downright", "downleft", "up"},
}

-- I don't intend to include visualization for kb7, beat, or pop'n,
-- so fall back on the visualization for dance if necessary.
if not pattern[game] then
	game = "dance"
end

local Update = function(af, delta)
	local index = SCREENMAN:GetTopScreen():GetSelectionIndex( GAMESTATE:GetMasterPlayerNumber() )
	if index ~= cursor_index then
		cursor_index = index

		cursor:stoptweening():linear(0.1)
			:y( -60 + (40 * index) )
			:zoomtowidth( choices[index+1].ZoomWidth )
		af:queuecommand("Update"):queuecommand("FirstLoop")
	end
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:SetUpdateFunction( Update )
			:xy(_screen.cx+90, _screen.cy)
			:zoom(1.25)
	end,

	-- side mask
	Def.Quad{
		InitCommand=function(self) self:zoomto(450, 450):diffuse(1,1,1,1):x(375):MaskSource() end
	},
	-- lower mask
	Def.Quad{
		InitCommand=function(self) self:zoomto(450, 450):diffuse(1,1,1,1):xy(74,305):MaskSource() end
	},

	-- gray backgrounds
	Def.ActorFrame{
		InitCommand=function(self) self:x(-188) end,
		Def.Quad{
			InitCommand=function(self) self:diffuse(0.2,0.2,0.2,1):zoomto(90,38):y(-60) end,
			OffCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0) end
		},
		Def.Quad{
			InitCommand=function(self) self:diffuse(0.2,0.2,0.2,1):zoomto(90,38):y(-20) end,
			OffCommand=function(self) self:sleep(0.2):linear(0.1):diffusealpha(0) end
		},
	},

	-- border
	Def.Quad{
		InitCommand=function(self) self:zoomto(302, 162):diffuse(1,1,1,1) end,
		OffCommand=function(self) self:sleep(0.6):linear(0.2):cropleft(1) end
	},
	-- background
	Def.Quad{
		InitCommand=function(self) self:zoomto(300, 160):diffuse(0,0,0,1) end,
		OffCommand=function(self) self:sleep(0.6):linear(0.2):cropleft(1) end
	},


	-- description
	Def.BitmapText{
		Font="_miso",
		Text=THEME:GetString("ScreenSelectPlayMode", "RegularDescription"),
		InitCommand=function(self)
			self:zoom(0.825):croptop(1):halign(0):valign(0):xy(-130,-60)
			description_text = self
		end,
		OnCommand=function(self) self:linear(0.15):croptop(0) end,
		UpdateCommand=function(self)
			self:stoptweening():linear(0.1):croptop(1)
				:settext( THEME:GetString("ScreenSelectPlayMode", choices[cursor_index+1].Value .. "Description") )
				:linear(0.1):croptop(0)
		end,
		OffCommand=function(self) self:sleep(0.4):linear(0.2):diffusealpha(0) end
	},
	-- cursor to highlight the current choice
	Def.ActorFrame{
		Name="Cursor",
		InitCommand=function(self)
			cursor = self
			self:x(-150):zoomtowidth( choices[cursor_index+1].ZoomWidth ) 
			self:queuecommand("FirstPosition")
		end,
		FirstPositionCommand=function(self)
			local index = SCREENMAN:GetTopScreen():GetSelectionIndex( GAMESTATE:GetMasterPlayerNumber() )
			self:y( -60 + (40 * index) )
		end,
		
		Def.Quad{
			InitCommand=function(self) self:zoomto(241, 42):diffuse(1,1,1,1):x(-1):halign(1) end,
			OffCommand=function(self) self:sleep(0.4):linear(0.2):cropleft(1) end
		},
		Def.Quad{
			InitCommand=function(self) self:zoomto(240, 40):diffuse(0,0,0,1):halign(1) end,
			OffCommand=function(self) self:sleep(0.4):linear(0.2):cropleft(1) end
		}
	},

	-- Score
	Def.BitmapText{
		Font="_wendy monospace numbers",
		Text="77.41",
		InitCommand=function(self)
			self:zoom(0.225):xy(124,-68)
		end,
		OnCommand=function(self)
			if SL.Global.GameMode == "ECFA" then
				self:settext("99.50")
			else
				self:settext("77.41")
			end
		end,
		OffCommand=function(self) self:sleep(0.4):linear(0.2):diffusealpha(0) end,
	},
	-- LifeMeter
	Def.ActorFrame{
		Name="LifeMeter",
		OnCommand=function(self)
			if SL.Global.GameMode == "StopmerZ" then
				self:visible(false)
			end
		end,
		OffCommand=function(self) self:sleep(0.4):linear(0.2):diffusealpha(0) end,
		-- lifemeter white border
		Def.Quad{
			InitCommand=function(self) self:zoomto(60,16):xy(68,-64) end
		},
		-- lifemeter black bg
		Def.Quad{
			InitCommand=function(self) self:zoomto(58,14):xy(68,-64):diffuse(0,0,0,1) end
		},
		-- lifemeter colored quad
		Def.Quad{
			InitCommand=function(self) self:zoomto(40,14):xy(59,-64):diffuse( GetCurrentColor() ) end
		},
		-- life meter animated swoosh
		LoadActor(THEME:GetPathB("ScreenGameplay", "underlay/PerPlayer/LifeMeter/swoosh.png"))..{
			InitCommand=function(self) self:zoomto(40,14):diffusealpha(0.45):xy(59,-64) end,
			OnCommand=function(self)
				self:customtexturerect(0,0,1,1):texcoordvelocity(-2,0)
			end,
		},
	},
	--StomperZLifeMeter
	Def.ActorFrame{
		Name="StomperZLifeMeter",
		OnCommand=function(self)
			if SL.Global.GameMode ~= "StomperZ" then
				self:visible(false)
			end
		end,
		OffCommand=function(self) self:sleep(0.4):linear(0.2):diffusealpha(0) end,
		
		LoadActor(THEME:GetPathG("", "Triangles.png"))..{
			InitCommand=function(self) self:zoom(0.25):xy(200,10) end,
			OnCommand=function(self)
				self:MaskDest()
			end,
		},
		-- StomperZLifeMeter left
		Def.Quad{
			InitCommand=function(self) self:zoomto(24,160):xy(50,28):diffuse(1,0,1,0.75):MaskDest():faderight(1) end,
			OnCommand=function(self) self:diffuseshift():effectcolor1(1,0,1,0.75):effectcolor2(1,0,1,0.45) end
		},
		-- StomperZLifeMeter right
		Def.Quad{
			InitCommand=function(self) self:zoomto(24,160):xy(140,28):diffuse(1,0,1,0.75):MaskDest():fadeleft(1) end,
			OnCommand=function(self) self:diffuseshift():effectcolor1(1,0,1,0.75):effectcolor2(1,0,1,0.45) end
		},
	}
}

local notefield = Def.ActorFrame{
	InitCommand=function(self)
		if game == "dance" then
			self:zoom(1):xy(90,15)
		elseif game == "techno" then
			self:zoom(0.6):xy(90,-10)
		elseif game == "pump" then
			self:zoom(0.9):xy(90, 10)
		end
	end,
	OffCommand=function(self) self:sleep(0.4):diffusealpha(0) end
}

t[#t+1] = notefield


-- loop through columns for this gametype and add Receptor arrows
for i, column in ipairs( arrow.columns[game] ) do

	local file = "arrow-body.png"
	if column == "center" then file = "center-body.png" end

	notefield[#notefield+1] = LoadActor( THEME:GetPathB("ScreenSelectPlayMode", "underlay/"..file) )..{
		InitCommand=function(self)
			self:rotationz( arrow.rotation[column] )
				:x( arrow.x[game][column] )
				:y(-55)
				:zoom(0.18)
		end
	}
end




local function YieldStepPattern(i, dir)

	local step = Def.ActorFrame{
		InitCommand=function(self) self:queuecommand("Update") end,
		OnCommand=function(self) self:queuecommand("FirstLoop") end,
		UpdateCommand=function(self)
			self:visible(true)
			if cursor_index == 0 and i % 2 == 0 then
				self:visible(false)
			end
		end,
		FirstLoopCommand=function(self)
			self:stoptweening()
			self:y( -55 + (i * (arrow.h+5)))
				:rotationz( arrow.rotation[dir] )
				:x( arrow.x[game][dir] )
				:MaskDest();
			-- apply tweens appropriately
			if choices[cursor_index+1].Value == "Marathon" then
				self:ease(timePerArrow * i, 75):addrotationz(720)
			else
				self:linear(timePerArrow * i)
			end
			self:y(-55)
			self:queuecommand("Loop")

		end,
		LoopCommand=function(self)
			-- reset the y of this arrow to a lower position
			self:y(#pattern[game] * arrow.h)

			-- apply tweens appropriately
			if choices[cursor_index+1].Value == "Marathon" then
				self:ease(timePerArrow * #pattern[game], 75):addrotationz(720)
			else
				self:linear(timePerArrow *  #pattern[game])
			end

			--  -55 seems to be a good static y value to tween up to
			--  before recursing and effectively doing this again
			self:y(-55)
			self:queuecommand('Loop')
		end
	}


	if dir == "center" then
		files = { "center-body.png", "center-border.png", "center-feet.png" }
	else
		files = {"arrow-border.png", "arrow-body.png", "arrow-stripes.png" }
	end

	for index,file in ipairs(files) do
		step[#step+1] = LoadActor( THEME:GetPathB("ScreenSelectPlayMode", "underlay/"..file) )..{
			InitCommand=cmd( diffuse,color("1,1,1,1"); zoom, 0.18 ),
			OnCommand=function(self)
				if file == "center-feet.png" or file == "arrow-stripes.png" then
					self:blend(Blend.Multiply)
				end
				if file == "center-body.png" or file == "center-feet.png" or file == "arrow-body.png" then
					self:diffuse( GetHexColor(i) )
				end
			end,
		}
	end

	return step
end

for index, direction in ipairs(pattern[game]) do
	notefield[#notefield+1] = YieldStepPattern(index, direction)
end

return t