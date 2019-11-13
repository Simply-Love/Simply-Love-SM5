local args = ...
local SongWheel = args[1]
local TransitionTime = args[2]
local row = args[3]
local col = args[4]

local CloseFolderTexture = nil
local NoJacketTexture = nil

-- max number of characters allowed in a song title before truncating to ellipsis
local max_chars = 28

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
				SlideToTopCommand=function(subself) subself:linear(0.2):xy(_screen.cx + 150, row.h+43) end,
				SlideBackIntoGridCommand=function(subself) subself:linear(0.2):y( 300 ):x( _screen.w/1.5+25 )end,

				-- wrap the function that plays the preview music in its own Actor so that we can
				-- call sleep() and queuecommand() and stoptweening() on it and not mess up other Actors
				Def.Actor{
					InitCommand=function(subself) self.preview_music = subself end,
					PlayMusicPreviewCommand=function(subself) play_sample_music() end,
				},

				-- AF for MusicWheel item
				Def.ActorFrame{
					GainFocusCommand=function(subself) subself:y(0) end,
					LoseFocusCommand=function(subself) subself:y(0) end,
					SlideBackIntoGridCommand=function(subself) subself:linear(0.12):diffusealpha(1) end,

					-- blinking quad behind focus box
					Def.Quad{
						InitCommand=function(subself) subself:diffuse(0,0,0,0):zoomto(0,0) end,
						GainFocusCommand=function(subself)
							subself:visible(true):linear(0.2):diffusealpha(1):zoomto(250, 40)
							:diffuseshift():effectcolor1(0.75,0.75,0.75,1):effectcolor2(0,0,0,1)
						end,
						LoseFocusCommand=function(subself) subself:visible( false) end,
						SlideToTopCommand=function(subself) subself:visible( false) end,
						SlideBackIntoGridCommand=function(subself) subself:visible( true) end,
					},
					--box behind song name
					Def.ActorFrame {
						SlideToTopCommand=function(subself) subself:linear(.12):diffusealpha(0):visible(false)  end,
						SlideBackIntoGridCommand=function(subself) subself:linear(.12):diffusealpha(1):visible( true) end,
						Def.Quad { InitCommand=function(subself) subself:zoomto(250,40):diffuse(.25,.25,.25,.25):diffusealpha(.5) end },
						Def.Quad { InitCommand=function(self) self:zoomto(250-2, 40-2*2):MaskSource(true) end },
						Def.Quad { InitCommand=function(self) self:zoomto(250,40):MaskDest() end },
						Def.Quad { InitCommand=function(self) self:diffusealpha(0):clearzbuffer(true) end },
					},
					-- title
					Def.BitmapText{
						Font="Common Normal",
						InitCommand=function(subself)
							self.title_bmt = subself
							subself:zoom(1):diffuse(Color.White):shadowlength(0.75)
						end,
						SlideToTopCommand=function(subself)
							if self.song ~= "CloseThisFolder" then subself:zoom(1.5):maxwidth(125):settext( self.song:GetDisplayMainTitle()) end end,
						SlideBackIntoGridCommand=function(subself) 
							if self.song  ~= "CloseThisFolder" then subself:zoom(1):settext( self.song:GetDisplayMainTitle() ):Truncate(max_chars) end end,
						GainFocusCommand=function(subself) --make the words a little bigger to make it seem like they're popping out
							if self.song == "CloseThisFolder" then
								subself:zoom(1)
							else
								subself:visible(true):zoom(1.2)
							end
						end,
						LoseFocusCommand=function(subself)
							if self.song == "CloseThisFolder" then
								subself:zoom(0.9)
							else
								subself:zoom(1)
							end
							subself:y(0):visible(true)
						end,
					},
					--A box for the grade
					Def.ActorFrame {
						InitCommand=function(subself) subself:visible(false) self.grade_box = subself  end,
						SlideToTopCommand=function(subself) subself:linear(.12):diffusealpha(0) end,
						SlideBackIntoGridCommand=function(subself) subself:linear(.12):diffusealpha(1) end,
						Def.Quad { InitCommand=function(self) self:zoomto(40,40):x(150):diffuse(.25,.25,.25,.25):diffusealpha(.5) end, },
						Def.Quad { InitCommand=function(self) self:zoomto(40-2, 40-2*2):x(150):MaskSource(true) end },
						Def.Quad { InitCommand=function(self) self:zoomto(40,40):x(150):MaskDest() end },
						Def.Quad { InitCommand=function(self) self:diffusealpha(0):clearzbuffer(true) end },
					},
					-- The grade shown to the right of the song box
					Def.Sprite{
						Texture=THEME:GetPathG("MusicWheelItem","Grades/grades 1x18.png"),
						InitCommand=function(subself) subself:zoom( WideScale(0.18, 0.3) ):x(150):animate(0) self.grade_sprite = subself end,
					},
				},
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
		--TODO maybe make music not play in the sort menu?
			self.container:finishtweening()
			if has_focus then
				if self.song ~= "CloseThisFolder" then
					SL.Global.LastSeenSong = self.song
					--Input.lua will transform the wheel when changing difficulty (to change the grade sprite) but we
					--don't need to restart the preview music because only difficulty changed
					--so check here that transform was called because we're moving to a new song
					--or because we're initializing ScreenSelectMusicExperiment
					if self.song ~= GAMESTATE:GetCurrentSong() or SL.Global.GroupToSong then
						GAMESTATE:SetCurrentSong(self.song)
						MESSAGEMAN:Broadcast("CurrentSongChanged", {song=self.song})
						stop_music()
						-- wait for the musicgrid to settle for at least 0.2 seconds before attempting to play preview music
						self.preview_music:stoptweening():sleep(0.2):queuecommand("PlayMusicPreview")
						SL.Global.GroupToSong = false
					else MESSAGEMAN:Broadcast("StepsHaveChanged") end
				else
					MESSAGEMAN:Broadcast("CloseThisFolderHasFocus")
				end
				self.container:playcommand("GainFocus")
			else
				self.container:playcommand("LoseFocus")
			end
			--change the Grade sprite 
			if self.song ~= "CloseThisFolder" then
				local current_difficulty
				local grade
				if GAMESTATE:GetCurrentSteps(0) then
					current_difficulty = GAMESTATE:GetCurrentSteps(0):GetDifficulty() --are we looking at steps?
				end
				if current_difficulty and self.song:GetOneSteps(GetStepsType(),current_difficulty) then --does this song have steps in the correct difficulty?
					grade = PROFILEMAN:GetProfile(0):GetHighScoreList(self.song,self.song:GetOneSteps(GetStepsType(),current_difficulty)):GetHighScores()[1] --TODO this only grabs scores for player one
				end
				if grade then
					local converted_grade = Grade:Reverse()[grade:GetGrade()]
					if converted_grade > 17 then converted_grade = 17 end
					self.grade_sprite:visible(true):setstate(converted_grade)
					--self.grade_box:visible(true):diffuseshift():effectcolor1(color("#33aa33")):effectcolor2(color("#55cc55"))
				else
					self.grade_sprite:visible(false)
					self.grade_box:visible(false)
				end
			else
				self.grade_sprite:visible(false)
				self.grade_box:visible(false)
			end
			
			--handle row hiding
			if item_index == 1 or item_index > num_items-1 then
				self.container:visible(false)
			else
				self.container:visible(true)
			end
			

			-- handle row shifting speed
			self.container:linear(0.2)

			local middle_index = math.floor(num_items/2)

			-- top row
			if item_index < middle_index  then
					self.container:y( 50*item_index ):x(_screen.w/1.5+25*(middle_index-item_index) )
			-- bottom row
			elseif item_index > middle_index then
					self.container:y( 50*item_index ):x(_screen.w/1.5+25*(item_index-middle_index))
			-- center row
			elseif item_index == middle_index then
				self.container:y( 50*item_index ):x( _screen.w/1.5+25 )

			end
		end,

		set = function(self, song)
			-- we are passed in a Song object as info
			if not song then return end
			if type(song) == "string" then
				self.song = song
				self.title_bmt:settext( THEME:GetString("ScreenSelectMusicCasual", "CloseThisFolder") )
			else
				self.song = song
				self.title_bmt:settext( self.song:GetDisplayMainTitle() ):Truncate(max_chars)
			end
		end
	}
}

return song_mt