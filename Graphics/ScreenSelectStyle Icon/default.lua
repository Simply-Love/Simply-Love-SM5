------------------------------------------------------------------------------------
-- ./Grahpics/ScreenSelectStyle Icon Choice/default.lua
------------------------------------------------------------------------------------

local gc = Var("GameCommand")
local iIndex = gc:GetIndex()
local choiceName = gc:GetName()
local gameName = GAMESTATE:GetCurrentGame():GetName()

local xshift = WideScale(42,52)
local yshift = WideScale(54,78)
local zoomFactor = WideScale(0.435,0.525)

local t = Def.ActorFrame {
	Name="Item"..iIndex,
	GainFocusCommand=cmd(stoptweening; linear,0.125; zoom,1 ),
	LoseFocusCommand=cmd(stoptweening; linear,0.125; zoom,0.5)
}

t[#t+1] = LoadFont("_wendy small")..{
	Name="StyleName"..iIndex,
	InitCommand=function(self)
		self:settext(THEME:GetString("ScreenSelectStyle", choiceName))

		if choiceName == "Versus" then
			self:addx(-14)
		end

		self:addy(60)
		self:zoom(0.5)
	end,
	OffCommand=function(self)
		if choiceName == "Versus" then
			self:sleep(0.12)
		elseif choiceName == "Double" then
			self:sleep(0.36)
		end
		self:linear(0.2)
		self:diffusealpha(0)
	end,
	EnabledCommand=cmd( diffusealpha,1),
	DisabledCommand=cmd( diffusealpha,0.25 )
}



------------------------------------------------------------------------------------
-- ninePanel definition
------------------------------------------------------------------------------------

function drawNinePanelPad(color, offset)

	return Def.ActorFrame {

		InitCommand=cmd(addx, offset; addy, -yshift),
		EnabledCommand=cmd( diffusealpha,1 ),
		DisabledCommand=cmd( diffusealpha,0.25 ),

		-- first row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth())
				self:y(zoomFactor * self:GetHeight())

				if gameName == "pump" or gameName == "techno" or gameName == "dance" and choiceName == "Solo" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 2)
				self:y(zoomFactor * self:GetHeight())

				if gameName == "dance" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 3)
				self:y(zoomFactor * self:GetHeight())

				if gameName == "pump" or gameName == "techno" or gameName == "dance" and choiceName == "Solo" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},


		-- second row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth())
				self:y(zoomFactor * self:GetHeight() * 2)

				if gameName == "dance" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 2)
				self:y(zoomFactor * self:GetHeight() * 2)

				if gameName == "pump" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 3)
				self:y(zoomFactor * self:GetHeight() * 2)

				if gameName == "dance" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},



		-- third row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth())
				self:y(zoomFactor * self:GetHeight() * 3)

				if gameName == "pump" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 2)
				self:y(zoomFactor * self:GetHeight() * 3)

				if gameName == "dance" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 3)
				self:y(zoomFactor * self:GetHeight() * 3)

				if gameName == "pump" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		}
	}
end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


if choiceName == "Single" then -- 1 Player
	t[#t+1] = drawNinePanelPad(3, -xshift - 14)..{
		OffCommand=cmd(linear,0.2; diffusealpha,0)
	}

elseif choiceName == "Versus" then -- 2 Players
	t[#t+1] = drawNinePanelPad(2,-xshift - WideScale(70,80))..{
		OffCommand=cmd(sleep,0.12; linear,0.2; diffusealpha,0)
	}
	t[#t+1] = drawNinePanelPad(5, xshift - WideScale(70,80))..{
		OffCommand=cmd(sleep,0.24; linear,0.2; diffusealpha,0)
	}

elseif choiceName == "Double" then -- Double
	t[#t+1] = drawNinePanelPad(4,-xshift - WideScale(60,70))..{
		OffCommand=cmd(sleep,0.36; linear,0.2; diffusealpha,0)
	}
	t[#t+1] = drawNinePanelPad(4, xshift - WideScale(60,70))..{
		OffCommand=cmd(sleep,0.48; linear,0.2; diffusealpha,0)
	}

elseif choiceName == "Solo" then -- Solo
	t[#t+1] = drawNinePanelPad(3, -xshift - 14)..{
		OffCommand=cmd(linear,0.2; diffusealpha,0)
	}

end

return t