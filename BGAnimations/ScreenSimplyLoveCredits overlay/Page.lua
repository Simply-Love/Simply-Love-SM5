local people = ...

local padding = 10
local header_height = 32
local space = { w=640, h=_screen.h - header_height }
local box_height = math.min( (space.h - (padding * (#people+1))) / #people, space.h/2)
local img_width = box_height-padding*4
local src_width, src_height, img_height

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
				src_width  = self:GetTexture():GetSourceWidth()
				src_height = self:GetTexture():GetSourceHeight()/self:GetTexture():GetNumFrames()
				img_height = img_width * (src_height/src_width)

				self:zoomto(img_width, img_height)
					:halign(0):valign(0)
					:x(-space.w/2 + padding*2)
					:y(padding + quad_y)
					:SetAllStateDelays(2)
			end
		}
	end

	-- name / handle
	af[#af+1] = Def.BitmapText{
		Font="_miso",
		Text=people[i].Name,
		InitCommand=function(self)
			local zoom_factor = scale(#people,2,5,1,0.75)
			self:valign(0)
				:zoom( zoom_factor )
				:maxwidth((img_width + padding) * 1/zoom_factor)
				:x(-space.w/2 + padding*2 + img_width/2)
				:y(padding*1.5 + quad_y + img_width)
		end
	}

	-- about
	af[#af+1] = Def.BitmapText{
		Font="_miso",
		Text=people[i].About,
		InitCommand=function(self)
			self:valign(0):halign(0):zoom(0.8)
				:wrapwidthpixels((space.w - padding*4 - img_width) * (1/0.85) )
				:x(-space.w/2 + padding*4 + img_width)
				:y(padding + quad_y )
		end
	}
end

return af