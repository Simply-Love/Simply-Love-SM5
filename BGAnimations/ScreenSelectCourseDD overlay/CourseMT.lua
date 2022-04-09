local args = ...
local CourseWheel = args[1]
local TransitionTime = args[2]
local row = args[3]
local col = args[4]

local Subtitle
local CurrentStyle = GAMESTATE:GetCurrentStyle():GetStepsType()

local function update_grade(self)
	--change the Grade sprite
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local pn = ToEnumShortString(player)
		if self.course ~= "CloseThisFolder" then
			local current_difficulty
			local grade
			local steps
			if GAMESTATE:GetCurrentTrail(pn) then
				current_difficulty = GAMESTATE:GetCurrentTrail(pn):GetDifficulty() --are we looking at steps?
			end
			if current_difficulty then
				steps = GAMESTATE:GetCurrentTrail(pn)
			end
			if steps then
				grade = GetTopGrade(player, self.course, steps)
			end
			--if we have a grade then set the grade sprite
			if grade then
				self[pn..'grade_sprite']:visible(true):setstate(grade)
			else
				self[pn..'grade_sprite']:visible(false)
			end
		else
			self[pn..'grade_sprite']:visible(false)
		end
	end
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
					if self.index == CourseWheel:get_actor_item_at_focus_pos().index then
						subself:queuecommand("SlideToTop")
						MESSAGEMAN:Broadcast("SwitchFocusToSingleCourse")

					-- hide everything else
					else
						subself:visible(false)
					end
				end,
				HideCommand=function(subself)
					subself:visible(false):diffusealpha(0)
				end,
				UnhideCommand=function(subself)

					-- we're going back to course selection
					-- slide the chosen course ActorFrame back into grid position
					if self.index == CourseWheel:get_actor_item_at_focus_pos().index then
						subself:playcommand("SlideBackIntoGrid")
						MESSAGEMAN:Broadcast("SwitchFocusToCourses")
					end

					subself:visible(true):sleep(0.3):linear(0.2):diffusealpha(1)
				end,
				SlideToTopCommand=function(subself) subself:linear(0.2)end,
				SlideBackIntoGridCommand=function(subself) subself:linear(0.2) end,

				CurrentStepsChangedMessageCommand=function(subself, params)
					update_grade(self)
				end,

				-- wrap the function that plays the preview music in its own Actor so that we can
				-- call sleep() and queuecommand() and stoptweening() on it and not mess up other Actors
				Def.Actor{
					InitCommand=function(subself) self.preview_music = subself end,
					PlayMusicPreviewCommand=function(subself) play_sample_music() end,
				},
				-- black background quad
					Def.Quad{
						Name="CourseWheelBackground",
						InitCommand=function(subself) 
						self.QuadColor = subself
						subself:zoomto(320,24):diffuse(color("#0a141b")):cropbottom(1):playcommand("Set")
						end,
						SwitchFocusToGroupsMessageCommand=function(subself) subself:smooth(0.3):cropright(1):diffuse(color("#0a141b")):playcommand("Set") end,
						SwitchFocusToCoursesMessageCommand=function(subself) subself:smooth(0.3):cropright(0):playcommand("Set") end,
						SwitchFocusToSingleCourseMessageCommand=function(subself) subself:smooth(0.3):cropright(1):playcommand("Set") end,
						SetCommand=function(subself)
							subself:x(0)
							subself:y(_screen.cy-215)
							subself:finishtweening()
							subself:accelerate(0.2):cropbottom(0)
								
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
						if not self.course == "CloseThisFolder" then
							subself:visible(true):maxwidth(315):y(25)
						end
					end,
					LoseFocusCommand=function(subself)
						if self.course == "CloseThisFolder" then
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
						subself:y(32)
					end,
					GainFocusCommand=function(subself)
						if self.course == "CloseThisFolder" then
							subself:zoom(0.5)
						else
							subself:visible(true)
						end
					end,
					LoseFocusCommand=function(subself)
						if self.course == "CloseThisFolder" then
							subself:zoom(0.5)
						else
						end
						subself:y(32):visible(true)
					end,
				},

			}
			
			--Things we need two of
			for pn in ivalues({'P1','P2'}) do
				local side
				if pn == 'PLAYER_1' then side = -1
				else side = 1 end
				local grade_position
				if pn == 'P1' then
					grade_position = -145
				else
					grade_position = -120
				end
				af[#af+1] = Def.ActorFrame {
					InitCommand=function(subself) 
						subself:visible(true) 
					end,
					-- The grade shown to the left of the course name
					Def.Sprite{
						Texture=THEME:GetPathG("","_grades/assets/grades 1x18.png"),
						InitCommand=function(subself) subself:visible(false):zoom(WideScale(.25,.22)):xy(side*grade_position, 25):animate(0) self[pn..'grade_sprite'] = subself end,
						SlideBackIntoGridCommand=function(subself)
							subself:linear(.12):diffusealpha(0):zoom( WideScale(.25, 0.22)):xy(side*grade_position,25):linear(.12):diffusealpha(1)
						end,
					}
				}
			end

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			local offset = IsUsingWideScreen() and WideScale( (item_index - math.floor(num_items/10)) - 3.4 , item_index - math.floor(num_items/3) - 0.4 ) or item_index - math.floor(num_items/2) + 3
			local ry = offset > 0 and 25 or (offset < 0 and -25 or 0)
			self.container:finishtweening()
			self.container:finishtweening()

			if item_index ~= 1 and item_index ~= num_items then
				self.container:decelerate(0.1)
			end

			if has_focus then
				if self.course ~= "CloseThisFolder" then
					GAMESTATE:SetCurrentCourse(self.course)
					MESSAGEMAN:Broadcast("CurrentCourseChanged", {course=self.course})
					if GAMESTATE:GetCurrentCourse() ~= nil then
						LastSeenCourse = GAMESTATE:GetCurrentCourse():GetCourseDir()
					end
					self.container:y(IsUsingWideScreen() and WideScale(((offset * col.w)/6.8 + _screen.cy ) - 33 , ((offset * col.w)/8.4 + _screen.cy ) - 33) or ((offset * col.w)/6.4 + _screen.cy ) - 190)
					self.container:x(_screen.cx)
				elseif self.course == "CloseThisFolder" then
					GAMESTATE:SetCurrentCourse(nil)
					MESSAGEMAN:Broadcast("CloseThisFolderHasFocus")
				end
				self.container:playcommand("GainFocus")
				self.container:x(_screen.cx)
				self.container:y(IsUsingWideScreen() and WideScale(((offset * col.w)/6.8 + _screen.cy ) - 33 , ((offset * col.w)/8.4 + _screen.cy ) - 33) or ((offset * col.w)/6.4 + _screen.cy ) - 190)
			else
				self.container:playcommand("LoseFocus")
				self.container:y(IsUsingWideScreen() and WideScale(((offset * col.w)/6.8 + _screen.cy ) - 33 , ((offset * col.w)/8.4 + _screen.cy ) - 33) or ((offset * col.w)/6.4 + _screen.cy ) - 190)
				self.container:x(_screen.cx)
			end
		end,
		
		set = function(self, course)

			if not course then return end

			self.img_path = ""
			self.img_type = ""

			-- this SongMT was passed the string "CloseThisFolder"
			-- so this is a special case for song metatable items
			if type(course) == "string" then
				if course == "CloseThisFolder" then
					self.course = course
					self.title_bmt:settext(NameOfGroup):diffuse(color("#4ffff3")):shadowlength(1.1):horizalign(center):valign(0.5):x(0)
					self.QuadColor:diffuse(color("#363d42"))
					self.subtitle_bmt:settext("")
				end
			else
				-- we are passed in a Course object as info
				self.course = course
				if GAMESTATE:GetCurrentCourse() ~= nil then
					LastSeenCourse = GAMESTATE:GetCurrentCourse():GetCourseDir()
				end
				self.title_bmt:settext( self.course:GetDisplayFullTitle() ):maxwidth(300):diffuse(Color.White):horizalign(left):x(-100)
				self.QuadColor:diffuse(color("#0a141b"))
				self.title_bmt:valign(0.5)
			end

			update_grade(self)
			
		end
	}
}

return song_mt