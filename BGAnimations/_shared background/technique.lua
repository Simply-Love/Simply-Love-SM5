-- mostly adapted from normal.lua so this is kind of a freaking mess, not gonna lie

local file = ...

local anim_data = {
	color_add = {-0.75,0,0,-0.75,-0.75,-0.75,0,-0.75,0,-0.75},
	diffusealpha = {0.05,0.2,0.1,0.1,0.1,0.1,0.1,0.05,0.1,0.1},
	xy = {0,40,80,120,200,280,360,400,480,560},
	texcoordvelocity = {{0.03,0.01},{0.03,0.02},{0.03,0.01},{0.02,0.02},{0.03,0.03},{0.02,0.02},{0.03,0.01},{-0.03,0.01},{0.05,0.03},{0.03,0.04}}
}

local t = Def.ActorFrame {
	InitCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")
		self:visible(style == "Technique")
	end,
	OnCommand=function(self) self:fov(90):accelerate(0.8):diffusealpha(1) end,
	HideCommand=function(self) self:visible(false) end,

	VisualStyleSelectedMessageCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")
		if style == "Technique" then
			self:visible(true):linear(0.6):diffusealpha(1)
		else
			self:linear(0.6):diffusealpha(0):queuecommand("Hide")
		end
	end
}

-- fricks sake this function is giving me so much damn mileage lol
local function randomXD(t)
	if t == 0 then return 0.5 else
	return (math.sin(t * 3229.3) * 43758.5453) % 1 end
end

-- background
t[#t+1] = Def.Quad {
	InitCommand=function(self)
		self:diffuse(20/255, 20/255, 20/255, 1):zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
	end
}

-- grid i think
t[#t+1] = Def.Sprite {
	Texture = "./square.png",
	OnCommand=function(self)
		self:zoom(20):xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
		:customtexturerect(0,0,60,60):texcoordvelocity(0.05, 0.07)
		:diffusealpha(0.1)
	end
}
t[#t+1] = Def.Sprite {
	Texture = "./square.png",
	OnCommand=function(self)
		self:zoom(20):xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
		:customtexturerect(0,0,60,60):texcoordvelocity(0.04, 0.02)
		:diffusealpha(0.05)
	end
}
t[#t+1] = Def.Sprite {
	Texture = "./square.png",
	OnCommand=function(self)
		self:zoom(20):xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
		:customtexturerect(0,0,60,60):texcoordvelocity(0.02, 0.015)
		:diffusealpha(0.025)
	end
}

-- main stuff (rings, arrow)
for i=1,10 do
	t[#t+1] = Def.Sprite {
		Texture="./circlefrag (doubleres).png",
		InitCommand=function(self)
			self:diffuse(GetHexColor(SL.Global.ActiveColorIndex+anim_data.color_add[i], true)):baserotationz(randomXD(i) * 100):baserotationx(-60):baserotationy(20)
			:SetTextureFiltering(true)
			:diffusealpha(randomXD(i))
		end,
		OnCommand=function(self)
			self:zoom((randomXD(i*1.5) + 0.5)):xy(SCREEN_CENTER_X, SCREEN_CENTER_Y):z((randomXD(i * 13) - 0.6) * (1 / self:GetZoom()) * 850)
			self:spin():effectmagnitude(0, 0, randomXD(i*3) * 14):effectoffset(i * 20)
		end
	}
end

t[#t+1] = Def.Sprite {
	Texture = "./ring.png",
	InitCommand=function(self)
		self:diffuse(1, 1, 1, 0.8):baserotationz(50):baserotationx(-60):baserotationy(20)
		:SetTextureFiltering(true)
	end,
	OnCommand=function(self)
		self:zoom(1.65):xy(SCREEN_CENTER_X, SCREEN_CENTER_Y):z(0)
		self:spin():effectmagnitude(0, 0, 10):effectoffset(20)
	end
}

t[#t+1] = Def.Sprite {
	Texture = "./ring.png",
	InitCommand=function(self)
		self:diffuse(1, 1, 1, 0.8):baserotationz(50):baserotationx(-60):baserotationy(20)
		:SetTextureFiltering(true)
	end,
	OnCommand=function(self)
		self:zoom(0.55):xy(SCREEN_CENTER_X, SCREEN_CENTER_Y):z(0)
		self:spin():effectmagnitude(0, 0, 4):effectoffset(20)
	end
}

t[#t+1] = Def.Sprite {
	Texture = "./arrow.png",
	InitCommand=function(self)
		self
		:diffuse(GetHexColor(SL.Global.ActiveColorIndex, true))
		:baserotationz(20)
		:SetTextureFiltering(true)
		:diffusealpha(0.7)
	end,
	OnCommand=function(self)
		self:zoom(1.3):xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
		self:spin():effectmagnitude(0, 10, 0)
	end
}

for i=11,18 do
	t[#t+1] = Def.Sprite {
		Texture="./circlefrag (doubleres).png",
		InitCommand=function(self)
			self:diffuse(1, 1, 1, randomXD(i / 1.6)):baserotationz(randomXD(i) * 100):baserotationx(-60):baserotationy(20)
			:SetTextureFiltering(true)
		end,
		OnCommand=function(self)
			self:zoom((randomXD(i*1.5) + 0.5)):xy(SCREEN_CENTER_X, SCREEN_CENTER_Y):z((randomXD(i * 13) - 0.6) * (1 / self:GetZoom()) * 850)
			self:spin():effectmagnitude(0, 0, randomXD(i*3) * 14):effectoffset(i * 20)
		end
	}
end


return t
