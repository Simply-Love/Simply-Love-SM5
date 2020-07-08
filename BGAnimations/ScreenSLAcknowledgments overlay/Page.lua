local args = ...
local page_num = args[1]
local people   = args[2]

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
-- collectively represent a single avatar
-- abstract out what is common between both those scenarios into this function
-- and append extra functionality (fading, etc.) later, if needed
local PictureActor = function( path, _y )
	local spr = Def.Sprite{
		Texture=THEME:GetPathB("ScreenSLAcknowledgments", "overlay/img/"..path),
		InitCommand=function(self)
			src_width  = self:GetTexture():GetSourceWidth()
			src_height = self:GetTexture():GetSourceHeight()

			-- check for animated sprite textures
			local w, h = path:match(" (%d+)x(%d+)")
			if w and h then
				src_width = src_width/w
				src_height = src_height/h
				self:SetAllStateDelays(0.035)
			end

			img_height = img_width * (src_height/src_width)

			self:zoomto(img_width, img_height)
				:halign(0):valign(0)
				:x(-space.w/2 + padding*2)
				:y(padding + _y)

			if path:match(".mp4") then
				self:animate(false):loop(false)
			end
		end
	}

	return spr
end

local viewcount = 0
local page_af = Def.ActorFrame{
	Name="Page"..page_num,
	InitCommand=function(self) self:visible(false):xy(_screen.cx, header_height) end,
	HideCommand=function(self) self:visible(false) end,
	["ShowPage"..page_num.."Command"]=function(self) self:visible(true) end,
}

for i=1, #people do
	local quad_y = padding*i + box_height*(i-1)


	-- background quad
	page_af[#page_af+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(space.w-padding*2, box_height)
				:valign(0)
				:diffuse(ThemePrefs.Get("RainbowMode") and {0,0,0,0.9} or {0.25,0.25,0.25,0.75} )
				:y(quad_y)
		end
	}

	-- picture
	if people[i].Img then

		-- single image; add it directly to the page ActorFrame
		if type(people[i].Img)=="string" and people[i].Img ~= "" then
			page_af[#page_af+1] = PictureActor( people[i].Img, quad_y )

		-- multiple images
		elseif type(people[i].Img)=="table" then

			-- create a sub-ActorFrame, so we can add the multiple images
			-- to this sub-AF and later add this sub-AF to the page AF
			local _af = Def.ActorFrame{}


			for j=1, #people[i].Img do
				local spr = PictureActor(people[i].Img[j], quad_y)

				-- multiple images and multiple About texts
				if people[i].About and type(people[i].About)=="table" and #people[i].About==#people[i].Img then


					spr["ShowPage"..page_num.."Command"]=function(self)
						self:visible( ((viewcount % #people[i].Img)+1) == j )
						if people[i].Img[j]:match(".mp4") then
							self:animate(self:GetVisible())
						end
					end

				-- multiple images, but only one About text
				-- add functions for a "slideshow" effect that automatically cycles through images
				else
					spr.OnCommand=function(self)
						self:diffusealpha( j==1 and 1 or 0 ):sleep( (j-1)*display_time ):queuecommand("Loop")
					end
					spr.LoopCommand=function(self)
						if self:GetDiffuseAlpha() == 0 then
							self:linear(fade_time):diffusealpha(1)
						end

						self:sleep( display_time )
							:linear(fade_time):diffusealpha(0)
							:sleep( (#people[i].Img-1) * display_time )
							:queuecommand("Loop")
					end
					spr.HideCommand=function(self)
						self:stoptweening():queuecommand("On")
					end
				end

				_af[#_af+1] = spr
			end

			page_af[#page_af+1] = _af
		end
	end

	-- name / handle
	page_af[#page_af+1] = Def.BitmapText{
		Font="Common Normal",
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
	local about = Def.BitmapText{
		Font="Common Normal",
		InitCommand=function(self)
			self:valign(0):halign(0):zoom(0.8)
				:_wrapwidthpixels((space.w - padding*4 - img_width) * (1/0.85) )
				:x(-space.w/2 + padding*4 + img_width)
				:y(padding + quad_y )


			if type(people[i].About) == "string" then
				self:settext(people[i].About)
			elseif type(people[i].About) == "table" then
				self:settext(people[i].About[1])
			end

			if #people >= 3
			and people[i].Name ~= "Paul J Kim" -- forever my favorite special case
			then
				self:vertspacing(-2)
			end
		end
	}

	if type(people[i].About) == "table" then
		about["ShowPage"..page_num.."Command"]=function(self)
			self:settext( people[i].About[(viewcount % #people[i].About)+1] )
			-- increment until viewcount reaches table size
			viewcount = math.min(viewcount + 1, #people[i].About - 1)
		end
	end

	page_af[#page_af+1] = about
end

return page_af
