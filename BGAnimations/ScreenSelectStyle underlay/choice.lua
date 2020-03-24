local args = ...
local choiceName = args[1].name
local frame_x = args[1].x
local pads = args[1].pads
local choice_index = args[2]

local _zoom = WideScale(0.435,0.525)
local _game = GAMESTATE:GetCurrentGame():GetName()

local layouts = {
	dance  = { false, true,  false, true,  false, true,  false, true,  false },
	pump   = { true,  false, true,  false, true,  false, true,  false, true  },
	techno = { true,  true,  true,  true,  false, true,  true,  true,  true  },
	solo   = { true,  true,  true,  true,  false, true,  false, true,  false }
}

local layout = (_game=="dance" and choiceName=="solo" and layouts.solo) or layouts[_game] or layouts.dance

-- -----------------------------------------------------------------------

local DrawNinePanelPad = function(color, xoffset)
	local pad = Def.ActorFrame{ InitCommand=function(self) self:x(xoffset) end }

	for row=0,2 do
		for col=0,2 do
			pad[#pad+1] = LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom)

					self:x(_zoom * self:GetWidth()  * (col-1))
					self:y(_zoom * self:GetHeight() * (row-2))

					self:diffuse(layout[row*3+col+1] and color or {0.2, 0.2, 0.2, 1})
				end
			}
		end
	end

	return pad
end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{
	InitCommand=function(self)
		-- I needed a way to keep track of whether each choice (single, versus, double, solo)
		-- was enabled or disabled depending on Premium settings and current coin standings.
		-- We can use aux() to associate arbitrary data with actors in a way that can be
		-- accessed externally without leaking memory. aux() accepts floating point values,
		-- so here I'm using 0 as a stand-in for false and 1 for true.
		self:aux(0)

		self:zoom(0.5):xy( frame_x, _screen.cy + WideScale(0,10) )

		if ThemePrefs.Get("VisualTheme")=="Gay" and not HolidayCheer() then
			self:bob():effectmagnitude(0,0,0):effectclock('bgm'):effectperiod(0.666)
		end
	end,
	GainFocusCommand=function(self)
		self:finishtweening():linear(0.125):zoom(1)
		if ThemePrefs.Get("VisualTheme")=="Gay" and not HolidayCheer() then
			self:effectmagnitude(0,4,0)
		end
	end,
	LoseFocusCommand=function(self)
		self:finishtweening():linear(0.125):zoom(0.5):effectmagnitude(0,0,0)
	end,
	EnableCommand=function(self)
		if self:getaux() == 1 then
			self:diffusealpha(1)
		else
			self:diffusealpha(0.25)
		end
	end,
	ChosenCommand=function(self)
		-- if this choice was chosen...
		-- ...don't do anything differently for now
		-- (maybe I'll revisit this later)
	end,
	NotChosenCommand=function(self)
		-- if this choice wasn't chosen, zoom the entire ActorFrame to 0
		self:finishtweening():smooth(0.333):zoom(0)
	end,

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenSelectStyle", choiceName:gsub("^%l", string.upper)),
		InitCommand=function(self)
			self:shadowlength(1):y(37):zoom(0.5)
		end,
		GainFocusCommand=function(self) if ThemePrefs.Get("VisualTheme")=="Gay" then self:rainbowscroll(true) end end,
		LoseFocusCommand=function(self) if ThemePrefs.Get("VisualTheme")=="Gay" then self:rainbowscroll(false) end end,
		NotChosenCommand=function(self)
			self:finishtweening():sleep(0.1):smooth(0.25):cropleft(1)
		end
	}
}

-- draw as many pads as needed for this choice
for pad in ivalues(pads) do
	af[#af+1] = DrawNinePanelPad(pad.color, pad.offset)
end

return af