local args = ...
local player = args.Player
local scroller = args.Scroller
local scroller_item_mt = LoadActor("./ScrollerItemMT.lua")

-- I tried really hard to use size + position variables instead of hardcoded numbers all over
-- the place, but gave up after an hour of questioning my sanity due to sub-pixel overlap
-- issues (rounding? texture sizing? I don't have time to figure it out right now.)
local row_height = 35
local scroller_x = -56
local scroller_y = row_height * -5

local descriptions = {}


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
			OnCommand=function(self) self:smooth(0.3):cropbottom(0) end,
			OffCommand=function(self)
				if not GAMESTATE:IsSideJoined(player) then
					self:accelerate(0.25):cropbottom(1)
				end
			end
		},

		-- a png asset that gives the colored frame (above) a lightly frosted feel
		-- currently inherited from _fallback
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardFrame") )..{
			InitCommand=function(self) self:cropbottom(1) end,
			OnCommand=function(self) self:smooth(0.3):cropbottom(0) end,
			OffCommand=function(self)
				if not GAMESTATE:IsSideJoined(player) then
					self:accelerate(0.25):cropbottom(1)
				end
			end
		}
	}
end

-- ----------------------------------------------------

return Def.ActorFrame{
	Name=ToEnumShortString(player) .. "Frame",
	InitCommand=function(self) self:xy(_screen.cx+(150*(player==PLAYER_1 and -1 or 1)), _screen.cy) end,

	OffCommand=function(self)
		if GAMESTATE:IsSideJoined(player) then
			self:bouncebegin(0.35):zoom(0)
		end
	end,
	
	-- colored frame that contains the profile scroller and DataFrame
	Def.ActorFrame {
		Name='ScrollerFrame',
		InitCommand=function(self)
		end,
		SetSearchWheelMessageCommand=function(self, params)
			-- here, we are padding the scroller_data table with dummy scroller items to accommodate
			-- the peculiar scroller behavior of starting low, starting on item#2, not wrapping, etc.
			-- see also: https://youtu.be/bXZhTb0eUqA?t=116
			descriptions = {}
			local scroller_data = {}
			local index_padding = 4
			for i = 1,index_padding do
				table.insert(scroller_data,{})
				descriptions[#descriptions+1] = ""
			end
			-- search for groups and songs that fit the searchTerm
			local tempGroups = GetGroups()
			for group in ivalues(PruneGroups(tempGroups)) do
				if string.find(string.lower(group),string.lower(params.searchTerm),1,true) then
					table.insert(scroller_data,{index=#scroller_data,displayname=GetGroupDisplayName(group),type="group",group=group})
					local toWrite = "Song Group\n---------------\n"
					for k,song in pairs(GetSongList(group)) do
						if k < 12 then
							toWrite = toWrite..song:GetDisplayMainTitle().."\n"
						end
					end
					if #GetSongList(group) > 12 then
						local remainder = #GetSongList(group) - 11
						toWrite = toWrite.."and "..remainder.." other songs"
					end
					descriptions[#descriptions+1] = toWrite
				end
			end
			for group in ivalues(tempGroups) do
				for song in ivalues(PruneSongList(GetSongList(group))) do
					if string.find(string.lower(song:GetDisplayMainTitle()),string.lower(params.searchTerm),1,true) then
						table.insert(scroller_data,{index=#scroller_data,displayname=song:GetDisplayMainTitle(),type="song",group=group,song=song})
						descriptions[#descriptions+1] = "Group: "..GetGroupDisplayName(group).."\nLoaded from: "..song:GetGroupName()
					end
				end
			end
			table.insert(scroller_data,{index=#scroller_data,displayname="Exit",type="exit",group="nothing"})
			descriptions[#descriptions+1] = ""
			scroller.focus_pos = 5
			scroller:set_info_set(scroller_data, 0)
			self:playcommand("Set",{index=5,searchTerm = params.searchTerm})
		end,
		
		FrameBackground(PlayerColor(player), player, 2)..{InitCommand = function(self) self:x(50) end},

		-- semi-transparent Quad used to indicate location in SelectProfile scroller
		Def.Quad {
			InitCommand=function(self) self:diffuse({0,0,0,0}):zoomto(145,row_height):x(-67) end,
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
		},

		-- sick_wheel scroller containing search results as choices
		scroller:create_actors( "Scroller", 9, scroller_item_mt, scroller_x, scroller_y ),

		-- description of the results
		Def.ActorFrame{
			Name="DataFrame",
			InitCommand=function(self) self:xy(62,1) end,
			OnCommand=function(self) end,

			-- semi-transparent Quad to the right of this colored frame to present song or group info
			Def.Quad {
				InitCommand=function(self) self:vertalign(top):diffuse(0,0,0,0):zoomto(235,221):xy(-57,-111):halign(0) end,
				OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
			},

			-- put all BitmapText actors in an ActorFrame so they can diffusealpha() simultaneously more easily
			Def.ActorFrame{
				InitCommand=function(self) self:diffusealpha(0) end,
				OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(1) end,
				ShowSearchMenuCommand=function(self)
					local index = scroller:get_info_at_focus_pos().index
					self:playcommand("Set",{index=index})
				end,
				-- description of each item
				LoadFont("Common Normal")..{
					Name="Explanation",
					InitCommand=function(self) self:align(0,0):xy(-50,-104):zoom(0.65):maxwidth(330):vertspacing(-2) end,
					SetCommand=function(self, params)
						self:settext(descriptions[params.index])
					end
				},
				LoadFont("Common Normal")..{
					Name='Number of Results',
					InitCommand=function(self)
						self:y(160):zoom(1.35):shadowlength(ThemePrefs.Get("RainbowMode") and 0.5 or 0):cropright(1)
					end,
					OnCommand=function(self) self:sleep(0.2):smooth(0.2):cropright(0) end,
					SetCommand=function(self, params)
						if #descriptions > 5 then 
							local plural = #descriptions > 6 and "s" or ""
							self:settext(#descriptions-5 .. " result"..plural.. " found") 
						else
							self:settext("No results found")
						end
					end
				},
				LoadFont("Common Normal")..{
					Name='SearchTerm',
					InitCommand=function(self)
						self:y(-160):zoom(1.35):shadowlength(ThemePrefs.Get("RainbowMode") and 0.5 or 0):cropright(1)
					end,
					OnCommand=function(self) self:sleep(0.2):smooth(0.2):cropright(0) end,
					SetCommand=function(self, params)
						if params and params.searchTerm then
							self:settext("Search results for: "..params.searchTerm)
						else
							self:settext("")
						end
					end
				}
			},

		}
	},

}