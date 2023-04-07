local paneHeight = 319
local paneWidth = 319

-- the metatable for an item in the song search results.
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

			-- Song Name
			af[#af+1] = Def.BitmapText{
				Font="Common Normal",
				Name="Song",
				InitCommand=function(subself)
					self.song_name = subself
					subself:y(0):diffusealpha(0):maxwidth(155)
				end,
				OnCommand=function(subself)
					subself:sleep(0.13):linear(0.05):diffusealpha(1)
				end
			}

			-- Song Name
			af[#af+1] = Def.BitmapText{
				Font=ThemePrefs.Get("ThemeFont") .. " Bold",
				Name="Exit",
				Text="Exit",
				InitCommand=function(subself)
					self.exit_text = subself
					subself:y(0):diffusealpha(0):maxwidth(155):zoom(0.5):diffuse(Color.Red)
				end,
				OnCommand=function(subself)
					subself:sleep(0.13):linear(0.05):diffusealpha(1)
				end
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()

			if has_focus then
				self.container:accelerate(0.1)
				self.container:diffuse( GetCurrentColor() )
				self.container:glow(color("1,1,1,0.5"))
				MESSAGEMAN:Broadcast("UpdateSearchResult", {songOrExit=self.song_name.songOrExit})
			else
				self.container:glow(color("1,1,1,0"))
				self.container:accelerate(0.1)
				self.container:diffuse(color("#888888"))
				self.container:glow(color("1,1,1,0"))
			end

			self.container:y(30 * item_index)

			if item_index <= 1 or item_index >= num_items then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end
		end,

		set = function(self, info)
			if info == nil then self.song_name:settext("") return end

			local songOrExit = info.songOrExit

			-- We use type(songOrExit) as a way to differentiate between Songs and the "Exit" text.
			-- Don't want to run into the issue of someone searching for "Exit".
			if type(songOrExit) == "string" then
				self.song_name:diffusealpha(0)
				self.exit_text:diffusealpha(1)
			else
				self.exit_text:diffusealpha(0)
				self.song_name:diffusealpha(1):settext(songOrExit:GetDisplayMainTitle()):diffuse(Color.White)
			end
			self.song_name.songOrExit = songOrExit
		end
	}
}