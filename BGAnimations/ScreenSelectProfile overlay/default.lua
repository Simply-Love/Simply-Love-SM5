-- AutoStyle is a Simply Love ThemePref that can allow players to always
-- automatically have one of [single, double, versus] chosen for them.
-- If AutoStyle is either "single" or "double", we don't want to load
-- SelectProfileFrames for both PLAYER_1 and PLAYER_2, but only the MasterPlayerNumber
local AutoStyle = ThemePrefs.Get("AutoStyle")

-- retrieve the MasterPlayerNumber now, at initialization, so that if AutoStyle is set
-- to "single" or "double" and that singular player unjoins, we still have a handle on
-- which PlayerNumber they're supposed to be...
local mpn = GAMESTATE:GetMasterPlayerNumber()

local GetLocalProfiles = function()
	local t = {}

	function GetSongsPlayedString(numSongs)
		return numSongs == 1 and Screen.String("SingularSongPlayed") or Screen.String("SeveralSongsPlayed")
	end

	for p = 0,PROFILEMAN:GetNumLocalProfiles()-1 do
		local profile=PROFILEMAN:GetLocalProfileFromIndex(p)
		local ProfileCard = Def.ActorFrame {
			LoadFont("_miso") .. {
				Text=profile:GetDisplayName(),
				InitCommand=cmd(y,-10;zoom,1;ztest,true)
			},
			LoadFont("_miso") .. {
				InitCommand=cmd(y,8;zoom,0.5;vertspacing,-8;ztest,true),
				BeginCommand=function(self)
					local numSongsPlayed = profile:GetNumTotalSongsPlayed()
					self:settext( string.format( GetSongsPlayedString( numSongsPlayed ), numSongsPlayed ) )
				end
			},
		}
		t[#t+1]=ProfileCard
	end

	return t
end

local LoadCard = function(c, player)
	return Def.ActorFrame {
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardBackground") )..{
			InitCommand=function(self) self:diffuse(c):cropbottom(1) end,
			OnCommand=function(self) self:smooth(0.3):cropbottom(0) end,
			OffCommand=function(self)
				if not GAMESTATE:IsSideJoined(player) then
					self:accelerate(0.25):cropbottom(1)
				end
			end
		},
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

local UpdateInternal3 = function(self, Player)
	local frame = self:GetChild(ToEnumShortString(Player) .. 'Frame')
	local scroller = frame:GetChild('Scroller')
	local seltext = frame:GetChild('SelectedProfileText')
	local joinframe = frame:GetChild('JoinFrame')
	local smallframe = frame:GetChild('SmallFrame')
	local bigframe = frame:GetChild('BigFrame')
	local usbsprite = frame:GetChild('USBIcon')

	if GAMESTATE:IsHumanPlayer(Player) then

		frame:visible(true)

		if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
			--using local profile
			joinframe:visible(false)
			usbsprite:visible(false)
			smallframe:visible(true)
			bigframe:visible(true)
			seltext:visible(true)
			scroller:visible(true)

			local ind = SCREENMAN:GetTopScreen():GetProfileIndex(Player)
			if ind > 0 then
				scroller:SetDestinationItem(ind-1)
				seltext:settext(PROFILEMAN:GetLocalProfileFromIndex(ind-1):GetDisplayName())
			else
				if SCREENMAN:GetTopScreen():SetProfileIndex(Player, 1) then
					scroller:SetDestinationItem(0)
					self:queuecommand('UpdateInternal2')
				else
					joinframe:visible(true)
					smallframe:visible(false)
					bigframe:visible(false)
					scroller:visible(false)
					seltext:settext(ScreenString("NoProfile"))
				end
			end
		else
			--using memorycard profile
			bigframe:visible(false)
			joinframe:visible(false)
			smallframe:visible(false)
			scroller:visible(false)

			usbsprite:visible(true)
			seltext:visible(true):settext(MEMCARDMAN:GetName(Player))

			SCREENMAN:GetTopScreen():SetProfileIndex(Player, 0)
		end
	else
		usbsprite:visible(false)
		joinframe:visible(true)
		scroller:visible(false)
		seltext:visible(false)
		smallframe:visible(false)
		bigframe:visible(false)
	end
end



local t = Def.ActorFrame {
	InitCommand=function(self) self:queuecommand("Capture"); main_af = self end,
	CaptureCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./Input.lua", self) ) end,

	-- the OffCommand will have been queued, when it is appropriate, from Input.lua
	-- sleep for 0.5 seconds to give the playerframes time to tween out
	-- and queue a call to finish() so that the engine can wrap things up
	OffCommand=function(self) self:sleep(0.5):queuecommand("Finish") end,
	FinishCommand=function(self) SCREENMAN:GetTopScreen():Finish() end,

	StorageDevicesChangedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2')
	end,

	CodeMessageCommand=function(self, params)

		if (AutoStyle=="single" or AutoStyle=="double") and params.PlayerNumber ~= mpn then return end

		if params.Name == "Select" then
			if GAMESTATE:GetNumPlayersEnabled()==0 then
				SCREENMAN:GetTopScreen():Cancel()
			else
				-- only attempt to unjoin the player if that side is currently joined
				if GAMESTATE:IsSideJoined(params.PlayerNumber) then
					MESSAGEMAN:Broadcast("BackButton")
					SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -2)
					GAMESTATE:UnjoinPlayer(params.PlayerNumber)
				end
			end
			return
		end
	end,

	PlayerJoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2')
	end,

	PlayerUnjoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2')
	end,

	OnCommand=function(self, params)
		self:queuecommand('UpdateInternal2')
	end,

	UpdateInternal2Command=function(self)
		if AutoStyle=="none" or AutoStyle=="versus" then
			UpdateInternal3(self, PLAYER_1)
			UpdateInternal3(self, PLAYER_2)
		else
			UpdateInternal3(self, mpn)
		end
	end,

	children = {
		-- sounds
		LoadActor( THEME:GetPathS("Common","start") )..{
			StartButtonMessageCommand=cmd(play)
		},
		LoadActor( THEME:GetPathS("ScreenSelectMusic","select down") )..{
			BackButtonMessageCommand=cmd(play)
		},
		LoadActor( THEME:GetPathS("ScreenSelectMaster","change") )..{
			DirectionButtonMessageCommand=cmd(play)
		},
		LoadActor( THEME:GetPathS("Common", "invalid") )..{
			InvalidChoiceMessageCommand=function(self) self:play() end
		}
	}
}

