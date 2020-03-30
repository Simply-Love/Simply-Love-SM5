local args = ...
local SongWheel = args[1]
local row = args[2]

local awards = {}
table.insert(awards,Color.White)
table.insert(awards,Color.Green)
table.insert(awards,Color.Yellow)
table.insert(awards,Color.Blue)

local songWidth = WideScale(250,250)

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
				SlideBackIntoGridCommand=function(subself) subself:linear(0.2):y( math.floor(13/2)*47 ):x( _screen.w/1.5+25 )end, --y = num_items/2 * 47

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
							subself:visible(true):linear(0.2):diffusealpha(1):zoomto(songWidth, 40)
							:diffuseshift():effectcolor1(0.75,0.75,0.75,1):effectcolor2(0,0,0,1)
						end,
						LoseFocusCommand=function(subself) subself:visible( false) end,
						SlideToTopCommand=function(subself) subself:visible( false) end,
						SlideBackIntoGridCommand=function(subself) subself:visible( true) end,
					},
					--box behind song name
					Def.ActorFrame {
						InitCommand = function(subself) self.song_box = subself end,
						SlideToTopCommand=function(subself) subself:linear(.12):diffusealpha(0):visible(false) end,
						SlideBackIntoGridCommand=function(subself) subself:linear(.12):diffusealpha(1):visible( true) end,
						Def.Quad { InitCommand=function(subself) subself:zoomto(songWidth,40):diffuse(.5,.5,.5,.5):diffusealpha(.5) end },
						Def.Quad { InitCommand=function(self) self:zoomto(songWidth-2, 40-2*2):MaskSource(true) end },
						Def.Quad { InitCommand=function(self) self:zoomto(songWidth,40):MaskDest() end },
						Def.Quad { InitCommand=function(self) self:diffusealpha(0):clearzbuffer(true) end },
					},
					-- title
					Def.BitmapText{
						Font="Common Normal",
						InitCommand=function(subself)
							self.title_bmt = subself
							subself:zoom(1):diffuse(Color.White):shadowlength(0.75):maxwidth(190)
						end,
						SlideToTopCommand=function(subself)
							if self.song ~= "CloseThisFolder" then subself:zoom(1.5):maxwidth(125):settext( self.song:GetDisplayMainTitle()) end end,
						SlideBackIntoGridCommand=function(subself) 
							if self.song  ~= "CloseThisFolder" then 
								if SL.Global.Order == "Difficulty/BPM" then
									local block = GetDifficultyBPM(self.index)
									subself:settext( "["..block.difficulty.."]["..math.floor(block.bpm).."] "..self.song:GetDisplayMainTitle() ):maxwidth(200):zoom(1.2)
								else
									subself:settext( self.song:GetDisplayMainTitle() ):maxwidth(190):zoom(1.2)
								end
							end
						end,
						GainFocusCommand=function(subself) --make the words a little bigger to make it seem like they're popping out
							subself:visible(true):zoom(1.2)
						end,
						LoseFocusCommand=function(subself)
							subself:zoom(1)
							subself:y(0):visible(true)
						end,
					},
				},
			}
			--Things we need two of
			for pn in ivalues({'P1','P2'}) do
				local side
				if pn == 'P1' then side = -1
				else side = 1 end
				local grade_position = WideScale(140,150)
				local pass_position = 120
				--A box for the pass type
				--TODO this might be better as an AMV
				af[#af+1] = Def.ActorFrame {
					InitCommand=function(subself) subself:visible(true) self.pass_box_outline = subself  end,
					--Box on the side of the musicwheel item
					Def.ActorFrame{
						SlideToTopCommand=function(subself) subself:linear(.12):diffusealpha(0) end,
						SlideBackIntoGridCommand=function(subself) subself:linear(.12):diffusealpha(1) end,
						Def.Quad { InitCommand=function(self) self:zoomto(10,40):x(side*pass_position):diffuse(.25,.25,.25,.25):diffusealpha(.5) end, },
						Def.Quad { InitCommand=function(self) self:zoomto(10-2, 40-2*2):x(side*pass_position):MaskSource(true) end },
						Def.Quad { InitCommand=function(self) self:zoomto(10,40):x(side*pass_position):MaskDest() end },
						Def.Quad { InitCommand=function(self) self:diffusealpha(0):clearzbuffer(true) end },
					},
					--Colors to fill in the box
					Def.ActorFrame{
						InitCommand=function(subself) subself:visible(false) self[pn..'pass_box'] = subself end,
						SlideToTopCommand=function(subself) subself:linear(.12):diffusealpha(0) end,
						SlideBackIntoGridCommand=function(subself) subself:linear(.12):diffusealpha(1) end,
						Def.Quad {InitCommand=function(self) self:zoomto(10-2, 40-2*2):x(side*pass_position) end},
					},
					-- The grade shown to the right of the song box
					Def.Sprite{
						Texture=THEME:GetPathG("MusicWheelItem","Grades/grades 1x18.png"),
						InitCommand=function(subself) subself:visible(false):zoom(WideScale(.25,.3)):x(side*grade_position):animate(0) self[pn..'grade_sprite'] = subself end,
						SlideToTopCommand=function(subself)
							subself:linear(.12):diffusealpha(0):xy(side*-1*-55,50):zoom(1):linear(.12):diffusealpha(1)
						end,
						SlideBackIntoGridCommand=function(subself)
							subself:linear(.12):diffusealpha(0):zoom( WideScale(.25, 0.3)):xy(side*grade_position,0):linear(.12):diffusealpha(1)
						end,
					}
				}
			end

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			if has_focus then
				--TODO find out why this is called twice every time we go to ScreenSelectMusicExperiment
				if self.song ~= "CloseThisFolder" then
					SL.Global.LastSeenSong = self.song
					--Input.lua will transform the wheel when changing difficulty (to change the grade sprite) but we
					--don't need to restart the preview music because only difficulty changed
					--so check here that transform was called because we're moving to a new song
					--or because we're initializing ScreenSelectMusicExperiment
					if self.song ~= GAMESTATE:GetCurrentSong() or SL.Global.GroupToSong or SL.Global.LastSeenIndex ~= self.index then
						GAMESTATE:SetCurrentSong(self.song)
						SL.Global.GroupToSong = false
						SL.Global.LastSeenIndex = self.index
						SL.Global.SongTransition = true
						MESSAGEMAN:Broadcast("CurrentSongChanged", {song=self.song, index=self.index})
						MESSAGEMAN:Broadcast("BeginSongTransition") --See the MessageCommand in ScreenSelectMusicExperiment/default.lua for details
						stop_music()
						-- wait for the musicgrid to settle for at least 0.2 seconds before attempting to play preview music
						self.preview_music:stoptweening():sleep(0.2):queuecommand("PlayMusicPreview")

					else
						MESSAGEMAN:Broadcast("StepsHaveChanged")
					end
				else
					stop_music()
					MESSAGEMAN:Broadcast("CloseThisFolderHasFocus")
				end
				self.container:playcommand("GainFocus")
			else
				self.container:playcommand("LoseFocus")
			end
			--change the Grade sprite and pass box
			--TODO this only shows grades for the master player. Maybe it should show for both players?
			for player in ivalues(GAMESTATE:GetHumanPlayers()) do
				local multiplayer = #GAMESTATE:GetHumanPlayers() == 2 and true or false
				local pn = ToEnumShortString(player)
				if self.song ~= "CloseThisFolder" then
					local current_difficulty
					local grade
					local steps
					if GAMESTATE:GetCurrentSteps(pn) then
						current_difficulty = GAMESTATE:GetCurrentSteps(pn):GetDifficulty() --are we looking at steps?
					end
					if current_difficulty and self.song:GetOneSteps(GetStepsType(),current_difficulty) then
						steps = self.song:GetOneSteps(GetStepsType(),current_difficulty)
					end
					if steps then
						--color the pass_box
						local award = GetBestPass(player,self.song,steps)
						if award > 0 then
							self[pn..'pass_box']:visible(true):diffuse(awards[award])
							if not multiplayer then
								if pn == 'P1' then self['P2pass_box']:visible(true):diffuse(awards[award])
								else self['P1pass_box']:visible(true):diffuse(awards[award]) end
							end
						else
							self[pn..'pass_box']:visible(false)
							if not multiplayer then
								if pn == 'P1' then self['P2pass_box']:visible(false)
								else self['P1pass_box']:visible(false) end
							end
						end
						grade = GetTopGrade(player, self.song, steps)
					end
					--if we have a grade then set the grade sprite
					if grade then
						self[pn..'grade_sprite']:visible(true):setstate(grade)
					else
						self[pn..'grade_sprite']:visible(false)
						self[pn..'pass_box']:visible(false)
						if not multiplayer then
							if pn == 'P1' then self['P2pass_box']:visible(false)
							else self['P1pass_box']:visible(false) end
						end
					end
					--set the song title color to white (Close This Folder is red)
					self.title_bmt:diffuse(Color.White)
				else
					self[pn..'grade_sprite']:visible(false)
					self[pn..'pass_box']:visible(false)
					self.title_bmt:diffuse(Color.Red)
				end
				--handle row hiding
				if item_index == 1 or item_index > 11 then
					self.container:visible(false)
				else
					self.container:visible(true)
				end

				-- handle row shifting speed
				self.container:linear(0.2)

				local middle_index = math.floor(num_items/2)

				-- top row
				if item_index < middle_index  then
						self.container:y( 47*item_index ):x(_screen.w/1.5+25*WideScale(1,(middle_index-item_index)) )
				-- bottom row
				elseif item_index > middle_index then
						self.container:y( 47*item_index ):x(_screen.w/1.5+25*WideScale(1,(item_index-middle_index)) )
				-- center row
				elseif item_index == middle_index then
					self.container:y( 47*item_index ):x( _screen.w/1.5+25 )
				end
			end
		end,

		set = function(self, item)
			-- we are passed in a Song object as info
			-- Set in "switch_to_songs" function in GroupMT.Lua
			if not item.song then return end
			if type(item.song) == "string" then
				self.song = item.song
				self.title_bmt:settext( THEME:GetString("ScreenSelectMusicExperiment", "CloseThisFolder") )
				self.index = 0
			else
				self.song = item.song
				self.index = item.index
				if SL.Global.Order == "Difficulty/BPM" then
					local block = GetDifficultyBPM(item.index)
					self.title_bmt:settext( "["..block.difficulty.."]["..math.floor(block.bpm).."] "..self.song:GetDisplayMainTitle() )
				else
					self.title_bmt:settext( self.song:GetDisplayMainTitle() )
				end

			end
		end
	}
}

return song_mt