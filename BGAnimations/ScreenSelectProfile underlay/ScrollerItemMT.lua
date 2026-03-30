-- the metatable for an item in ScreenSelectProfile's sick_wheel scroller
-- for the scrollers in ScreenSelectProfile, this is just each profile's DisplayName
return {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=name,
				InitCommand=function(subself)
					self.container = subself
					subself:diffusealpha(0):visible(false)
				end,
				OnCommand=function(subself) subself:sleep(0.2):queuecommand("Appear") end,
				AppearCommand=function(subself) subself:visible(true):linear(0.15):diffusealpha(1) end,
			}

			local txt = LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
				InitCommand=function(subself)
					self.bmt = subself
					subself:maxwidth(115):MaskDest():shadowlength(0.5)
				end,
			}

			if ThemePrefs.Get("RainbowMode") then
				txt.GainFocusCommand=function(subself) subself:diffusealpha(1) end
				txt.LoseFocusCommand=function(subself) subself:diffusealpha(0.8) end
			end

			af[#af+1] = txt

			return af
		end,
		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()

			if item_index <= 1 or item_index >= num_items then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end

			if has_focus then
				self.bmt:playcommand("GainFocus")
			else
				self.bmt:playcommand("LoseFocus")
			end

			self.container:linear(0.15):y(35 * item_index)
		end,
		set = function(self, info)
			if not info then self.bmt:settext(""); return end
			self.info = info
			self.bmt:settext(info.displayname or "")
		end
	}
}