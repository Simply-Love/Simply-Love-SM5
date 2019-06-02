local player = ...

-- I tried really hard to use size + position variables instead of hardcoded numbers all over
-- the place, but gave up after an hour of questioning my sanity due to sub-pixel overlap
-- issues (rounding? texture sizing? I don't have time to figure it out right now.)
local row_height = 35

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
	InvalidChoiceMessageCommand=function(self, params)
		if params.PlayerNumber == player then
			self:finishtweening():bounceend(0.1):addx(5):bounceend(0.1):addx(-10):bounceend(0.1):addx(5)
		end
	end,
	PlayerJoinedMessageCommand=function(self,param)
		if param.Player == player then
			self:zoom(1.15):bounceend(0.175):zoom(1)
		end
	end,


	-- dark frame prompting players to "Press START to join!"
	Def.ActorFrame {
		Name='JoinFrame',
		FrameBackground(Color.Black, player),

		LoadFont("_miso") .. {
			Text=THEME:GetString("ScreenSelectProfile", "PressStartToJoin"),
			InitCommand=cmd(diffuseshift;effectcolor1,Color('White');effectcolor2,color("0.5,0.5,0.5");diffusealpha,0;maxwidth,180),
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,
			OffCommand=function(self) self:linear(0.1):diffusealpha(0) end
		},
	},

	-- colored frame that contains the profile scroller and DataFrame
	Def.ActorFrame {
		Name='ScrollerFrame',
		FrameBackground(PlayerColor(player), player, 1.25),

		-- semi-transparent Quad used to indicate location in SelectProfile scroller
		Def.Quad {
			InitCommand=function(self) self:diffuse({0,0,0,0}):zoomto(124,row_height):x(-56) end,
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
		},

		-- scroller containing local profiles as choices
		Def.ActorScroller{
			Name='Scroller',
			NumItemsToDraw=7,
			InitCommand=cmd(x,-56; SetFastCatchup,true; SetSecondsPerItem,0.15; diffusealpha,0; SetMask, 400,60),
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,
			TransformFunction=function(self, offset, itemIndex, numItems)
				self:y(math.floor(offset*row_height))
			end,
			children=(function()
				local items = {}

				for i=0, PROFILEMAN:GetNumLocalProfiles()-1 do
					local profile = PROFILEMAN:GetLocalProfileFromIndex(i)
					items[#items+1] = LoadFont("_miso")..{
						Text=profile:GetDisplayName(),
						InitCommand=function(self)
							-- ztest(true) ensures that the text masks properly when scrolling above/below the frame
							self:ztest(true):maxwidth(115)
						end
					}
				end

				return items
			end)()
		},

		-- player profile data
		Def.ActorFrame{
			Name="DataFrame",
			InitCommand=function(self) self:xy(62,1) end,

			-- semi-transparent Quad to the right of this colored frame to present profile stats and mods
			Def.Quad {
				InitCommand=function(self) self:valign(0):diffuse({0,0,0,0}):zoomto(112,220):y(-111) end,
				OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
			},

			-- put all BitmapText actors in an ActorFrame so they can diffusealpha() simultaneously more easily
			Def.ActorFrame{
				InitCommand=function(self) self:diffusealpha(0) end,
				OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(1) end,

				-- the name the player most recently used for high score entry
				LoadFont("_miso")..{
					Name="HighScoreName",
					InitCommand=function(self) self:align(0,0):xy(-50,-104):zoom(0.65):maxwidth(104/0.65):vertspacing(-2) end,
					SetCommand=function(self, params)
						if params.data then
							local desc = THEME:GetString("ScreenGameOver","LastUsedHighScoreName") .. ": "
							self:visible(true):settext(desc .. params.data.highscorename)
						else
							self:visible(false):settext("")
						end
					end
				},

				-- the song that was most recently played, presented as "group name/song name", eventually
				-- truncated so it passes the "How to Cook Delicious Rice and the Effects of Eating Rice" test.
				LoadFont("_miso")..{
					Name="MostRecentSong",
					InitCommand=function(self) self:align(0,0):xy(-50,-85):zoom(0.65):wrapwidthpixels(104/0.65):vertspacing(-3) end,
					SetCommand=function(self, params)
						if params.data then
							local desc = THEME:GetString("ScreenSelectProfile","MostRecentSong") .. ":\n"
							self:settext(desc .. params.data.recentsong):Truncate(112)
						else
							self:settext("")
						end
					end
				},

				-- how many songs this player has completed in gameplay
				-- failing a song will increment this count, but backing out will not
				LoadFont("_miso")..{
					Name="TotalSongs",
					InitCommand=function(self) self:align(0,0):xy(-50,0):zoom(0.65):maxwidth(104/0.65):vertspacing(-2) end,
					SetCommand=function(self, params)
						if params.data then
							self:visible(true):settext(params.data.totalsongs)
						else
							self:visible(false):settext("")
						end
					end
				},

				-- (some of) the modifiers saved to this player's UserPrefs.ini file
				-- if the list is long, it will line break and eventually be masked
				-- to prevent it from visually spilling out of the FrameBackground
				LoadFont("_miso")..{
					Name="RecentMods",
					InitCommand=function(self) self:align(0,0):xy(-50,25):zoom(0.625):wrapwidthpixels(104/0.625):vertspacing(-3):ztest(true) end,
					SetCommand=function(self, params)
						if params.data then
							self:visible(true):settext(params.data.mods)
						else
							self:visible(false):settext("")
						end
					end
				}
			},

			-- thin white line separating stats from mods
			Def.Quad {
				InitCommand=function(self) self:zoomto(100,1):y(17):diffusealpha(0) end,
				OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(0.5) end,
			},
		}
	},


	LoadActor(THEME:GetPathB("ScreenMemoryCard", "overlay/usbicon.png"))..{
		Name="USBIcon",
		InitCommand=function(self)
			self:rotationz(90):zoom(0.75):visible(false):diffuseshift()
				:effectperiod(1.5):effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.5)
		end
	},

	LoadFont("_miso")..{
		Name='SelectedProfileText',
		InitCommand=cmd(y,160; zoom, 1.35; shadowlength, ThemePrefs.Get("RainbowMode") and 0.5 or 0)
	}
}