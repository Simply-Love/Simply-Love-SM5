local optionrow_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			-- this is a terrible way to do this
			local item_index = name:gsub("item", "")
			self.index = item_index

			local af = Def.ActorFrame{
				Name=name,
				InitCommand=function(subself)
					self.container = subself
					subself:diffusealpha(0):queuecommand("Hide2")
				end,
				OnCommand=function(subself) subself:y(item_index * 62) end,

				HideCommand=function(subself) subself:linear(0.2):diffusealpha(0):queuecommand("Hide2") end,
				Hide2Command=function(subself) subself:visible(false) end,

				UnhideCommand=function(subself) subself:visible(true):queuecommand("Unhide2") end,
				Unhide2Command=function(subself) subself:sleep(0.3):linear(0.2):diffusealpha(1) end,

				-- helptext
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.helptext = subself
						subself:horizalign(left):zoom(0.9)
							:diffuse(Color.White):diffusealpha(0.5)
					end,
					GainFocusCommand=function(subself) subself:diffusealpha(0.85) end,
					LoseFocusCommand=function(subself) subself:diffusealpha(0.5) end
				},

				-- bg quad
				Def.Quad{
					InitCommand=function(subself)
						self.bgQuad = subself
						subself:horizalign(left):zoomto(200, 28):diffuse(Color.White):diffusealpha(0.5)
					end,
					OnCommand=function(subself) subself:y(26) end,
					GainFocusCommand=function(subself) subself:diffusealpha(1) end,
					LoseFocusCommand=function(subself) subself:diffusealpha(0.5) end,
				},
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

		set = function(self, optionrow)
			if not optionrow then return end
			self.helptext:settext( optionrow.HelpText )
			if optionrow.HelpText == "" then
				self.bgQuad:visible(false)
			end
		end
	}
}

return optionrow_mt