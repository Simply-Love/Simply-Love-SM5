local _zoom = SL_WideScale(0.435, 0.525)
local _game = GAMESTATE:GetCurrentGame():GetName()

local init = function(self, col, row)
	self:zoom(_zoom)
	self:x(_zoom * self:GetWidth()  * (col-1))
	self:y(_zoom * self:GetHeight() * (row-2))
	return self
end

local layouts = {
	dance    = { false, true,  false, true,  false, true,  false, true,  false },
	pump     = { true,  false, true,  false, true,  false, true,  false, true  },
	techno   = { true,  true,  true,  true,  false, true,  true,  true,  true  },
	solo     = { true,  true,  true,  true,  false, true,  false, true,  false },
	inactive = { false, false, false, false, false, false, false, false, false }
}

local rotations = {315, 0, 45, 270, 0, 90, 225, 180, 135 }

return function(color_used, color_unused)

	color_used   = color_used   or {1, 1, 1, 1.0}
	color_unused = color_unused or (DarkUI() and {0.25,0.25,0.25,1} or {1, 1, 1, 0.3})

	local layout = layouts[_game] or layouts.dance

	local pad = Def.ActorFrame{}

	for row=0,2 do
		for col=0,2 do
			pad[#pad+1] = LoadActor("rounded-square.png")..{
				InitCommand=function(self) init(self, col, row) end,
				SetCommand=function(self, params)
					local layout = layouts[_game] or layouts.dance

					local style = params.style or (GAMESTATE:GetCurrentStyle() and GAMESTATE:GetCurrentStyle():GetName())
					-- simplify the style string to handle technomotion's single8 and double8
					style = style:gsub("8", "")

					if _game=="dance" and style=="solo" then layout = layouts.solo end

					if params.Player then
						if not GAMESTATE:IsHumanPlayer(params.Player) and style ~= "double" then
							layout = layouts.inactive
						end
					end

					if layout[row*3+col+1] then
						self:diffuse(color_used)
					else
						self:diffuse(color_unused)
					end
				end
			}

			if IsSpooky() then
				pad[#pad+1] = LoadActor( THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Spider.png") )..{
					InitCommand=function(self) init(self, col, row):rotationz(rotations[row*3+col+1]) end,
					SetCommand=function(self, params)
						local layout = layouts[_game] or layouts.dance

						local style = params.style or (GAMESTATE:GetCurrentStyle() and GAMESTATE:GetCurrentStyle():GetName())
						-- simplify the style string to handle technomotion's single8 and double8
						style = style:gsub("8", "")

						if _game=="dance" and style=="solo" then layout = layouts.solo end

						if params.Player then
							if not GAMESTATE:IsHumanPlayer(params.Player) and style ~= "double" then
								layout = layouts.inactive
							end
						end

						self:visible( layout[row*3+col+1] )
					end
				}
			end
		end
	end

	return pad
end