local color_used, color_unused, padNum, style = unpack(...)

color_used   = color_used   or {1, 1, 1, 1.0}
color_unused = color_unused or (DarkUI() and {0.25,0.25,0.25,1} or {1, 1, 1, 0.3})
padNum = padNum or 1
style  = style  or (GAMESTATE:GetCurrentStyle() and GAMESTATE:GetCurrentStyle():GetName())


local zoom = SL_WideScale(0.435, 0.525)
local game = GAMESTATE:GetCurrentGame():GetName()

local init_panel = function(self, col, row)
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

local pad = Def.ActorFrame{}

if IsSpooky() then
	local spooky_bpm = 120
	local spooky_bps = spooky_bpm/60
	local globalOffset = PREFSMAN:GetPreference("GlobalOffsetSeconds")
	local footspeed, old_footspeed = false, nil

	local Update = function(self, delta)
		beat = (self:GetSecsIntoEffect() + globalOffset) * (spooky_bps)
		footspeed = (beat >= 48 and beat < 80)
		if footspeed ~= old_footspeed then
			old_footspeed = footspeed
			self:playcommand(footspeed and "Footspeed" or "NotFootspeed")
		end
	end

	pad.OnCommand=function(self)
		if SCREENMAN:GetTopScreen():GetName()=="ScreenSelectStyle" then
			self:effectclock('music'):SetUpdateFunction( Update )
		end
	end
end

for row=0,2 do
	for col=0,2 do
		local panel_index = row*3+col+1

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
			InitCommand=function(self) init_panel(self, col, row) end,
			ReassessCommand=function(self, layout)
				if layout[panel_index] then
					self:diffuse(color_used)
				else
					self:diffuse(color_unused)
				end
			end
		}

		-- -----------------------------------------------------------------------
		-- setup specific to IsSpooky() is mostly off in
		-- ExtraSpooky.lua in order to keep this file less cluttered
		if IsSpooky() then
			local spider = LoadActor("./ExtraSpooky.lua", {game, style, padNum, panel_index})
			spider.InitCommand=function(self)
				init_panel(self, col, row)
			end
			spider.ReassessCommand=function(self, layout)
				self:visible( layout[panel_index] )
			end

			panel_af[#panel_af+1] = spider
		end
		-- -----------------------------------------------------------------------

		pad[#pad+1] = panel_af
	end
end

return pad