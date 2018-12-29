local people = ...

local padding = 10
local header_height = 32
local space = { w=640, h=_screen.h - header_height }
local box_height = (space.h - (padding * (#people+1))) / math.max(#people,2)
local img_width = box_height-padding*4
local src_width, src_height, img_height

local fade_time = 0.25
local display_time = 3

-- sometimes we just want a single static image to be the avatar
-- sometimes we have a set of images we want to cycle through that
-- collectively reprsent a single avatar
-- abstract out what is common between both those scenarios into this function
-- and append extra functionality (fading, etc.) later, if needed
local PictureActor = function( path, _y )
	return Def.Sprite{
		Texture=THEME:GetPathB("ScreenSimplyLoveCredits", "overlay/img/"..path),
		InitCommand=function(self)
			src_width  = self:GetTexture():GetSourceWidth()
			src_height = self:GetTexture():GetSourceHeight()
			img_height = img_width * (src_height/src_width)

			self:zoomto(img_width, img_height)
				:halign(0):valign(0)
				:x(-space.w/2 + padding*2)
				:y(padding + _y)
		end
	}
end



local af = Def.ActorFrame{ InitCommand=function(self) self:y(header_height) end }

for i=1, #people do
	local quad_y = padding*i + box_height*(i-1)

	-- background quad
	af[#af+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(space.w-padding*2, box_height)
				:valign(0)
				:diffuse(ThemePrefs.Get("RainbowMode") and {0,0,0,0.9} or {0.25,0.25,0.25,0.75} )
				:y(quad_y)
		end
	}

	-- picture
	if people[i].Img then
		if type(people[i].Img)=="string" and people[i].Img ~= "" then
			af[#af+1] = PictureActor( people[i].Img, quad_y )
		elseif type(people[i].Img)=="table" then

			af[#af+1] = Def.ActorFrame{}

			for j=1, #people[i].Img do
				af[#af][j] = PictureActor( people[i].Img[j], quad_y )..{
					OnCommand=function(self)
						self:diffusealpha( j==1 and 1 or 0 ):sleep( (j-1)*display_time ):queuecommand("Loop")
					end,
					LoopCommand=function(self)
						if self:GetDiffuseAlpha() == 0 then
							self:linear(fade_time):diffusealpha(1)
						end

						self:sleep( display_time )
							:linear(fade_time):diffusealpha(0)
							:sleep( (#people[i].Img-1) * display_time )
							:queuecommand("Loop")
					end,
					HideCommand=function(self)
						self:stoptweening():queuecommand("On")
					end
				}
			end
		end
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
