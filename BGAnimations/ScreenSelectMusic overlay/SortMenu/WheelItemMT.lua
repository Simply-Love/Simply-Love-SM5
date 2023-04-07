-- the metatable for an item in the sort_wheel
return {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
					subself:MaskDest()
					subself:diffusealpha(0)
				end,
			}

			-- top text
			af[#af+1] = Def.BitmapText{
				Font="Common Normal",
				InitCommand=function(subself)
					self.top_text = subself
					subself:zoom(1.15):y(-15):diffusealpha(0)
				end,
				OnCommand=function(subself)
					subself:sleep(0.13):linear(0.05):diffusealpha(1)
				end
			}

			-- bottom text
			af[#af+1] = Def.BitmapText{
				Font=ThemePrefs.Get("ThemeFont") .. " Bold",
				InitCommand=function(subself)
					self.bottom_text = subself
					subself:zoom(0.85):y(10):diffusealpha(0):maxwidth(405)
				end,
				OnCommand=function(subself)
					subself:sleep(0.1):linear(0.15):diffusealpha(1)
				end
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()

			if has_focus then
				self.container:accelerate(0.15)
				self.container:zoom(0.6)
				self.container:diffuse( GetCurrentColor() )
				self.container:glow(color("1,1,1,0.5"))
			else
				self.container:glow(color("1,1,1,0"))
				self.container:accelerate(0.15)
				self.container:zoom(0.5)
				self.container:diffuse(color("#888888"))
				self.container:glow(color("1,1,1,0"))
			end

			self.container:y(36 * (item_index - math.ceil(num_items/2)))

			if item_index <= 1 or  item_index >= num_items then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end
		end,

		set = function(self, info)
			if not info then self.bottom_text:settext("") return end
			self.info = info
			self.kind = info[1]

			if self.kind == "SortBy" then
				self.sort_by = info[2]

			elseif self.kind == "ChangeMode" or self.kind == "ChangeStyle" then
				self.change = info[2]

			else
				self.new_overlay = info[2]
			end

			local toptext    = self.kind ~= "" and THEME:GetString("ScreenSelectMusic", self.kind) or ""
			local bottomtext = THEME:GetString(self.kind == "ChangeMode" and "ScreenSelectPlayMode" or "ScreenSelectMusic", info[2])

			self.top_text:settext(toptext)
			self.bottom_text:settext(bottomtext)
		end
	}
}
