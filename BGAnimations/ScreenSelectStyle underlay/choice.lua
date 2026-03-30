local args = ...
local choiceName = args[1].name
local frame_x = args[1].x
local pads = args[1].pads
local choice_index = args[2]

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

		if ThemePrefs.Get("VisualStyle")=="Gay" and not HolidayCheer() then
			self:bob():effectmagnitude(0,0,0):effectclock('bgm'):effectperiod(0.666)
		end
	end,
	GainFocusCommand=function(self)
		self:finishtweening():linear(0.125):zoom(1)
		if ThemePrefs.Get("VisualStyle")=="Gay" and not HolidayCheer() then
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
		-- if this choice was chosen, fluidly zoom in a tiny amount then zoom to 0
		-- similar to animation from SelectProfile
		self:finishtweening():bouncebegin(0.415):zoom(0)
	end,
	NotChosenCommand=function(self)
		-- if this choice wasn't chosen, fade out
		self:finishtweening():sleep(0.1):smooth(0.2):diffusealpha(0)
	end,

	LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
		Text=THEME:GetString("ScreenSelectStyle", choiceName:gsub("^%l", string.upper)),
		InitCommand=function(self)
			self:shadowlength(1):y(37):zoom(0.5)
		end,
		GainFocusCommand=function(self) if ThemePrefs.Get("VisualStyle")=="Gay" then self:rainbowscroll(true) end end,
		LoseFocusCommand=function(self) if ThemePrefs.Get("VisualStyle")=="Gay" then self:rainbowscroll(false) end end,
	}
}

-- draw as many pads as needed for this choice
for i, pad in ipairs(pads) do
	af[#af+1] = LoadActor("./pad.lua", {pad.color, {0.2,0.2,0.2,1}, i, choiceName})..{
		InitCommand=function(self)
			self:x(pad.offset):playcommand("Set")
		end,
	}
end

return af