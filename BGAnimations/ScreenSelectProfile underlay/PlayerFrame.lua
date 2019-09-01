local args = ...
local player = args.Player
local profile_data = args.ProfileData
local scroller = args.Scroller
local scroller_item_mt = LoadActor("./ScrollerItemMT.lua")


-- I tried really hard to use size + position variables instead of hardcoded numbers all over
-- the place, but gave up after an hour of questioning my sanity due to sub-pixel overlap
-- issues (rounding? texture sizing? I don't have time to figure it out right now.)
local row_height = 35
local scroller_x = -56
local scroller_y = row_height * -5

-- account for the possibility that there are no local profiles and
-- we want "[ Guest ]" to start in the middle, with focus
if PROFILEMAN:GetNumLocalProfiles() <= 0 then
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
	-- (or "Enter credits to join!" depending on CoinMode and available credits)
	Def.ActorFrame {
		Name='JoinFrame',
		FrameBackground(Color.Black, player),

		LoadFont("Common Normal")..{
			InitCommand=function(self)
				if IsArcade() and not GAMESTATE:EnoughCreditsToJoin() then
					self:settext( THEME:GetString("ScreenSelectProfile", "EnterCreditsToJoin") )
				else
					self:settext( THEME:GetString("ScreenSelectProfile", "PressStartToJoin") )
				end

				self:diffuseshift():effectcolor1(1,1,1,1):effectcolor2(0.5,0.5,0.5,1)
				self:diffusealpha(0):maxwidth(180)
			end,
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,
			OffCommand=function(self) self:linear(0.1):diffusealpha(0) end,
			CoinsChangedMessageCommand=function(self)
				if IsArcade() and GAMESTATE:EnoughCreditsToJoin() then
					self:settext(THEME:GetString("ScreenSelectProfile", "PressStartToJoin"))
				end
			end
		},
	},

	-- colored frame that contains the profile scroller and DataFrame
	Def.ActorFrame {
		Name='ScrollerFrame',
		InitCommand=function(self)
			-- Create the info needed for the "[Guest]" scroller item.
			-- It won't map to any real local profile (as desired!), so we'll hardcode
			-- an index of 0, and handle it later, on ScreenSelectProfile's OffCommand
			-- in default.lua if either/both players want to chose it.
			local guest_profile = { index=0, displayname=THEME:GetString("ScreenSelectProfile", "GuestProfile") }

			-- here, we are padding the scroller_data table with dummy scroller items to accommodate
			-- the peculiar scroller behavior of starting low, starting on item#2, not wrapping, etc.
			-- see also: https://youtu.be/bXZhTb0eUqA?t=116
			local scroller_data = {{}, {}, {}, guest_profile}

			-- add actual profile data into the scroller_data table
			for profile in ivalues(profile_data) do
				table.insert(scroller_data, profile)
			end

			scroller.focus_pos = 5
			scroller:set_info_set(scroller_data, 0)
		end,

		FrameBackground(PlayerColor(player), player, 1.25),

		-- semi-transparent Quad used to indicate location in SelectProfile scroller
		Def.Quad {
			InitCommand=function(self) self:diffuse({0,0,0,0}):zoomto(124,row_height):x(-56) end,
			OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
		},

		-- sick_wheel scroller containing local profiles as choices
		scroller:create_actors( "Scroller", 9, scroller_item_mt, scroller_x, scroller_y ),

		-- player profile data
		Def.ActorFrame{
			Name="DataFrame",
			InitCommand=function(self) self:xy(62,1) end,
			OnCommand=function(self) self:playcommand("Set", profile_data[1]) end,

			-- semi-transparent Quad to the right of this colored frame to present profile stats and mods
			Def.Quad {
				InitCommand=function(self) self:vertalign(top):diffuse(0,0,0,0):zoomto(112,221):y(-111) end,
				OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
			},

			-- put all BitmapText actors in an ActorFrame so they can diffusealpha() simultaneously more easily
			Def.ActorFrame{
				InitCommand=function(self) self:diffusealpha(0) end,
				OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(1) end,

				-- the name the player most recently used for high score entry
				LoadFont("Common Normal")..{
					Name="HighScoreName",
					InitCommand=function(self) self:align(0,0):xy(-50,-104):zoom(0.65):maxwidth(104/0.65):vertspacing(-2) end,
					SetCommand=function(self, params)
						if params then
							local desc = THEME:GetString("ScreenGameOver","LastUsedHighScoreName") .. ": "
							self:visible(true):settext(desc .. (params.highscorename or ""))
						else
							self:visible(false):settext("")
						end
					end
				},

				-- the song that was most recently played, presented as "group name/song name", eventually
				-- truncated so it passes the "How to Cook Delicious Rice and the Effects of Eating Rice" test.
				LoadFont("Common Normal")..{
					Name="MostRecentSong",
					InitCommand=function(self) self:align(0,0):xy(-50,-85):zoom(0.65):_wrapwidthpixels(104/0.65):vertspacing(-3) end,
					SetCommand=function(self, params)
						if params then
							local desc = THEME:GetString("ScreenSelectProfile","MostRecentSong") .. ":\n"
							self:settext(desc .. (params.recentsong or "")):Truncate(112)
						else
							self:settext("")
						end
					end
				},

				-- how many songs this player has completed in gameplay
				-- failing a song will increment this count, but backing out will not
				LoadFont("Common Normal")..{
					Name="TotalSongs",
					InitCommand=function(self) self:align(0,0):xy(-50,0):zoom(0.65):maxwidth(104/0.65):vertspacing(-2) end,
					SetCommand=function(self, params)
						if params then
							self:visible(true):settext(params.totalsongs or "")
						else
							self:visible(false):settext("")
						end
					end
				},

				-- (some of) the modifiers saved to this player's UserPrefs.ini file
				-- if the list is long, it will line break and eventually be masked
				-- to prevent it from visually spilling out of the FrameBackground
				LoadFont("Common Normal")..{
					Name="RecentMods",
					InitCommand=function(self) self:align(0,0):xy(-50,25):zoom(0.625):_wrapwidthpixels(104/0.625):vertspacing(-3):ztest(true) end,
					SetCommand=function(self, params)
						if params then
							self:visible(true):settext(params.mods or "")
						else
							self:visible(false):settext("")
						end
					end
				},

				-- NoteSkin preview
				Def.ActorProxy{
					Name="NoteSkinPreview",
					InitCommand=function(self) self:zoom(0.25):xy(-42,50) end,
					SetCommand=function(self, params)
						local underlay = SCREENMAN:GetTopScreen():GetChild("Underlay")
						if params and params.noteskin then
							local noteskin = underlay:GetChild("NoteSkin_"..params.noteskin)
							if noteskin then
								self:visible(true):SetTarget(noteskin)
							else
								self:visible(false)
							end
						else
							self:visible(false)
						end
					end
				},

				-- JudgmentGraphic preview
				Def.ActorProxy{
					Name="JudgmentGraphicPreview",
					InitCommand=function(self) self:zoom(0.35):xy(12,68) end,
					SetCommand=function(self, params)
						local underlay = SCREENMAN:GetTopScreen():GetChild("Underlay")
						if params and params.judgment then
							local judgment = underlay:GetChild("JudgmentGraphic_"..StripSpriteHints(params.judgment))
							if judgment then
								self:SetTarget(judgment)
							else
								self:SetTarget(underlay:GetChild("JudgmentGraphic_None"))
							end
						else
							self:SetTarget(underlay:GetChild("JudgmentGraphic_None"))
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

	LoadFont("Common Normal")..{
		Name='SelectedProfileText',
		InitCommand=function(self)
			self:settext(profile_data[1] and profile_data[1].displayname or "")
			self:y(160):zoom(1.35):shadowlength(ThemePrefs.Get("RainbowMode") and 0.5 or 0):cropright(1)
		end,
		OnCommand=function(self) self:sleep(0.2):smooth(0.2):cropright(0) end
	}
}