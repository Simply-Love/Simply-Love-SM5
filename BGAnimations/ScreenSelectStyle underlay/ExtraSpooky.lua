local game, style, padNum, panel_index = unpack(...)

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

return LoadActor( THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Spider.png") )..{
	OnCommand=function(self)
		self:rotationz(rotations[panel_index])
		self:diffuseblink():effectcolor1(0,0,0,1):effectcolor2(1,1,1,1)
		self:effectclock("beatnooffset")
	end,
	NotFootspeedCommand=function(self)
		self:effectoffset(effect_offsets[game][style][padNum][panel_index])
		self:effectperiod(2)
		self:effecttiming(0,0,0, 0.5, num_panels[game][style] - 0.5)
	end,
	FootspeedCommand=function(self)
		self:effectoffset(effect_offsets[game][style][padNum][panel_index]*0.25)
		self:effectperiod(0.5)
		self:effecttiming(0,0,0, 0.125, num_panels[game][style]*0.25 - 0.125)
	end
}