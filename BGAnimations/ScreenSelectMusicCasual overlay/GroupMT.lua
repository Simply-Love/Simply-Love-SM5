local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local TransitionTime = args[3]
local steps_type = args[4]
local row = args[5]
local col = args[6]
local Input = args[7]

local max_chars = 64

local switch_to_songs = function(group_name)
	local songs = {}
	local current_song = GAMESTATE:GetCurrentSong()
	local index = 1

	-- prune out songs that don't have valid steps
	for i,song in ipairs(SONGMAN:GetSongsInGroup(group_name)) do
		-- this should be guaranteed by this point, but better safe than segfault
		if song:HasStepsType(steps_type)
		-- respect StepMania's cutoff for 1-round songs
		and song:MusicLengthSeconds() < PREFSMAN:GetPreference("LongVerSongSeconds") then
			for steps in ivalues(song:GetStepsByStepsType(steps_type)) do
				if steps:GetMeter() < ThemePrefs.Get("CasualMaxMeter") then
					songs[#songs+1] = song
					break
				end
			end
		end
		-- we need to retain the index of the currnt song so we can set the SongWheel to start on it
		if current_song == song then index = #songs end
	end

	songs[#songs+1] = "CloseThisFolder"

	SongWheel:set_info_set(songs, index)
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

					subself:xy(_screen.cx, _screen.cy)

					if GAMESTATE:GetCurrentSong() then

						if self.index ~= GroupWheel:get_actor_item_at_focus_pos().index then
							subself:playcommand("LoseFocus"):diffusealpha(0)
						else
							-- position this folder in the header
							subself:playcommand("GainFocus"):xy(70,35):zoom(0.35)

							local starting_group = GAMESTATE:GetCurrentSong():GetGroupName()
							switch_to_songs(starting_group)
							MESSAGEMAN:Broadcast("SwitchFocusToSongs")
							MESSAGEMAN:Broadcast("CurrentGroupChanged", {group=starting_group})
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
				GainFocusCommand=cmd(linear,0.2; zoom,0.8),
				LoseFocusCommand=cmd(linear,0.2; zoom,0.6),
				SlideToTopCommand=cmd( linear, 0.12; y, 35; zoom, 0.35; linear, 0.2; x, 70; queuecommand, "Switch" ),
				SlideBackIntoGridCommand=function(subself)
					subself:linear( 0.2 ):x( _screen.cx )
						:linear( 0.12 ):zoom( 0.9 ):y( _screen.cy )
				end,
				SwitchCommand=function(subself) switch_to_songs(self.groupName) end,


				-- back of folder
				LoadActor("./img/folderBack.png")..{
					Name="back",
					InitCommand=cmd(zoom,0.75),
					OnCommand=cmd(y,-10),
					GainFocusCommand=cmd(diffuse, color("#c47215")),
					LoseFocusCommand=cmd(diffuse, color("#4e4f54"))
				},

				-- group banner
				Def.Banner{
					Name="Banner",
					InitCommand=function(subself) self.banner = subself end,
					OnCommand=cmd(y,-30; setsize,418,164; zoom, 0.48),
				},

				-- front of folder
				LoadActor("./img/folderFront.png")..{
					Name="front",
					InitCommand=cmd(zoom,0.75; valign,1),
					OnCommand=cmd(y, 64),
					GainFocusCommand=cmd( diffusetopedge, color("#eebc54"); diffusebottomedge, color("#7c5505"); decelerate,0.33; rotationx,50; ),
					LoseFocusCommand=cmd( diffusebottomedge, color("#3d3e43"); diffusetopedge, color("#8d8e93"); decelerate,0.15; rotationx,0; ),
				},

				-- group title bmt
				Def.BitmapText{
					Font="_miso",
					InitCommand=function(subself)
						self.bmt = subself
						subself:wrapwidthpixels(150):vertspacing(-4):shadowlength(0.5)
					end,
					OnCommand=function(subself)
						if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
							subself:horizalign(left):xy(150,-6):zoom(3):diffuse(Color.White):wrapwidthpixels(480):shadowlength(0):playcommand("Untruncate")
						end
					end,
					UntruncateCommand=function(subself) subself:settext(self.groupName) end,
					TruncateCommand=function(subself) subself:settext(self.groupName):Truncate(max_chars) end,

					GainFocusCommand=cmd(x, 0 horizalign, center; linear, 0.15; y, 20; zoom,1.1),
					LoseFocusCommand=cmd(xy, 0, 6; horizalign, center; linear, 0.15; zoom, 1; diffuse, Color.White),
					SlideToTopCommand=function(subself)
						subself:sleep(0.3):diffuse(Color.White):queuecommand("SlideToTop2")
					end,
					SlideToTop2Command=cmd(horizalign, left; linear, 0.2; xy, 150,-6; zoom, 3; wrapwidthpixels, 480; shadowlength, 0; playcommand, "Untruncate"),
					SlideBackIntoGridCommand=cmd(horizalign, center; linear, 0.2; xy, 0,20; zoom, 1.1; diffuse, Color.White; wrapwidthpixels, 150; shadowlength, 0.5; playcommand, "Truncate"),
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
			self.bmt:settext(self.groupName):Truncate(max_chars)

			-- handle banner
			self.banner:LoadFromSongGroup(self.groupName):playcommand("On")
		end
	}
}

return item_mt