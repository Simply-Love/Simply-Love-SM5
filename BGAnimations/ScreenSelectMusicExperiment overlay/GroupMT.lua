local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local TransitionTime = args[3]
local steps_type = args[4]
local row = args[5]
local col = args[6]
local Input = args[7]

local max_chars = 64

local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualTheme")
local banner_directory = FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")

local switch_to_songs = function(group_name)
	local songs = PruneSongList(GetSongList(group_name))
	if SL.Global.Order == "Difficulty/BPM" then
		local newList = CreateSpecialSongList(songs)
		songs = newList
	end
	songs[#songs+1] = "CloseThisFolder"
	local toAdd = {}
	for k,song in pairs(songs) do
		toAdd[#toAdd+1] = {song = song, index = k}
	end
	local current_song = GAMESTATE:GetCurrentSong() or SL.Global.LastSeenSong
	local index
	for k,song in pairs(songs) do
		if song == current_song then
			index = k
		end
	end
	if index == nil then index = 1 end --TODO if songs are no longer in a folder then go to groupwheel not songwheel
	SL.Global.DifficultyGroup = group_name
	SL.Global.GradeGroup = group_name
	SongWheel:set_info_set(toAdd, index)
end

local item_mt = {
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

					subself:xy(_screen.cx, _screen.cy-100)
					
					local current_song = GAMESTATE:GetCurrentSong() or SL.Global.LastSeenSong
					if current_song then

						if self.index ~= GroupWheel:get_actor_item_at_focus_pos().index then
							subself:playcommand("LoseFocus"):diffusealpha(0)
						else
							-- position this folder in the header and switch to the songwheel
							subself:playcommand("GainFocus"):xy(70,35):zoom(0.35)
							local starting_group = GetCurrentGroup()
							switch_to_songs(starting_group)
							MESSAGEMAN:Broadcast("SwitchFocusToSongs")
							MESSAGEMAN:Broadcast("CurrentGroupChanged", {group=self.groupName})
						end
					end
				end,
				OnCommand=function(subself) subself:finishtweening() end,
				StartCommand=function(subself)
					if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
						-- slide the chosen Actor into place
						subself:queuecommand("SlideToTop")
						MESSAGEMAN:Broadcast("SwitchFocusToSongs")
					else
						-- hide everything else
						subself:linear(0.2):diffusealpha(0)
					end
				end,
				UnhideCommand=function(subself)
					-- we're going back to group selection
					-- slide the chosen group Actor back into grid position
					if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
						subself:playcommand("SlideBackIntoGrid")
						MESSAGEMAN:Broadcast("SwitchFocusToGroups")
					else
						subself:sleep(0.25):linear(0.2):diffusealpha(1)
					end
				end,
				GainFocusCommand=function(subself) subself:linear(0.2):zoom(0.8) end,
				LoseFocusCommand=function(subself) subself:linear(0.2):zoom(0.6) end,
				SlideToTopCommand=function(subself)
					subself:linear(0.12):y(35):zoom(0.35)
					       :linear(0.2 ):x(70):queuecommand("Switch")
				end,
				SlideBackIntoGridCommand=function(subself)
					subself:linear( 0.2 ):x( _screen.cx )
					       :linear( 0.12 ):zoom( 0.9 ):y( _screen.cy-100 )
				end,
				SwitchCommand=function(subself) switch_to_songs(self.groupName) end,
			

				-- back of folder
				LoadActor("./img/folderBack.png")..{
					Name="back",
					InitCommand=function(subself) subself:zoom(0.75):diffusealpha(0) end,
					OnCommand=function(subself) subself:y(-10) end,
					GainFocusCommand=function(subself) subself:diffuse(color("#c47215")) end,
					LoseFocusCommand=function(subself) subself:diffuse(color("#4e4f54")) end,
					SlideToTopCommand=function(subself) subself:sleep(.3):linear(.2):diffusealpha(0) end,
					SlideBackIntoGridCommand=function(subself) subself:linear(.2):diffusealpha(1) end,
				},

				-- group banner
				LoadActor(banner_directory.."/banner"..SL.Global.ActiveColorIndex.." (doubleres).png" )..{
					Name="FallbackBanner",
					OnCommand=function(subself) subself:y(-30):setsize(418,164):zoom(0.48) end,
				},

				Def.Banner{
					Name="Banner",
					InitCommand=function(subself) self.banner = subself end,
					OnCommand=function(subself) subself:y(-30):setsize(418,164):zoom(0.48) end,
				},

				-- front of folder
				LoadActor("./img/folderFront.png")..{
					Name="front",
					InitCommand=function(subself) subself:zoom(0.75):vertalign(bottom):diffusealpha(0) end,
					OnCommand=function(subself) subself:y(64) end,
					GainFocusCommand=function(subself) subself:diffusetopedge(color("#eebc54")):diffusebottomedge(color("#7c5505")):decelerate(0.33):rotationx(60) end,
					LoseFocusCommand=function(subself) subself:diffusebottomedge(color("#3d3e43")):diffusetopedge(color("#8d8e93")):decelerate(0.15):rotationx(0) end,
					SlideToTopCommand=function(subself) subself:sleep(.3):linear(.2):diffusealpha(0) end,
					SlideBackIntoGridCommand=function(subself) subself:linear(.2):diffusealpha(1) end,
				},

				-- group title bmt
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.bmt = subself:maxwidth(225)
						subself:_wrapwidthpixels(150):vertspacing(-4):shadowlength(0.5)
					end,
					OnCommand=function(subself)
						if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
							subself:horizalign(left):xy(150,-50):zoom(3):diffuse(Color.White):_wrapwidthpixels(480):shadowlength(0):playcommand("Untruncate")
						end
					end,
					--when the sort changes we may need to change the group text to whatever it becomes
					GroupTypeChangedMessageCommand=function(subself)
						if self.index == GroupWheel:get_actor_item_at_focus_pos().index and Input.WheelWithFocus ~= GroupWheel and GAMESTATE:GetCurrentSong() then --only if we're not on group wheel
							subself:horizalign(left):xy(150,-50):zoom(3):diffuse(Color.White):_wrapwidthpixels(480):shadowlength(0):playcommand("Untruncate")
						end
					end,		
					UntruncateCommand=function(subself) --group name to display is not necessarily the same so check in SL-SortHelpers
						self.bmt:settext(GetGroupDisplayName(self.groupName))
					end,
					TruncateCommand=function(subself) --group name to display is not necessarily the same so check in SL-SortHelpers
						self.bmt:settext(GetGroupDisplayName(self.groupName)):Truncate(max_chars)
					end,

					GainFocusCommand=function(subself) subself:x(0):horizalign(center):decelerate(0.33):y(35):zoom(1.1) end,
					LoseFocusCommand=function(subself) subself:xy(0,6):horizalign(center):linear(0.15):zoom(1):diffuse(Color.White) end,

					SlideToTopCommand=function(subself) subself:sleep(0.3):diffuse(Color.White):queuecommand("SlideToTop2") end,
					SlideToTop2Command=function(subself) subself:horizalign(left):linear(0.2):xy(150,-50):zoom(3):_wrapwidthpixels(480):shadowlength(0):playcommand("Untruncate") end,
					SlideBackIntoGridCommand=function(subself) subself:horizalign(center):decelerate(0.33):xy(0,35):zoom(1.1):diffuse(Color.White):_wrapwidthpixels(150):shadowlength(0.5):playcommand("Truncate") end,
				}
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)

			local offset = item_index - math.floor(num_items/2)
			local zm = scale(math.abs(offset),0,math.floor(num_items/2),0.9,0.05 )
			local ry = offset > 0 and 25 or (offset < 0 and -25 or 0)
			self.container:finishtweening()

			-- if we are initializing the screen, the focus starts (should start) on the SongWheel
			-- so we want to position all the folders "behind the scenes", and then call Init
			-- on the group folder with focus so that it is positioned correctly at the top
			if Input.WheelWithFocus ~= GroupWheel then
				self.container:x( offset * col.w * zm + _screen.cx ):z( -1 * math.abs(offset) ):zoom( zm ):rotationy( ry )
				if has_focus then self.container:playcommand("Init") end

			-- otherwise, we are performing a normal transform
			else
				if has_focus then
					self.container:playcommand("GainFocus")
					SL.Global.CurrentGroup = self.groupName
					MESSAGEMAN:Broadcast("CurrentGroupChanged", {group=self.groupName})
				else
					self.container:playcommand("LoseFocus")
				end
				self.container:x( offset * col.w * zm + _screen.cx ):z( -1 * math.abs(offset) ):zoom( zm ):rotationy( ry )
			end
		end,

		set = function(self, groupName)

			self.groupName = groupName

			-- handle text
			-- group name to display is not necessarily the same so check in SL-GroupHelpers
			self.bmt:settext(GetGroupDisplayName(self.groupName)):Truncate(max_chars)
			

			-- handle banner
			self.banner:LoadFromSongGroup(self.groupName):playcommand("On")
		end
	}
}

return item_mt