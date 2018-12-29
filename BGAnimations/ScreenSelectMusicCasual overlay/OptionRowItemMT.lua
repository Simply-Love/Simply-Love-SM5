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
				UnhideCommand=cmd( sleep, 0.3; linear, 0.2; diffusealpha, 1),
				HideCommand=cmd( linear, 0.2; diffusealpha, 0),

				Def.BitmapText{
					Font="_miso",
					InitCommand=function(subself)
						self.bmt1 = subself
						subself:horizalign(left)
						subself:diffusealpha(1)
						-- subself:zoom(0.5)
						subself:diffuse(Color.Black)
					end,
					OnCommand=cmd(sleep, 0.13; linear, 0.05; x, 200 ),
					GainFocusCommand=cmd(diffusealpha, 1 ),
					LoseFocusCommand=cmd(diffusealpha, 0 )
				},
				Def.BitmapText{
					Font="_miso",
					InitCommand=function(subself)
						self.bmt2 = subself
						subself:horizalign(right)
						subself:diffusealpha(0)
						-- subself:zoom(0.5)
						subself:diffuse(Color.Black)
					end,
					OnCommand=cmd(sleep, 0.13; linear, 0.05; x, 340 ),
					GainFocusCommand=cmd(diffusealpha, 1 ),
					LoseFocusCommand=cmd(diffusealpha, 0 )
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

			if type(info) == "userdata" then
				local difficulty = THEME:GetString( "CustomDifficulty", info:GetDifficulty():gsub("Difficulty_", "") )
				self.bmt1:settext( difficulty )
				self.bmt2:settext( info:GetMeter() )
			else
				self.bmt1:settext( info )
				self.bmt2:settext( "" )
			end
		end
	}
}

return optionrow_item_mt