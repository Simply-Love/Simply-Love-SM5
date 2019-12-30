local args = ...
local player = args.Player
local scroller = args.Scroller
local scroller_item_mt = LoadActor("./ScrollerItemMT.lua")
local data = args.data

-- I tried really hard to use size + position variables instead of hardcoded numbers all over
-- the place, but gave up after an hour of questioning my sanity due to sub-pixel overlap
-- issues (rounding? texture sizing? I don't have time to figure it out right now.)
local row_height = 35
local scroller_x = -56
local scroller_y = row_height * -5

-- account for the possibility that there are no local profiles and
-- we want "[ Guest ]" to start in the middle, with focus
if #GetGroups("Tag") <= 0 then
	scroller_y = row_height * -4
end


local FrameBackground = function(c, player, w)
	w = w or 1

	return Def.ActorFrame {
		InitCommand=function(self) self:zoomto(w, 1) end,

		-- a lightly styled png asset that is not so different than a Quad
		-- currently inherited from _fallback
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardBackground") )..{
			InitCommand=function(self)
				self:diffuse(c):cropbottom(1)
			end,
			ShowTagMenuCommand=function(self) self:smooth(0.3):cropbottom(0) end,
			OffCommand=function(self)
				self:sleep(.4):cropbottom(1)
			end
		},

		-- a png asset that gives the colored frame (above) a lightly frosted feel
		-- currently inherited from _fallback
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardFrame") )..{
			InitCommand=function(self) self:cropbottom(1) end,
			ShowTagMenuCommand=function(self) self:smooth(0.3):cropbottom(0) end,
			OffCommand=function(self)
				self:sleep(.4):cropbottom(1)
			end
		}
	}
end

-- ----------------------------------------------------

return Def.ActorFrame{
	Name=ToEnumShortString(player) .. "Frame",
	InitCommand=function(self) self:xy(_screen.cx+(150*(player==PLAYER_1 and -1 or 1)), _screen.cy) end,
	ShowTagMenuCommand=function(self) self:zoom(1) end,
	OffCommand=function(self)
		if GAMESTATE:IsSideJoined(player) then
			self:bouncebegin(0.35):zoom(0)
		end
	end,
	
	-- colored frame that contains the profile scroller and DataFrame
	Def.ActorFrame {
		Name='ScrollerFrame',
		InitCommand=function(self)
			self:playcommand("SetTagWheel")
		end,
		SetTagWheelCommand=function(self)
			-- here, we are padding the scroller_data table with dummy scroller items to accommodate
			-- the peculiar scroller behavior of starting low, starting on item#2, not wrapping, etc.
			-- see also: https://youtu.be/bXZhTb0eUqA?t=116
			local scroller_data = {}
			local index_padding = 3
			if #GetGroups("Tag") <= 1 then index_padding = 4 end
			for i = 1,index_padding do
				table.insert(scroller_data,{})
			end
			table.insert(scroller_data,{index = 0, displayname = "Create New Tag"})
			for k,v in pairs(GetGroups("Tag")) do
				if v ~= "No Tags Set" and v ~= "BPM Changes" then table.insert(scroller_data,{index = k, displayname = v}) end
			end
			scroller.focus_pos = 5
			scroller:set_info_set(scroller_data, 0)
		end,
		
		FrameBackground(PlayerColor(player), player, 1.25),

		-- semi-transparent Quad used to indicate location in SelectProfile scroller
		Def.Quad {
			InitCommand=function(self) self:diffuse({0,0,0,0}):zoomto(124,row_height):x(-56) end,
			ShowTagMenuCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
			OffCommand=function(self) self:sleep(.4):diffusealpha(0) end,
		},

		-- sick_wheel scroller containing tags as choices
		scroller:create_actors( "Scroller", 9, scroller_item_mt, scroller_x, scroller_y ),

		-- player profile data
		Def.ActorFrame{
			Name="DataFrame",
			InitCommand=function(self) self:xy(62,1) end,

			-- semi-transparent Quad to the right of this colored frame to present profile stats and mods
			Def.Quad {
				InitCommand=function(self) self:vertalign(top):diffuse(0,0,0,0):zoomto(112,221):y(-111) end,
				ShowTagMenuCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
				OffCommand=function(self) self:sleep(.4):diffusealpha(0) end,
			},

			-- put all BitmapText actors in an ActorFrame so they can diffusealpha() simultaneously more easily
			Def.ActorFrame{
				InitCommand=function(self) self:diffusealpha(0) end,
				OffCommand=function(self) self:sleep(.4):diffusealpha(0) end,
				ShowTagMenuCommand=function(self)
					self:sleep(0.45):linear(0.1):diffusealpha(1)
					local index = scroller:get_info_at_focus_pos().index
					self:playcommand("Set",{index=index})
				end,
				-- list of songs in the custom group
				LoadFont("Common Normal")..{
					Name="SongList",
					InitCommand=function(self) self:align(0,0):xy(-50,-104):zoom(0.65):maxwidth(104/0.65):vertspacing(-2) end,
					SetCommand=function(self, params)
						if params.index == 0 then
							self:settext("")
						else
							local data={}
							for group in ivalues(GetGroups("Tag")) do
								data[#data+1]=GetSongList(group, "Tag")
							end
							local toWrite = ""
							for song in ivalues(data[params.index]) do
								toWrite = toWrite..song:GetMainTitle().."\n"
							end
							self:settext(toWrite)
						end
					end
				},
				LoadFont("Common Normal")..{
					Name='AddOrRemove',
					InitCommand=function(self)
						self:y(160):zoom(1.35):shadowlength(ThemePrefs.Get("RainbowMode") and 0.5 or 0):cropright(1)
					end,
					ShowTagMenuCommand=function(self) self:sleep(0.2):smooth(0.2):cropright(0) end,
					OffCommand=function(self) self:sleep(.35):cropright(1) end,
					SetCommand=function(self, params)
						if params.index == 0 then 
							self:settext("Create a new tag") 
						else
							local current_song = GAMESTATE:GetCurrentSong() or SL.Global.LastSeenSong
							local group = GetGroups("Tag")[params.index]
							local inGroup = GetTags(current_song, group)
							self:settext((inGroup and "Remove [" or "Add [")..current_song:GetMainTitle()..(inGroup and "] from " or "] to ")..group)
						end
					end
				}

			},

		}
	},

}