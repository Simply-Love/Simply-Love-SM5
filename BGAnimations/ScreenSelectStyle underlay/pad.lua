local _zoom = WideScale(0.435,0.525)
local _game = GAMESTATE:GetCurrentGame():GetName()

local layouts = {
	dance  = { false, true,  false, true,  false, true,  false, true,  false },
	pump   = { true,  false, true,  false, true,  false, true,  false, true  },
	techno = { true,  true,  true,  true,  false, true,  true,  true,  true  },
	solo   = { true,  true,  true,  true,  false, true,  false, true,  false }
}

return function(choiceName, color_used, color_unused, xoffset)

	color_used   = color_used   or {  1,  1,  1,  1}
	color_unused = color_unused or {0.9,0.9,0.9,0.5}
	xoffset      = xoffset or 0

	local layout = (_game=="dance" and choiceName=="solo" and layouts.solo) or layouts[_game] or layouts.dance

	local pad = Def.ActorFrame{ InitCommand=function(self) self:x(xoffset) end }

	for row=0,2 do
		for col=0,2 do
			pad[#pad+1] = LoadActor("rounded-square.png")..{
				InitCommand=function(self)
					self:zoom(_zoom)

					self:x(_zoom * self:GetWidth()  * (col-1))
					self:y(_zoom * self:GetHeight() * (row-2))

					if layout[row*3+col+1] then
						self:diffuse(color_used)
					else
						self:diffuse(color_unused)
					end
				end
			}
		end
	end

	return pad
end