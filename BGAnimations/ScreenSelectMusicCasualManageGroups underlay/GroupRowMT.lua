local args = ...
local rows_visible = args.rows_visible
local padding = 6

local group_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
				end,
				OnCommand=function(subself) subself:finishtweening() end,

				Def.Quad{
					Name="RowBackgroundQuad",
					InitCommand=function(subself)
						subself:halign(0):x(-_screen.cx + 50):setsize(_screen.w*0.5, (_screen.h/rows_visible)-padding*2)
							:diffuse(Color.Black):diffusealpha(BrighterOptionRows() and 0.8 or 0.5)
					end,
					GainFocusCommand=function(subself) subself:zoomy(1.3) end,
					LoseFocusCommand=function(subself) subself:zoomy(1) end,
				},

				Def.Quad{
					Name="TitleBackgroundQuad",
					InitCommand=function(subself)
						subself:halign(0):x(-_screen.cx + 50):setsize(50, (_screen.h/rows_visible) - padding*2)
							:diffuse(Color.Black):diffusealpha(BrighterOptionRows() and 0.85 or 0.75)
					end,
					GainFocusCommand=function(subself) subself:zoomy(1.3) end,
					LoseFocusCommand=function(subself) subself:zoomy(1) end,
				},

				-- red x or green checkmark
				LoadFont("_wendy white")..{
					InitCommand=function(subself)
						self.active_bmt = subself
						subself:settext("&BACK;"):diffuse(1,0,0,1):zoom(0.75)
							:halign(0):xy(-_screen.cx + 50, 2 )
					end
				},

				-- group name
				LoadFont("_miso")..{
					Text=group_name,
					InitCommand=function(subself)
						self.group_bmt = subself
						subself:halign(0):x(-_screen.cx + 110)
					end,
					GainFocusCommand=function(subself) subself:diffuse( PlayerColor(PLAYER_2) ):zoom(1.3) end,
					LoseFocusCommand=function(subself) subself:diffuse(1,1,1,1):zoom(1) end,
				},
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			local offset = item_index - math.floor(num_items/2)

			self.group_bmt:settext( self.name.. "  " .. item_index )
			self.container:finishtweening():linear(0.1):y(offset * (_screen.h/(rows_visible)) - padding*2 )
			if has_focus then
				self.container:playcommand("GainFocus")
			else
				if item_index == 1 or item_index == num_items then
					self.container:visible(false)
				else
					self.container:visible(true):playcommand("LoseFocus")
				end
			end
		end,

		set = function(self, groupName)
			-- handle text
			self.name = groupName
			self.group_bmt:settext(groupName)
		end
	}
}

return group_mt