local args = ...
local choiceName = args[1].name
local frame_x = args[1].x
local pads = args[1].pads
local index = args[2]


local _zoom = WideScale(0.435,0.525)
local _game = GAMESTATE:GetCurrentGame():GetName()

local drawNinePanelPad = function(color, xoffset)

	return Def.ActorFrame {

		InitCommand=function(self) self:x(xoffset) end,

		-- first row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(_zoom)
				self:x(_zoom * self:GetWidth() * -1)
				self:y(_zoom * self:GetHeight() * -2)

				if _game == "pump" or _game == "techno" or (_game == "dance" and choiceName == "solo") then
					self:diffuse(color)
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(_zoom)
				self:x(0)
				self:y(_zoom * self:GetHeight() * -2)

				if _game == "dance" or _game == "techno" then
					self:diffuse(color)
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(_zoom)
				self:x(_zoom * self:GetWidth())
				self:y(_zoom * self:GetHeight() * -2)

				if _game == "pump" or _game == "techno" or (_game == "dance" and choiceName == "solo") then
					self:diffuse(color)
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},


		-- second row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(_zoom)
				self:x(_zoom * self:GetWidth() * -1)
				self:y(_zoom * self:GetHeight() * -1)

				if _game == "dance" or _game == "techno" then
					self:diffuse(color)
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(_zoom)
				self:x(0)
				self:y(_zoom * self:GetHeight() * -1)

				if _game == "pump" then
					self:diffuse(color)
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(_zoom)
				self:x(_zoom * self:GetWidth())
				self:y(_zoom * self:GetHeight() * -1)

				if _game == "dance" or _game == "techno" then
					self:diffuse(color)
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},



		-- third row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(_zoom)
				self:x(_zoom * self:GetWidth() * -1)
				self:y(0)

				if _game == "pump" or _game == "techno" then
					self:diffuse(color)
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(_zoom)
				self:x(0)
				self:y(0)

				if _game == "dance" or _game == "techno" then
					self:diffuse(color)
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(_zoom)
				self:x(_zoom * self:GetWidth())
				self:y(0)

				if _game == "pump" or _game == "techno" then
					self:diffuse(color)
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		}
	}
end



local af = Def.ActorFrame{
	Enabled = false,
	InitCommand=function(self)
		self:zoom(0.5):xy( frame_x, _screen.cy + WideScale(0,10) )

		if ThemePrefs.Get("VisualTheme")=="Gay" then
			self:bob():effectmagnitude(0,0,0):effectclock('bgm'):effectperiod(0.666)
		end
	end,
	OffCommand=function(self)
		self:sleep(0.04 * index)
		self:linear(0.2)
		self:diffusealpha(0)
	end,
	GainFocusCommand=function(self)
		self:linear(0.125):zoom(1)
		if ThemePrefs.Get("VisualTheme")=="Gay" then
			self:effectmagnitude(0,4,0)
		end
	end,
	LoseFocusCommand=function(self)
		self:linear(0.125):zoom(0.5):effectmagnitude(0,0,0)
	end,
	EnableCommand=function(self)
		if self.Enabled then
			self:diffusealpha(1)
		else
			self:diffusealpha(0.25)
		end
	 end,

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenSelectStyle", choiceName:gsub("^%l", string.upper)),
		InitCommand=function(self)
			self:shadowlength(1):y(37):zoom(0.5)
		end,
	}
}

-- draw as many pads as needed for this choice
for pad in ivalues(pads) do
	af[#af+1] = drawNinePanelPad(pad.color, pad.offset)..{
		OffCommand=function(self) self:linear(0.2):diffusealpha(0) end
	}
end

return af