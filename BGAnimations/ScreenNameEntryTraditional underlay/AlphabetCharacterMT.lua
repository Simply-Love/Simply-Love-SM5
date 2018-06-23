local charWidth = 40

local alphabet_character_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=name,
				InitCommand=function(subself)
					self.container = subself
					subself:diffusealpha(0)
					subself:MaskDest()
				end,
				OnCommand=cmd(linear,0.25; diffusealpha, 1),
				HideCommand=cmd(linear, 0.25; diffusealpha, 0),

				Def.BitmapText{
					Font="_wendy white",
					InitCommand=function(subself)
						self.bmt = subself
						subself:zoom(0.5)
						subself:diffuse(0.75,0.75,0.75,1)
					end,
					OnCommand=cmd(sleep, 0.2; linear, 0.25 ),
				}
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)

			self.container:finishtweening()

			if item_index <= 0 or  item_index >= num_items-1 then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end

			if has_focus then
				self.bmt:diffuse(1,1,1,1)
			else
				self.bmt:diffuse(0.75,0.75,0.75,1)
			end

			self.container:linear(0.075)
			self.container:x(charWidth * (item_index - math.ceil(num_items/2)))

		end,

		set = function(self, character)

			if not character then return end

			self.bmt:settext( character )

		end
	}
}

return alphabet_character_mt
