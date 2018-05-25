local args = ...
local SongWheel = args[1]
local TransitionTime = args[2]
local row = args[3]
local col = args[4]

local max_chars = { title=32, artist=32, genre=40 }

BitmapText.Truncate = function(bmt, kind)
	local text = bmt:GetText()
	if text:len() <= max_chars[kind] then return end
	bmt:settext( text:sub(1, max_chars[kind]) .. "…" )
end

local song_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			-- this is a terrible way to do this
			local item_index = name:gsub("item", "")
			self.index = item_index
			self.column = ((item_index-1) % col.how_many) + 1

			self.static_row = math.ceil((item_index/col.how_many)-1) % row.how_many + 1
			self.changing_row = self.static_row

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
					-- subself:diffusealpha(0)
					-- subself:x(col.w * self.column)
				end,
				OnCommand=function(subself)
					subself:finishtweening()

					-- if self.changing_row <= 0 and self.changing_row ~= math.ceil(SongWheel.num_items/col.how_many) - 1 then
					-- 	subself:sleep(0.3)
					-- 	subself:linear(0.2)
					-- 	subself:diffusealpha(1)
					-- end
				end,
				StartCommand=function(subself)
					-- slide the chosen Actor into place
					if self.index == SongWheel:get_actor_item_at_focus_pos().index then
						subself:queuecommand("SlideToTop")
						MESSAGEMAN:Broadcast("SwitchFocusToSingleSong")

					-- hide everything else
					else
						subself:linear(0.2)
						subself:diffusealpha(0)
					end
				end,
				HideCommand=function(subself)
					stop_music()
					subself:linear(0.2)
					subself:diffusealpha(0)
				end,
				UnhideCommand=function(subself)

					-- we're going back to song selection
					-- slide the chosen song ActorFrame back into grid position
					if self.index == SongWheel:get_actor_item_at_focus_pos().index then
						subself:playcommand("SlideBackIntoGrid")
						MESSAGEMAN:Broadcast("SwitchFocusToSongs")
					end

					-- only unhide the middle rows, of course
					if self.changing_row > 0 and self.changing_row ~= math.ceil(SongWheel.num_items/col.how_many) - 1 then
						subself:sleep(0.3)
						subself:linear(0.2)
						subself:diffusealpha(1)
					end
				end,
				SlideToTopCommand=cmd(linear,0.1; x, WideScale(col.w*0.7, col.w); linear, 0.1; y, _screen.cy - 80 ),
				SlideBackIntoGridCommand=function(subself)
					subself:linear( 0.1 )
					subself:y( row.h * 2 )
					subself:linear( 0.1 )
					subself:x( col.w )
				end,

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

				-- text
				Def.ActorFrame{
					GainFocusCommand=function(subself) subself:y(8) end,
					LoseFocusCommand=function(subself) subself:y(0) end,
					SlideToTopCommand=function(subself) subself:linear(0.12):zoom(1.1):y(0) end,
					SlideBackIntoGridCommand=function(subself) subself:linear(0.12):zoom(1):y(8) end,

					-- title
					Def.BitmapText{
						Font="_miso",
						InitCommand=function(subself)
							self.title_bmt = subself
							subself:zoom(0.8):diffuse(Color.White):horizalign(left)
						end,
						GainFocusCommand=function(subself)
							subself:zoom(1.2):xy(80,-40):horizalign(left)
							if self.song == "CloseThisFolder" then subself:xy(0,6):zoom(0.85):horizalign(center) end
						end,
						LoseFocusCommand=function(subself)
							subself:x(0):horizalign(center)

							if self.song == "CloseThisFolder"
							then subself:linear(0.2):y(0):zoom(0.45)
							else subself:linear(0.2):y(40):zoom(0.8)
							end
						end,
						SlideToTopCommand=cmd(horizalign, left; diffuse, Color.Black),
						SlideBackIntoGridCommand=cmd(horizalign, left; diffuse, Color.White)
					},

					-- artist
					Def.BitmapText{
						Font="_miso",
						InitCommand=function(subself)
							self.artist_bmt = subself
							subself:zoom(0.8):diffuse(Color.White)
								:y(-20):horizalign(left)
						end,
						GainFocusCommand=function(subself)
							subself:diffusealpha(1):diffuse(Color.White):visible(true)
								:x(80):zoom(0.8)
						end,
						LoseFocusCommand=function(subself)
							subself:diffusealpha(0):visible(false):x(0)
						end,
						SlideToTopCommand=cmd(diffuse, Color.Black),
						SlideBackIntoGridCommand=cmd(queuecommand, "GainFocus")
					},

					-- BPM
					Def.BitmapText{
						Font="_miso",
						InitCommand=function(subself)
							self.bpm_bmt = subself
							subself:zoom(0.65):diffuse(Color.White)
								:xy(80, 18):horizalign(left)
						end,
						GainFocusCommand=function(subself) subself:visible(true):diffuse(Color.White) end,
						LoseFocusCommand=function(subself) subself:visible(false) end,
						SlideToTopCommand=cmd(diffuse,Color.Black),
						SlideBackIntoGridCommand=cmd(diffuse,Color.White)
					},
					-- length
					Def.BitmapText{
						Font="_miso",
						InitCommand=function(subself)
							self.length_bmt = subself
							subself:zoom(0.65):diffuse(Color.White)
								:xy(80, 32):horizalign(left)
						end,
						GainFocusCommand=function(subself) subself:visible(true):diffuse(Color.White) end,
						LoseFocusCommand=function(subself) subself:visible(false) end,
						SlideToTopCommand=cmd(diffuse, Color.Black),
						SlideBackIntoGridCommand=cmd(diffuse,Color.White)
					},
					-- genre
					Def.BitmapText{
						Font="_miso",
						InitCommand=function(subself)
							self.genre_bmt = subself
							subself:zoom(0.65):diffuse(Color.White)
								:xy(80, 46):horizalign(left)
						end,
						GainFocusCommand=function(subself) subself:visible(true):diffuse(Color.White) end,
						LoseFocusCommand=function(subself) subself:visible(false) end,
						SlideToTopCommand=cmd(diffuse, Color.Black),
						SlideBackIntoGridCommand=cmd(diffuse,Color.White)
					},
				}
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)

			self.container:finishtweening()

			if has_focus then
				if self.song == "CloseThisFolder" then
					stop_music()
				else
					GAMESTATE:SetCurrentSong(self.song)
					-- GetDisplayBPMs() relies on GAMESTATE:GetCurrentSong() which we just set
					self.bpm_bmt:settext( THEME:GetString("ScreenSelectMusic", "BPM") .. ": " .. GetDisplayBPMs())
					play_sample_music()

					-- undo Truncate()
					self.title_bmt:settext( self.song:GetDisplayFullTitle() )
					self.artist_bmt:settext( THEME:GetString("ScreenSelectMusic", "Artist") .. ": " .. self.song:GetDisplayArtist() )
					self.genre_bmt:settext( THEME:GetString("ScreenSelectMusic", "Genre") .. ": " .. self.song:GetGenre() )
				end
				self.container:playcommand("GainFocus")
			else
				self.container:playcommand("LoseFocus")
				self.title_bmt:Truncate("title")
				self.artist_bmt:Truncate("artist")
				self.genre_bmt:Truncate("genre")
			end

			-- handle row hiding
			if self.changing_row <= 0 or self.changing_row == math.ceil(num_items/col.how_many) - 1 then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end

			-- handle row shifting
			self.container:linear(0.2)

			local focal_point_index = math.floor(num_items/2)

			-- top row
			if item_index < focal_point_index  then
				if item_index < focal_point_index - col.how_many then
					self.container:y( 0 )
				else
					self.container:y( row.h * 1 ):x( col.w * (focal_point_index-item_index) )
				end

			-- bottom row
			elseif item_index > focal_point_index then
				if item_index > focal_point_index + col.how_many then
					self.container:y( row.h * row.how_many )
				else
					self.container:y( row.h * 3 ):x( col.w * math.abs(focal_point_index-item_index))
				end

			-- center row
			elseif item_index == focal_point_index then
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
				self.artist_bmt:settext( "" )
				self.genre_bmt:settext( "" )
				self.length_bmt:settext( "")
				self.bpm_bmt:settext( "" )
				imgPath = THEME:GetPathB("ScreenSelectMusicCasual", "overlay/img/CloseThisFolder.png")

			else

				-- we are passed in a Song object as info
				self.song = song
				self.title_bmt:settext( self.song:GetDisplayFullTitle() ):Truncate("title")
				self.artist_bmt:settext( THEME:GetString("ScreenSelectMusic", "Artist") .. ": " .. self.song:GetDisplayArtist() ):Truncate("artist")
				self.genre_bmt:settext( THEME:GetString("ScreenSelectMusic", "Genre") .. ": " .. self.song:GetGenre() ):Truncate("genre")
				self.length_bmt:settext( THEME:GetString("ScreenSelectMusic", "Length") .. ": " .. SecondsToMMSS(self.song:MusicLengthSeconds()):gsub("^0*","") )

				if song:HasJacket() then
					imgPath = song:GetJacketPath()
				elseif song:HasBackground() then
					imgPath = song:GetBackgroundPath()
				elseif song:HasBanner() then
					imgPath = song:GetBannerPath()
				end
			end

			self.banner:LoadBanner(imgPath)

			-- determine if we have row shifting to do
			local ActiveActor = SongWheel:get_actor_item_at_focus_pos()

			-- we'll only get into this if statement once...
			if SongWheel.ActiveRow ~= ActiveActor.static_row then
				local change = SongWheel.ActiveRow - ActiveActor.static_row
				SongWheel.ActiveRow = ActiveActor.static_row

				-- ... so update every item's changing_row attribute now for the transform that comes next
				for i=1,SongWheel.num_items do
					SongWheel.items[i].changing_row = (SongWheel.items[i].changing_row + change) % row.how_many
				end
			end
		end
	}
}

return song_mt