local color_used, color_unused, padNum, style = unpack(...)

color_used   = color_used   or {1, 1, 1, 1.0}
color_unused = color_unused or (DarkUI() and {0.25,0.25,0.25,1} or {1, 1, 1, 0.3})
padNum = padNum or 1
style  = style  or (GAMESTATE:GetCurrentStyle() and GAMESTATE:GetCurrentStyle():GetName())


local zoom = SL_WideScale(0.435, 0.525)
local game = GAMESTATE:GetCurrentGame():GetName()

local init = function(self, col, row)
	self:zoom(zoom)
	self:x(zoom * self:GetWidth()  * (col-1))
	self:y(zoom * self:GetHeight() * (row-2))
	return self
end

local layouts = {
	dance    = { false, true,  false, true,  false, true,  false, true,  false },
	pump     = { true,  false, true,  false, true,  false, true,  false, true  },
	techno   = { true,  true,  true,  true,  false, true,  true,  true,  true  },
	solo     = { true,  true,  true,  true,  false, true,  false, true,  false },
	inactive = { false, false, false, false, false, false, false, false, false }
}



-- -----------------------------------------------------------------------
-- variables specific to IsSpooky()

local rotations = {
	315,   0,  45,
	270,   0,  90,
	225, 180, 135,
}

local effect_offsets = {}
effect_offsets.dance = {}
effect_offsets.dance.single = {{
	0, 2, 0,
	0, 0, 3,
	0, 1, 0,
}}
effect_offsets.dance.versus = {
	effect_offsets.dance.single[1],
	effect_offsets.dance.single[1]
}
effect_offsets.dance.double = {
	effect_offsets.dance.single[1],
	{
		0, 6, 0,
		4, 0, 7,
		0, 5, 0,
	}
}
effect_offsets.dance.solo = {{
	1, 5, 2,
	3, 0, 4,
	0, 0, 0,
}}

effect_offsets.pump = {}
effect_offsets.pump.single = {{
	3, 0, 2,
	0, 1, 0,
	4, 0, 0,
}}
effect_offsets.pump.versus = {
	effect_offsets.pump.single[1],
	effect_offsets.pump.single[1]
}
effect_offsets.pump.double = {
	{
		0, 0, 3,
		0, 1, 0,
		2, 0, 4,
	},
	{
		5, 0, 7,
		0, 8, 0,
		6, 0, 9,
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


local spooky_bpm = 120
local spooky_bps = spooky_bpm/60
local globalOffset = PREFSMAN:GetPreference("GlobalOffsetSeconds")
local footspeed, old_footspeed = false, nil

local Update = function(self, delta)
	beat = (self:GetSecsIntoEffect() + globalOffset) * (spooky_bps)
	footspeed = (beat >= 48 and beat < 80)
	if footspeed ~= old_footspeed then
		old_footspeed = footspeed
		if footspeed then
			self:playcommand("FootSpeed")
		else
			self:playcommand("NotFootSpeed")
		end
	end
end
-- -----------------------------------------------------------------------

local pad = Def.ActorFrame{}
pad.OnCommand=function(self)
	if IsSpooky() and SCREENMAN:GetTopScreen():GetName()=="ScreenSelectStyle" then
		self:effectclock('music'):SetUpdateFunction( Update )
	end
end

for row=0,2 do
	for col=0,2 do
		local panel_af = Def.ActorFrame{}
		panel_af.InitCommand=function(self)  end
		panel_af.SetCommand=function(self, params)
			local layout = layouts[game] or layouts.dance

			-- simplify the style string to handle technomotion's single8 and double8
			style = style:gsub("8", "")

			if   game=="dance"
			and style=="solo"
			then
				layout = layouts.solo
			end

			if  params and params.Player
			and not GAMESTATE:IsHumanPlayer(params.Player)
			and style ~= "double"
			then
				layout = layouts.inactive
			end

			self:playcommand("Reassess", layout)
		end

		panel_af[#panel_af+1] = LoadActor("rounded-square.png")..{
			InitCommand=function(self) init(self, col, row) end,
			ReassessCommand=function(self, layout)
				if layout[row*3+col+1] then
					self:diffuse(color_used)
				else
					self:diffuse(color_unused)
				end
			end
		}

		-- https://www.youtube.com/watch?v=PKx_ihQ7mrY&lc=UgxXSurH391nm907OEh4AaABAg
		if IsSpooky() then
			panel_af[#panel_af+1] = LoadActor( THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Spider.png") )..{
				InitCommand=function(self)
					init(self, col, row):rotationz(rotations[row*3+col+1])
				end,
				ReassessCommand=function(self, layout)
					local i = row*3+col+1
					self:visible( layout[i] )

					if layout[i] then
						self:diffuseblink():effectcolor1(0,0,0,1):effectcolor2(1,1,1,1)
						self:effectclock("beatnooffset")
						self:effectoffset(effect_offsets[game][style][padNum][i])
						self:effectperiod(2)
						self:effecttiming(0,0,0, 0.5, num_panels[game][style] - 0.5)
					end
				end,
				NotFootSpeedCommand=function(self)
					local i = row*3+col+1
					self:effectclock("beatnooffset")
					self:effectoffset(effect_offsets[game][style][padNum][i])
					self:effectperiod(2)
					self:effecttiming(0,0,0, 0.5, num_panels[game][style] - 0.5)
				end,
				FootSpeedCommand=function(self)
					local i = row*3+col+1
					self:effectclock("beatnooffset")
					self:effectoffset(effect_offsets[game][style][padNum][i]*0.25)
					self:effectperiod(0.5)
					self:effecttiming(0,0,0, 0.125, num_panels[game][style]*0.25 - 0.125)
				end
			}
		end

		pad[#pad+1] = panel_af
	end
end

return pad