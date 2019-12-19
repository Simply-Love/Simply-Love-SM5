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
			self:playcommand("SetOrderWheel")
		end,
		SetOrderWheelCommand=function(self)
			-- here, we are padding the scroller_data table with dummy scroller items to accommodate
			-- the peculiar scroller behavior of starting low, starting on item#2, not wrapping, etc.
			-- see also: https://youtu.be/bXZhTb0eUqA?t=116
			local scroller_data = {}
			local index_padding = 4
			for i = 1,index_padding do
				table.insert(scroller_data,{})
			end
			table.insert(scroller_data,{index = 1, displayname = "Alphabetical"})
			descriptions[#descriptions+1] = "Order songs\nalphabetically"
			table.insert(scroller_data,{index = 2, displayname = "BPM"})
			descriptions[#descriptions+1] = "Order songs\nby BPM"
			table.insert(scroller_data,{index = 3, displayname = "Difficulty/BPM"})
			local toWrite = "Order songs\nby difficulty\nand then BPM\n\nNote: Songs will\nbe duplicated for\neach chart."
			toWrite = toWrite.."\n\n\***EXAMPLE***\n[12][136] Song A\n[13][120] Song B\n[13][140] Song A\n[15][200] Song C"
			descriptions[#descriptions+1] = toWrite
			scroller.focus_pos = 5
			scroller:set_info_set(scroller_data, 0)
		end,
		
		FrameBackground(PlayerColor(player), player, 1.25),

		-- semi-transparent Quad used to indicate location in SelectProfile scroller
		Def.Quad {
			InitCommand=function(self) self:diffuse({0,0,0,0}):zoomto(124,row_height):x(-56) end,
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
		},

		-- sick_wheel scroller containing tags as choices
		scroller:create_actors( "Scroller", 9, scroller_item_mt, scroller_x, scroller_y ),

		-- player profile data
		Def.ActorFrame{
			Name="DataFrame",
			InitCommand=function(self) self:xy(62,1) end,
			OnCommand=function(self) end,

			-- semi-transparent Quad to the right of this colored frame to present profile stats and mods
			Def.Quad {
				InitCommand=function(self) self:vertalign(top):diffuse(0,0,0,0):zoomto(112,221):y(-111) end,
				OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
			},

			-- put all BitmapText actors in an ActorFrame so they can diffusealpha() simultaneously more easily
			Def.ActorFrame{
				InitCommand=function(self) self:diffusealpha(0) end,
				OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(1) end,
				ShowOrderMenuCommand=function(self)
					local index = scroller:get_info_at_focus_pos().index
					self:playcommand("Set",{index=index})
				end,
				-- description of each order
				LoadFont("Common Normal")..{
					Name="Explanation",
					InitCommand=function(self) self:align(0,0):xy(-50,-104):zoom(0.65):maxwidth(104/0.65):vertspacing(-2) end,
					SetCommand=function(self, params)
						self:settext(descriptions[params.index])
					end
				},

			},

		}
	},

}