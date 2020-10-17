local game, style, padNum,
      zoom, init_panel = unpack(...)

local rotations = {
	315,   0,  45,
	270,   0,  90,
	225, 180, 135,
}

local effect_offsets = {}
effect_offsets.dance = {}
effect_offsets.dance.single = {{
	0, 1, 0,
	3, 0, 0,
	0, 2, 0,
}}
effect_offsets.dance.versus = {
	effect_offsets.dance.single[1],
	effect_offsets.dance.single[1]
}
effect_offsets.dance.double = {
	effect_offsets.dance.single[1],
	{
		0, 5, 0,
		7, 0, 4,
		0, 6, 0,
	}
}
effect_offsets.dance.solo = {{
	1, 5, 2,
	3, 0, 4,
	0, 0, 0,
}}

effect_offsets.pump = {}
effect_offsets.pump.single = {
	{
		1, 0, 3,
		0, 2, 0,
		0, 0, 4,
	}
}
effect_offsets.pump.versus = {
	effect_offsets.pump.single[1],
	effect_offsets.pump.single[1]
}
effect_offsets.pump.double = {
	{
		1, 0, 4,
		0, 2, 0,
		0, 0, 3,
	},
	{
		6, 0, 8,
		0, 7, 0,
		5, 0, 9,
	}
}

effect_offsets.techno = {}
effect_offsets.techno.single = {{
	1, 4, 0,
	3, 0, 6,
	5, 7, 2,
}}
effect_offsets.techno.versus = {
	effect_offsets.techno.single[1],
	effect_offsets.techno.single[1]
}
effect_offsets.techno.double = {
	{
		0, 4, 1,
		2, 0, 3,
		6, 5, 7,
	},
	{
		 8, 12,  9,
		10,  0, 11,
		14, 13, 15,
	},
}

effect_offsets.kb7  = effect_offsets.dance
effect_offsets.para = effect_offsets.dance

local num_panels = {}
num_panels.dance = { single=4, versus=4, double=8, solo=6 }
num_panels.pump  = { single=5, versus=4, double=10 }
num_panels.techno= { single=8, versus=8, double=16 }
num_panels.kb7   = num_panels.dance
num_panels.para  = num_panels.dance

-- -----------------------------------------------------------------------
local action_index = 1
local actions = {
	{  0,    function(_af) _af:playcommand("Normal") end },

	{  6.50, function(_af) _af:playcommand("AllOn")  end },
	{  6.75, function(_af) _af:playcommand("AllOff") end },
	{  7,    function(_af) _af:playcommand("AllOn")  end },
	{  7.25, function(_af) _af:playcommand("Normal") end },

	{ 14.5,  function(_af) _af:playcommand("AllOn")  end },
	{ 14.75, function(_af) _af:playcommand("AllOff") end },
	{ 15,    function(_af) _af:playcommand("AllOn")  end },
	{ 15.25, function(_af) _af:playcommand("Normal") end },

	{ 22.5,  function(_af) _af:playcommand("AllOn")  end },
	{ 22.75, function(_af) _af:playcommand("AllOff") end },
	{ 23,    function(_af) _af:playcommand("AllOn")  end },
	{ 23.25, function(_af) _af:playcommand("Normal") end },

	{ 30.5,  function(_af) _af:playcommand("AllOn")  end },
	{ 30.75, function(_af) _af:playcommand("AllOff") end },
	{ 31,    function(_af) _af:playcommand("AllOn")  end },
	{ 31.25, function(_af) _af:playcommand("Normal") end },

	{ 38.5,  function(_af) _af:playcommand("AllOn")  end },
	{ 38.75, function(_af) _af:playcommand("AllOff") end },
	{ 39,    function(_af) _af:playcommand("AllOn")  end },
	{ 39.25, function(_af) _af:playcommand("Normal") end },

	{ 46.5,  function(_af) _af:playcommand("AllOn")  end },
	{ 46.75, function(_af) _af:playcommand("AllOff") end },
	{ 47,    function(_af) _af:playcommand("AllOn")  end },
	{ 47.25, function(_af) _af:playcommand("Normal") end },

	{ 48,   function(_af) _af:playcommand("Footspeed") end },
	{ 80,   function(_af) _af:playcommand("Normal")    end },

	{ 95.75,   function(_af) _af:playcommand("AllOff"); action_index = 1 end },
}

local spooky_bpm = 120
local spooky_bps = spooky_bpm/60
local globalOffset = PREFSMAN:GetPreference("GlobalOffsetSeconds")

local last_beat = -1
local beat = 0

local Update = function(af, delta)
	beat = (af:GetSecsIntoEffect() + globalOffset) * spooky_bps

	if beat < last_beat then action_index = 1 end

	if beat >= actions[action_index][1] then
		actions[action_index][2](af)
		action_index = action_index + 1
	end

	last_beat = beat
end

local noop = function() end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}
af.InitCommand=function(self)
	self:effectclock('music'):SetUpdateFunction( Update )
end
af.OnCommand=function(self)
	-- if we're not on ScreenSelectStyle,
	-- replace the real Update function with a noop
	if SCREENMAN:GetTopScreen():GetName() ~= "ScreenSelectStyle" then
		self:SetUpdateFunction( noop )
	end
end


for row=0,2 do
	for col=0,2 do
		local panel_index = row*3+col+1

		af[#af+1] = LoadActor( THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Spider.png") )..{
			InitCommand=function(self)
				init_panel(self, col, row, zoom)
			end,
			ReassessCommand=function(self, layout)
				self:visible( layout[panel_index] )
			end,
			OnCommand=function(self)
				self:stopeffect()
				self:rotationz(rotations[panel_index]):diffuse(0,0,0,1)

				-- for ScreenGameplay and other headers that these will appear in
				if SCREENMAN:GetTopScreen():GetName() ~= "ScreenSelectStyle" then
					-- sync all spiders to blink with beatnooffset, same as musicwheel cursor
					self:diffuseblink():effectcolor1(0,0,0,1):effectcolor2(1,1,1,1):effectclock("beatnooffset")
				else
					self:playcommand("Normal")
				end
			end,

			AllOnCommand=function(self)
				self:diffuseblink():effectcolor1(1,1,1,1):effectcolor2(1,1,1,1):effectperiod(spooky_bps)
			end,
			AllOffCommand=function(self)
				self:diffuseblink():effectcolor1(0,0,0,1):effectcolor2(0,0,0,1):effectperiod(spooky_bps)
			end,

			NormalCommand=function(self)
				self:diffuseblink():effectcolor1(0,0,0,1):effectcolor2(1,1,1,1)
				self:effectclock("beatnooffset")
				self:effectoffset(effect_offsets[game][style][padNum][panel_index])
				self:effectperiod(2)
				self:effecttiming(0,0,0, 0.5, num_panels[game][style] - 0.5)
			end,
			FootspeedCommand=function(self)
				self:diffuseblink():effectcolor1(0,0,0,1):effectcolor2(1,1,1,1)
				self:effectclock("beatnooffset")
				self:effectoffset(effect_offsets[game][style][padNum][panel_index]*0.25)
				self:effectperiod(0.5)
				self:effecttiming(0,0,0, 0.125, num_panels[game][style]*0.25 - 0.125)
			end,
		}
	end
end

return af