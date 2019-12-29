-- the metatable for an item in songDescription.lua's sick_wheel tagItem
local w, h = 80, 25

return {
	__index = {
		create_actors = function(self, name)
			self.name=name

			return Def.ActorFrame{
				Name=name,
				InitCommand=function(subself)
					self.container = subself
				end,
				OnCommand=function(subself) subself:sleep(0.2):queuecommand("Appear") end,
				AppearCommand=function(subself) subself:visible(true):linear(0.15):diffusealpha(1) end,
				
				Def.Quad{
					Name="Quad",
					InitCommand=function(subself)
						subself:zoomto(85,18):diffuse(Color.Green)
						self.box = subself
					end
				},
				LoadFont("Common Normal")..{
					InitCommand=function(subself)
						self.bmt = subself
						subself:maxwidth(80):MaskDest()
					end,
				},
				LoadActor("./img/start_glow.png")..{
					Name="Glow",
					InitCommand=function(subself)
						-- start_glow.png is 600px wide, but the space carved out of the middle is only 500px wide
						subself:zoomto( subself:GetWidth()/6,25 )
						self.glowBorder = subself
					end,
					--OnCommand=function(self) self:diffuseshift():effectcolor1(color("#33aa33")):effectcolor2(color("#55cc55")) end,
					OnCommand=function(self) self:diffuseshift():effectcolor1(color("#33aa33")):effectcolor2(color("#55cc55")) end,
				},
			}
		end,
		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			self.container:y(25 * item_index)
		end,
		set = function(self, tag)
			self.tag = tag
			if not tag then 
				self.bmt:settext("") 
				self.glowBorder:visible(false)
				self.box:visible(false) 
				return 
			end
			self.bmt:settext(tag.displayName or "")
			self.glowBorder:visible(true) 
			self.box:visible(true)
			if tag.displayName == "BPM Changes" or tag.displayName == "Filters Active" then self.box:diffuse(Color.Red)
			elseif tag.displayName == "No Tags Set" then self.box:diffuse(Color.Black)
			else self.box:diffuse(Color.Green) end --TODO allow player to choose color for each tag
		end
	}
}