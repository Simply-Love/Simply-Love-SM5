local optionrow_item_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			-- this is a terrible way to do this
			local item_index = name:gsub("item", "")
			self.index = item_index

			local af = Def.ActorFrame{
				Name=name,
				InitCommand=function(subself)
					subself:diffusealpha(0)
					self.container = subself
				end,
				UnhideCommand=function(subself) subself:sleep(0.3):linear(0.2):diffusealpha(1) end,
				HideCommand=function(subself) subself:linear(0.2):diffusealpha(0) end,

				Def.BitmapText{
					Font=ThemePrefs.Get("ThemeFont") .. " Normal",
					InitCommand=function(subself)
						self.bmt1 = subself
						subself:horizalign(left):diffusealpha(1):diffuse(Color.Black)
					end,
					OnCommand=function(subself) subself:sleep(0.13):linear(0.05):x(200) end,
					GainFocusCommand=function(subself) subself:diffusealpha(1) end,
					LoseFocusCommand=function(subself) subself:diffusealpha(0) end
				},
				Def.BitmapText{
					Font=ThemePrefs.Get("ThemeFont") .. " Normal",
					InitCommand=function(subself)
						self.bmt2 = subself
						subself:horizalign(right):diffusealpha(0):diffuse(Color.Black)
					end,
					OnCommand=function(subself) subself:sleep(0.13):linear(0.05):x(340) end,
					GainFocusCommand=function(subself) subself:diffusealpha(1) end,
					LoseFocusCommand=function(subself) subself:diffusealpha(0) end
				}
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)

			self.container:finishtweening()

			if has_focus then
				self.container:playcommand("GainFocus")
			else
				self.container:playcommand("LoseFocus")
			end
		end,

		set = function(self, info)

			if not info then return end

			if type(info) == "table" then
				self.bmt1:settext( info[1] )
				self.bmt2:settext( info[2] )
			else
				self.bmt1:settext( info )
				self.bmt2:settext( "" )
			end
		end
	}
}

return optionrow_item_mt