local PlayerFrame = function(player)
	return Def.ActorFrame {
		Name=ToEnumShortString(player) .. "Frame",
		InitCommand=function(self) self:xy(_screen.cx+(160*(player==PLAYER_1 and -1 or 1)), _screen.cy) end,
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

		children = {
			Def.ActorFrame {
				Name='JoinFrame',
				LoadCard(Color.Black, player),

				LoadFont("_miso") .. {
					Text=THEME:GetString("ScreenSelectProfile", "PressStartToJoin"),
					InitCommand=cmd(diffuseshift;effectcolor1,Color('White');effectcolor2,color("0.5,0.5,0.5"); diffusealpha, 0),
					OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,
					OffCommand=function(self) self:linear(0.1):diffusealpha(0) end
				},
			},

			Def.ActorFrame {
				Name='BigFrame',
				LoadCard(PlayerColor(player), player)
			},

			Def.ActorFrame {
				Name='SmallFrame',
				InitCommand=cmd(y,-2),

				Def.Quad {
					InitCommand=cmd(zoomto,200-10,40+2; diffuse,Color('Black'); diffusealpha,0),
					OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(0.5) end,
				},
			},

			Def.Sprite{
				Name="USBIcon",
				Texture=THEME:GetPathB("ScreenMemoryCard", "overlay/usbicon.png"),
				InitCommand=function(self)
					self:rotationz(90):zoom(0.75):visible(false):diffuseshift()
						:effectperiod(1.5):effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.5)
				end
			},

			Def.ActorScroller{
				Name='Scroller',
				NumItemsToDraw=6,
				InitCommand=cmd(y,1;SetFastCatchup,true;SetMask,200,58;SetSecondsPerItem,0.15; diffusealpha,0),
				OnCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,
				TransformFunction=function(self, offset, itemIndex, numItems)
					local focus = scale(math.abs(offset),0,2,1,0)
					self:visible(false)
					self:y(math.floor( offset*40 ))

				end;
				children = GetLocalProfiles()
			},

			LoadFont("_miso")..{
				Name='SelectedProfileText',
				InitCommand=cmd(y,160; zoom, 1.35; shadowlength, ThemePrefs.Get("RainbowMode") and 0.5 or 0)
			}
		}
	}
end

-- load SelectProfileFrames for both
if AutoStyle=="none" or AutoStyle=="versus" then
	t.children[#t.children+1] = PlayerFrame(PLAYER_1)
	t.children[#t.children+1] = PlayerFrame(PLAYER_2)

-- load only for the MasterPlayerNumber
else
	t.children[#t.children+1] = PlayerFrame(mpn)
end

return t