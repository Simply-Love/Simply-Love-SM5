-- the metatable for an item in the sort_wheel
return {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
				end,
				OnCommand=function(subself)
					subself:y((((self.rh_index-1)%10)+1)*30)
					subself:addx(self.rh_index <= 10 and -150 or WideScale(90,150))
				end
			}

			-- text
			af[#af+1] = Def.BitmapText{
				File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
				InitCommand=function(subself)
					self.bmt = subself
					subself:diffusealpha(0):halign(0):x(-100)
				end,
				OnCommand=function(subself)
					subself:sleep(0.1):smooth(0.25):diffusealpha(1)
				end
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()

			if has_focus then
				self.container:accelerate(0.15)
				self.container:zoom(1.2)
				self.container:diffuse( GetCurrentColor() )
				self.container:glow(color("1,1,1,0.5"))
			else
				self.container:glow(color("1,1,1,0"))
				self.container:accelerate(0.15)
				self.container:zoom(1.1)
				self.container:diffuse(color("#888888"))
				self.container:glow(color("1,1,1,0"))
			end
		end,

		set = function(self, info)
			if not info then return end
			self.info = info
			self.rh_index = info[1]
			self.text = info[2]
			self.bmt:settext(self.text)
		end
	}
}