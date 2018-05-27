local args = ...
local SongWheel = args[1]
local TransitionTime = args[2]
local row = args[3]
local col = args[4]

local max_chars = { title=28, artist=32, genre=40 }

BitmapText.Truncate = function(bmt, m)
	local text = bmt:GetText()
	if text:len() <= m then return end
	bmt:settext( text:sub(1, m) .. "…" )
end

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
				SlideToTopCommand=cmd(linear,0.1; x, WideScale(col.w*0.7, col.w); linear, 0.1; y, _screen.cy - 80 ),
				SlideBackIntoGridCommand=function(subself)
					subself:linear( 0.1 ):y( row.h * 2 )
					subself:linear( 0.1 ):x( col.w )
				end,

				-- wrap the function that plays the preview music in its own Actor so that we can
				-- call sleep() and queuecommand() and stoptweening() on it and not mess up other Actors
				Def.Actor{
					InitCommand=function(subself) self.preview_music = subself end,
					PlayMusicPreviewCommand=function(subself) play_sample_music() end,
				},

				-- AF for Banner and blinking Quad
				Def.ActorFrame{
					GainFocusCommand=function(subself) subself:y(10) end,
					LoseFocusCommand=function(subself) subself:y(0) end,
					SlideToTopCommand=function(subself) subself:y(0) end,
					SlideBackIntoGridCommand=function(subself) subself:y(10) end,

					-- blinking quad behind banner
					Def.Quad{
						InitCommand=cmd( diffuse, Color.Black; zoomto, 0,0; diffusealpha, 0),
						GainFocusCommand=function(subself)
							if self.song == "CloseThisFolder" then
								subself:visible(false)
							else
								subself:visible(true):linear(0.2):diffusealpha(1):zoomto(128, 128)
									:diffuseshift()
									:effectcolor1(0.75,0.75,0.75,1):effectcolor2(0,0,0,1)
							end
						end,
						LoseFocusCommand=cmd(visible, false; diffusealpha, 0; stopeffect; zoomto, 0,0),
						SlideToTopCommand=cmd(linear,0.12; zoomto, 112, 112),
						SlideBackIntoGridCommand=cmd(linear,0.12; zoomto, 128,128)
					},

					-- banner
					Def.Banner{
						Name="Banner",
						InitCommand=function(subself) self.banner = subself; subself:diffusealpha(0) end,
						OnCommand=cmd(queuecommand,"Refresh"),
						RefreshCommand=function(subself)
							subself:scaletoclipped(110,110)
							if self.index ~= SongWheel:get_actor_item_at_focus_pos().index then
								subself:zoom(0.5)
							else
								subself:zoom(1.15)
							end
							subself:diffusealpha(1)
						end,
						GainFocusCommand=function(subself)
							subself:linear(0.2):zoom(1.15):stopeffect()
							if self.song == "CloseThisFolder" then
								subself:diffuseshift():effectcolor1(1,0.65,0.65,1):effectcolor2(1,1,1,1)
							end
						end,
						LoseFocusCommand=cmd(linear,0.2; zoom,0.5; stopeffect),
						SlideToTopCommand=cmd(linear,0.3; zoom, 1; rotationy, 360; sleep, 0; rotationy, 0),
						SlideBackIntoGridCommand=cmd(linear,0.12; zoom, 1.15),
					},
				},

				-- title
				Def.BitmapText{
					Font="_miso",
					InitCommand=function(subself)
						self.title_bmt = subself
						subself:zoom(0.8):diffuse(Color.White):shadowlength(0.75)
					end,
					GainFocusCommand=function(subself)
						if self.song == "CloseThisFolder" then
							subself:y(10):zoom(0.9)
						else
							subself:visible(false)
						end
					end,
					LoseFocusCommand=function(subself)
						if self.song == "CloseThisFolder" then
							subself:zoom(0.8)
						else
							subself:zoom(0.725)
						end
						subself:y(40):visible(true)
					end,
				},
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)

			self.container:finishtweening()
			stop_music()

			if has_focus then
				if self.song ~= "CloseThisFolder" then
					GAMESTATE:SetCurrentSong(self.song)
					MESSAGEMAN:Broadcast("CurrentSongChanged", {song=self.song})

					-- wait for the musicgrid to settle for at least 0.2 seconds before attempting to play preview music
					self.preview_music:stoptweening():sleep(0.2):queuecommand("PlayMusicPreview")
				else
					MESSAGEMAN:Broadcast("CloseThisFolderHasFocus")
				end
				self.container:playcommand("GainFocus")
			else
				self.container:playcommand("LoseFocus")
			end

			-- self.title_bmt:settext(item_index)

			-- handle row hiding
			if item_index < num_items*0.2 or item_index > num_items*0.8 then
				self.container:visible(false)
			else
				self.container:visible(true)
			end

			-- handle row shifting
			self.container:linear(0.2)

			local middle_index = math.floor(num_items/2)

			-- top row
			if item_index < middle_index  then
				-- if we need to tween this song jacket off the top edge of the screen
				if item_index < middle_index - col.how_many then
					self.container:y( -100 ):x( col.w * col.how_many )
				-- otherwise, it is somewhere in the top row
				else
					self.container:y( row.h ):x( col.w * (middle_index-item_index) )
				end

			-- bottom row
			elseif item_index > middle_index then
				-- if we need to tween this song jacket off the bottom edge of the screen
				if item_index > middle_index + col.how_many then
					self.container:y( row.h * row.how_many ):x(col.w * col.how_many)
				-- otherwise, it is somewhere in the bottom row
				else
					self.container:y( row.h * 3 ):x( col.w * math.abs(middle_index-item_index))
				end

			-- center row
			elseif item_index == middle_index then
				self.container:y( row.h * 2 ):x( col.w )

			end
		end,

		set = function(self, song)

			if not song then return end

			local imgPath = ""

			-- this SongMT was passed the string "CloseThisFolder"
			-- so this is a special case song metatable item
			if type(song) == "string" then
				self.song = song
				self.title_bmt:settext( THEME:GetString("ScreenSelectMusicCasual", "CloseThisFolder") )
				imgPath = THEME:GetPathB("ScreenSelectMusicCasual", "overlay/img/CloseThisFolder.png")

			else

				-- we are passed in a Song object as info
				self.song = song
				self.title_bmt:settext( self.song:GetDisplayMainTitle() ):Truncate(max_chars.title)

				if song:HasJacket() then
					imgPath = song:GetJacketPath()
				elseif song:HasBackground() then
					imgPath = song:GetBackgroundPath()
				elseif song:HasBanner() then
					imgPath = song:GetBannerPath()
				end
			end

			self.banner:LoadBanner(imgPath)
		end
	}
}

return song_mt