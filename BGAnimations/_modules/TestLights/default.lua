local pad_img = GAMESTATE:GetCurrentGame():GetName()
local bassInParallel = PREFSMAN:GetPreference("LightsBassParallel")
local isSolo = false
if pad_img == "dance" and ThemePrefs.Get("AllowDanceSolo") then
	local style = GAMESTATE:GetCurrentStyle()
	-- style will be nil in ScreenTestInput within the operator menu
	if style==nil or style:GetName()=="solo" then
		isSolo = true
		pad_img = "dance-solo"
	end
end

local CabinetHighlights = {
	MarqueeUpLeft=	{    x=-278, y=-587, rotationz=0, zoom=0.6, graphic="red.png" },
	MarqueeUpRight=	{    x=278,   y=-587, rotationz=0, zoom=0.6, graphic="blue.png" },
	MarqueeLrLeft=	{    x=-278,  y=-409, rotationz=0, zoom=0.6, graphic="white.png" },
	MarqueeLrRight=	{    x=278, y=-409,  rotationz=0, zoom=0.6, graphic="pink.png" },
	BassLeft=		{    x=-230,   y=433,  rotationz=0, zoom=0.6, graphic="bass light (blue).png" },
	BassRight=		{    x=230,  y=433,  rotationz=0, zoom=0.6, graphic="bass light (blue).png" }
}
local parallelBass= {
	BassLeft="BassRight",
	BassRight="BassLeft"
}
local highlight = THEME:GetPathB("", "_modules/TestInput Pad/highlight.png")
local GameButtonHighlights = {
	-- Start={     x=0,   y=0, rotationz=0,   zoom=0.5, graphic="green.png" },
	-- Select={    x=0,   y=0, rotationz=0, zoom=0.5, graphic="red.png" },
	-- MenuRight={ x=0,  y=0, rotationz=0,   zoom=0.5, graphic="yellow.png" },
	-- MenuLeft={  x=-0, y=0, rotationz=0, zoom=0.5, graphic="yellow.png" },
	UpLeft={    x=-84, y=-84, rotationz=0, zoom=1, graphic=highlight },
	Up={        x=0,   y=-84, rotationz=0, zoom=1, graphic=highlight },
	UpRight={   x=84,  y=-84, rotationz=0, zoom=1, graphic=highlight },

	Left={      x=-84, y=0,  rotationz=0, zoom=1, graphic=highlight },
	Center={    x=0,   y=0,  rotationz=0, zoom=1, graphic=highlight },
	Right={     x=84,  y=0,  rotationz=0, zoom=1, graphic=highlight },

	DownLeft={  x=-84, y=84,  rotationz=0, zoom=1, graphic=highlight },
	Down={      x=0,   y=84,  rotationz=0, zoom=1, graphic=highlight },
	DownRight={ x=84,  y=84,  rotationz=0, zoom=1, graphic=highlight }
}

local cabinet = Def.ActorFrame{
	Name="Cabinet",
	InitCommand=function(self)
		self:visible(true):zoom(0.2)
		self.lastOn = nil
	end,
	LoadActor("cabinet ITG2.png"),
	TestLightEventMessageCommand=function(self, params)
		if params.CabinetLightId == "None" then
			return
		end

		if self.lastOn ~= nil then
			self:GetChild(self.lastOn):queuecommand("TurnOff")

			if bassInParallel and string.find(self.lastOn, "Bass") then
				self:GetChild(parallelBass[self.lastOn]):queuecommand("TurnOff")
			end
			self.lastOn = nil
		end

		self:GetChild(params.CabinetLightId):queuecommand("TurnOn")

		if bassInParallel and string.find(params.CabinetLightId, "Bass") then
				self:GetChild(parallelBass[params.CabinetLightId]):queuecommand("TurnOn")
		end

		self.lastOn = params.CabinetLightId
	end
}

for panel,values in pairs(CabinetHighlights) do
	cabinet[#cabinet+1] = LoadActor(values.graphic)..{
		Name=panel,
		InitCommand=function(self) 
			self:xy(values.x, values.y):rotationz(values.rotationz):zoom(values.zoom):queuecommand("TurnOff")
		end,
		TurnOffCommand=function(self)
			self:visible(false)
		end,
		TurnOnCommand=function(self)
			self:visible(true)
		end
	}
end

local pads = Def.ActorFrame{
	Name="Pads",
	InitCommand=function(self)
		self:zoom(0.55):xy(0, 210):visible(true)
		self.lastOn = nil
	end,
	TestLightEventMessageCommand=function(self, params)
		if params.GameButtonLightId == "None" then
			return
		end

		if self.lastOn ~= nil then
			self.lastOn:queuecommand("TurnOff")
			self.lastOn = nil
		end

		local child = self:GetChild(params.Side)
		local panel = child:GetChild(params.GameButtonLightId)
		panel:queuecommand("TurnOn")
		self.lastOn = panel
	end
}

for i=1,2 do
	local pn = "P"..i
	pads[#pads+1] = Def.ActorFrame{
		Name=pn,
		InitCommand=function(self)
			local pos = i == 1 and -135 or 135
			self:xy(pos, 0):visible(true)
		end,
		LoadActor(THEME:GetPathB("", "_modules/TestInput Pad/"..pad_img..".png"))
	}
	for panel,values in pairs(GameButtonHighlights) do
		local pad = pads[#pads]
		pad[#pad+1] = LoadActor(values.graphic)..{
			Name=panel,
			InitCommand=function(self) 
				self:xy(values.x, values.y):rotationz(values.rotationz):zoom(values.zoom):queuecommand("TurnOff")
			end,
			TurnOffCommand=function(self)
				self:visible(false)
			end,
			TurnOnCommand=function(self)
				self:visible(true)
			end
		}
	end
end

local af = Def.ActorFrame{
	InitCommand=function(self) 
		self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y-70):visible(true)
	end,
	cabinet,
	pads
}

return af