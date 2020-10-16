local color_used, color_unused, padNum, style = unpack(...)

color_used   = color_used   or {1, 1, 1, 1.0}
color_unused = color_unused or (DarkUI() and {0.25,0.25,0.25,1} or {1, 1, 1, 0.3})
padNum = padNum or 1
style  = style  or (GAMESTATE:GetCurrentStyle() and GAMESTATE:GetCurrentStyle():GetName())


local zoom = SL_WideScale(0.435, 0.525)
local game = GAMESTATE:GetCurrentGame():GetName()

local init_panel = function(self, col, row, z)
	self:zoom(z)
	self:x(z * self:GetWidth()  * (col-1))
	self:y(z * self:GetHeight() * (row-2))
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

for row=0,2 do
	for col=0,2 do
		local panel_index = row*3+col+1

		local panel_af = Def.ActorFrame{}
		panel_af.InitCommand=function(self)  end
		panel_af.SetCommand=function(self, params)
			local layout = layouts[game] or layouts.dance

			if game=="dance" and style=="solo" then
				layout = layouts.solo
			end

			if  params and params.Player
			and not GAMESTATE:IsHumanPlayer(params.Player)
			and style ~= "double"
			then
				layout = layouts.inactive
			end

			self:GetParent():playcommand("Reassess", layout)
		end

		panel_af[#panel_af+1] = LoadActor("rounded-square.png")..{
			InitCommand=function(self) init_panel(self, col, row, zoom) end,
			ReassessCommand=function(self, layout)
				if layout[panel_index] then
					self:diffuse(color_used)
				else
					self:diffuse(color_unused)
				end
			end
		}

		pad[#pad+1] = panel_af
	end
end

-- -----------------------------------------------------------------------
-- https://www.youtube.com/watch?v=PKx_ihQ7mrY&lc=UgxXSurH391nm907OEh4AaABAg
if IsSpooky() then
	pad[#pad+1] = LoadActor("./ExtraSpooky.lua", {game, style, padNum, zoom, init_panel})
end
-- -----------------------------------------------------------------------

return pad