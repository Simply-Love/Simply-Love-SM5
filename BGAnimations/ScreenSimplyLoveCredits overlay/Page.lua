local people = ...

local padding = 10
local header_height = 32
local space = { w=640, h=_screen.h - header_height }
local box_height = (space.h - (padding * (#people+1))) / #people
local img_height = box_height-padding*4

local af = Def.ActorFrame{ InitCommand=function(self) self:y(header_height) end }

for i=1, #people do
	local quad_y = padding*i + box_height*(i-1)

	-- background quad
	af[#af+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(space.w-padding*2, box_height)
				:valign(0)
				:diffuse(0.25,0.25,0.25, ThemePrefs.Get("RainbowMode") and 0.85 or 0.75 )
				:y(quad_y)
		end
	}

	-- picture
	if people[i].Img and people[i].Img ~= "" then
		af[#af+1] = Def.Sprite{
			Texture="./img/"..people[i].Img,
			InitCommand=function(self)
				self:zoomto(img_height, img_height)
					:halign(0):valign(0)
					:x(-space.w/2 + padding*2)
					:y(padding + quad_y)
			end
		}
	end

	-- name / handle
	af[#af+1] = Def.BitmapText{
		Font="_miso",
		Text=people[i].Name,
		InitCommand=function(self)
			self:valign(0)
				:maxwidth(img_height + padding)
				:x(-space.w/2 + padding*2 + img_height/2)
				:y(padding*1.5 + quad_y + img_height)
		end
	}

	-- about
	af[#af+1] = Def.BitmapText{
		Font="_miso",
		Text=people[i].About,
		InitCommand=function(self)
			self:valign(0):halign(0):zoom(0.8)
				:wrapwidthpixels((space.w - padding*4 - img_height) * (1/0.85) )
				:x(-space.w/2 + padding*4 + img_height)
				:y(padding + quad_y )
		end
	}
end

return af