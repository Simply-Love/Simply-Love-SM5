local args = ...
local SongWheel = args[1]
local TransitionTime = args[2]
local row = args[3]
local col = args[4]

local CloseFolderTexture = nil
local NoJacketTexture = nil

local Subtitle

NameOfGroup = GAMESTATE:GetCurrentSong():GetGroupName()

local song_mt = {
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
					subself:diffusealpha(0)
				end,
				OnCommand=function(subself)
					subself:finishtweening():sleep(0.25):linear(0.25):diffusealpha(1):queuecommand("PlayMusicPreview")
				end,

				StartCommand=function(subself)
					-- slide the chosen Actor into place
					if self.index == SongWheel:get_actor_item_at_focus_pos().index then
						subself:queuecommand("SlideToTop")
						MESSAGEMAN:Broadcast("SwitchFocusToSingleSong")

					-- hide everything else
					else
						subself:visible(false)
					end
				end,
				HideCommand=function(subself)
					stop_music()
					subself:visible(false):diffusealpha(0)
				end,
				UnhideCommand=function(subself)

					-- we're going back to song selection
					-- slide the chosen song ActorFrame back into grid position
					if self.index == SongWheel:get_actor_item_at_focus_pos().index then
						subself:playcommand("SlideBackIntoGrid")
						MESSAGEMAN:Broadcast("SwitchFocusToSongs")
					end

					subself:visible(true):sleep(0.3):linear(0.2):diffusealpha(1)
				end,
				SlideToTopCommand=function(subself) subself:linear(0.2)end,
				SlideBackIntoGridCommand=function(subself) subself:linear(0.2) end,

				-- wrap the function that plays the preview music in its own Actor so that we can
				-- call sleep() and queuecommand() and stoptweening() on it and not mess up other Actors
				Def.Actor{
					InitCommand=function(subself) self.preview_music = subself end,
					PlayMusicPreviewCommand=function(subself) play_sample_music() end,
				},
				-- black background quad
					Def.Quad{
						Name="SongWheelBackground",
						InitCommand=function(subself) 
						self.QuadColor = subself
						subself:zoomto(320,24):diffuse(color("#0a141b")):cropbottom(1):playcommand("Set")
						end,
						SwitchFocusToGroupsMessageCommand=function(subself) subself:smooth(0.3):cropright(1):diffuse(color("#0a141b")):playcommand("Set") end,
						SwitchFocusToSongsMessageCommand=function(subself) subself:smooth(0.3):cropright(0):playcommand("Set") end,
						SwitchFocusToSingleSongMessageCommand=function(subself) subself:smooth(0.3):cropright(1):diffuse(color("#0a141b")):playcommand("Set") end,
						
						SetCommand=function(subself)
							subself:xy(0, _screen.cy-215):finishtweening()
							:accelerate(0.2):cropbottom(0)
								
						end,
					},
				-- title
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.title_bmt = subself
						subself:zoom(0.8):diffuse(Color.White):shadowlength(0.75):y(25)
					end,
					GainFocusCommand=function(subself)
						if self.song == "CloseThisFolder" then
						else
							subself:visible(true):maxwidth(315):y(25)
						end
					end,
					LoseFocusCommand=function(subself)
						if self.song == "CloseThisFolder" then
							subself:zoom(0.8):y(25)
						else
							subself:zoom(0.8):y(25)
						end
						subself:visible(true)
					end,
				},
				-- subtitle
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.subtitle_bmt = subself
						subself:zoom(0.5):diffuse(Color.White):shadowlength(0.75)
					end,
					GainFocusCommand=function(subself)
						if self.song == "CloseThisFolder" then
							subself:zoom(0.5)
						else
							subself:visible(true)
						end
					end,
					LoseFocusCommand=function(subself)
						if self.song == "CloseThisFolder" then
							subself:zoom(0.5)
						end
						subself:y(32):visible(true)
					end,
				},

			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			local offset = item_index - math.floor(num_items/2)
			local ry = offset > 0 and 25 or (offset < 0 and -25 or 0)
			self.container:finishtweening()
			self.container:finishtweening()
			stop_music()

			if has_focus then
				if self.song ~= "CloseThisFolder" then
					GAMESTATE:SetCurrentSong(self.song)
					MESSAGEMAN:Broadcast("CurrentSongChanged", {song=self.song})

					-- wait for the musicgrid to settle for at least 0.2 seconds before attempting to play preview music
					self.preview_music:stoptweening():sleep(0.2):queuecommand("PlayMusicPreview")
					self.container:y( ((offset * col.w)/8.4 + _screen.cy ) - 33)
					self.container:x(_screen.cx)
				else
					MESSAGEMAN:Broadcast("CloseThisFolderHasFocus")
				end
				self.container:playcommand("GainFocus")
				self.container:x(_screen.cx)
				self.container:y( ((offset * col.w)/8.4 + _screen.cy ) + 33)
			else
				self.container:playcommand("LoseFocus")
				self.container:y( ((offset * col.w)/8.4 + _screen.cy ) + 33)
				self.container:x(_screen.cx)
			end
			
		end,

		set = function(self, song)

			if not song then return end

			self.img_path = ""
			self.img_type = ""

			-- this SongMT was passed the string "CloseThisFolder"
			-- so this is a special case song metatable item
			if type(song) == "string" then
				self.song = song
				self.title_bmt:settext(NameOfGroup):diffuse(color("#4ffff3")):horizalign(center):valign(0.5):x(0)
				self.img_path = THEME:GetPathB("ScreenSelectMusicCasual", "overlay/img/CloseThisFolder.png")
				self.QuadColor:diffuse(color("#4c565d"))
				self.subtitle_bmt:settext("")

			else
				-- we are passed in a Song object as info
				self.song = song
				Subtitle = self.song:GetDisplaySubTitle()
				self.title_bmt:settext( self.song:GetDisplayMainTitle() ):maxwidth(300):diffuse(Color.White):horizalign(left):x(-100)
				self.subtitle_bmt:settext( self.song:GetDisplaySubTitle() ):maxwidth(300):horizalign(left):x(-100)
				self.QuadColor:diffuse(color("#0a141b"))
				if Subtitle ~= "" then
					self.title_bmt:valign(row.h/170)
				else
					self.title_bmt:valign(0.5)
				end

			end
		end
	}
}

return song_mt