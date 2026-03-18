local sortmenu_dimensions = unpack(...)
local row_height = 36

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

			-- background
			af[#af+1] = Def.Quad{
				Name="background",
				InitCommand=function(subself)
					self.bg = subself
					subself:vertalign(top):setsize(sortmenu_dimensions.w, row_height-2)
					subself:y(-12):diffuse(0.15,0.15,0.15,1)
				end,
				ShowFolderCommand=function(subself)
					subself:diffusealpha(1)
				end,
				HideFolderCommand=function(subself)
					subself:diffusealpha(0)
				end,
				GainFocusCommand=function(subself)
					subself:finishtweening():accelerate(0.1):diffuse(0.35,0.35,0.35,1)
				end,
				LoseFocusCommand=function(subself)
					subself:finishtweening():decelerate(0.1):diffuse(0.2,0.2,0.2,1)
				end
			}

			af[#af+1] = Def.ActorFrame{
				Name="text container AF",
				InitCommand=function(subself)
					self.text_container = subself
					subself:x(-100):zoom(0.5)
				end,

				-- folder icon
				LoadActor("./folder-solid.png")..{
					Name="folder icon",
					InitCommand=function(subself)
						self.folder_icon = subself
						subself:visible(false):vertalign(top)
						subself:zoom(0.4):xy(28, -16)
					end,
					ShowFolderCommand=function(subself)
						subself:visible(true)
					end,
					HideFolderCommand=function(subself)
						subself:visible(false)
					end,
					GainFocusCommand=function(subself)
						subself:diffuse(1,1,1,1)
					end,
					LoseFocusCommand=function(subself)
						subself:diffuse(0.6,0.6,0.6,1)
					end,
				},

				-- top text
				Def.BitmapText{
					Name="top text",
					Font="Common Normal",
					InitCommand=function(subself)
						self.top_text = subself
						subself:zoom(1.15):xy(33,-8):diffusealpha(0)
						subself:horizalign(left)
					end,
					OnCommand=function(subself)
						subself:sleep(0.13):linear(0.05):diffusealpha(1)
					end,
					GainFocusCommand=function(subself)
						subself:diffuse(1,1,1,1)
					end,
					LoseFocusCommand=function(subself)
						subself:diffuse(0.6,0.6,0.6,1)
					end,
				},

				-- bottom text
				Def.BitmapText{
					Name="bottom text",
					Font="Common Bold",
					InitCommand=function(subself)
						self.bottom_text = subself
						subself:zoom(0.8):y(10):diffusealpha(0):maxwidth(405)
						subself:horizalign(left)
					end,
					OnCommand=function(subself)
						subself:sleep(0.1):linear(0.15):diffusealpha(1)
					end,
					ShowFolderCommand=function(subself)
						subself:xy(64,10)
					end,
					HideFolderCommand=function(subself)
						subself:xy(32,17)
					end,
					GainFocusCommand=function(subself)
						if subself:GetText() == "Go Back" then
							subself:diffuse(1,0.6,0.6,1)
						else
							subself:diffuse(1,1,1,1)
						end
					end,
					LoseFocusCommand=function(subself)
						if subself:GetText() == "Go Back" then
							subself:diffuse(color("#7E0E13"))
						else
							subself:diffuse(0.6,0.6,0.6,1)
						end
					end,
				}
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			local isFolder = self.kind == "" and self.new_overlay ~= "GoBack"

			self.container:finishtweening()

			if isFolder then
				self.container:queuecommand("ShowFolder")
			else
				self.container:queuecommand("HideFolder")
			end

			if has_focus then
				self.container:playcommand('GainFocus')
			else
				self.container:playcommand('LoseFocus')
			end

			self.container:smooth(0.1):y(
				row_height * (item_index - math.ceil(num_items/2)) - 4
			)

			if item_index <= 1 or item_index >= num_items then
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

			local toptext = THEME:HasString("ScreenSelectMusic", info[1]) and THEME:GetString("ScreenSelectMusic", info[1]) or tostring(info[1])
			local bottomtext

			if THEME:HasString("ScreenSelectMusic", info[2]) then
				bottomtext = THEME:GetString("ScreenSelectMusic", info[2])
			elseif THEME:HasString("ScreenSelectPlayMode", info[2]) then
				bottomtext = THEME:GetString("ScreenSelectPlayMode", info[2])
			else
				bottomtext = tostring(info[2]):gsub("^Category", "")
			end
			self.top_text:settext(toptext)
			self.bottom_text:settext(bottomtext)
		end
	}
}
