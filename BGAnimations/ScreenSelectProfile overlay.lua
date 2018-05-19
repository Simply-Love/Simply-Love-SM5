-- AutoStyle is a Simply Love ThemePref that can allow players to always
-- automatically have one of [single, double, versus] chosen for them.
-- If AutoStyle is either "single" or "double", we don't want to load
-- SelectProfileFrames for both PLAYER_1 and PLAYER_2, but only the MasterPlayerNumber
local AutoStyle = ThemePrefs.Get("AutoStyle")

function GetLocalProfiles()
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

function LoadCard(cColor)
	return Def.ActorFrame {
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardBackground") )..{ InitCommand=function(self) self:diffuse(cColor) end },
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardFrame") )
	}
end


function LoadPlayerStuff(Player)
	local t = {}

	t[#t+1] = Def.ActorFrame {
		Name='JoinFrame',
		LoadCard(Color.Black),

		LoadFont("_miso") .. {
			Text=THEME:GetString("ScreenSelectProfile", "PressStartToJoin"),
			OnCommand=cmd(diffuseshift;effectcolor1,Color('White');effectcolor2,color("0.5,0.5,0.5")),
		},
	}

	t[#t+1] = Def.ActorFrame {
		Name='BigFrame',
		LoadCard(PlayerColor(Player))
	}

	t[#t+1] = Def.ActorFrame {
		Name='SmallFrame',
		InitCommand=cmd(y,-2),

		Def.Quad {
			InitCommand=cmd(zoomto,200-10,40+2),
			OnCommand=cmd(diffuse,Color('Black');diffusealpha,0.5),
		},
	}

	t[#t+1] = Def.ActorScroller{
		Name='Scroller',
		NumItemsToDraw=6,
		OnCommand=cmd(y,1;SetFastCatchup,true;SetMask,200,58;SetSecondsPerItem,0.15),
		TransformFunction=function(self, offset, itemIndex, numItems)
			local focus = scale(math.abs(offset),0,2,1,0)
			self:visible(false)
			self:y(math.floor( offset*40 ))

		end;
		children = GetLocalProfiles()
	}

	t[#t+1] = LoadFont("_miso") .. {
		Name='SelectedProfileText',
		InitCommand=cmd(y,160;)
	}

	return t
end

function UpdateInternal3(self, Player)
	local frame = self:GetChild(ToEnumShortString(Player) .. 'Frame')
	local scroller = frame:GetChild('Scroller')
	local seltext = frame:GetChild('SelectedProfileText')
	local joinframe = frame:GetChild('JoinFrame')
	local smallframe = frame:GetChild('SmallFrame')
	local bigframe = frame:GetChild('BigFrame')

	if GAMESTATE:IsHumanPlayer(Player) then
		frame:visible(true)
		if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
			--using profile if any
			joinframe:visible(false)
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
			--using card
			smallframe:visible(false)
			scroller:visible(false)
			seltext:settext(ScreenString("Card"))
			SCREENMAN:GetTopScreen():SetProfileIndex(Player, 0)
		end
	else
		joinframe:visible(true)
		scroller:visible(false)
		seltext:visible(false)
		smallframe:visible(false)
		bigframe:visible(false)
	end
end

local t = Def.ActorFrame {

	StorageDevicesChangedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2')
	end,

	CodeMessageCommand=function(self, params)
		if (AutoStyle=="single" or AutoStyle=="double") and params.PlayerNumber ~= GAMESTATE:GetMasterPlayerNumber() then
			return
		end

		if params.Name == 'Start' or params.Name == 'Center' then
			MESSAGEMAN:Broadcast("StartButton")
			if not GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -1)
			else
				SCREENMAN:GetTopScreen():Finish()
			end
		end
		if params.Name == 'Up' or params.Name == 'Left' or params.Name == 'DownLeft' then
			if GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(params.PlayerNumber)
				if ind > 1 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, ind - 1 ) then
						MESSAGEMAN:Broadcast("DirectionButton")
						self:queuecommand('UpdateInternal2')
					end
				end
			end
		end
		if params.Name == 'Down' or params.Name == 'Right' or params.Name == 'DownRight' then
			if GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(params.PlayerNumber)
				if ind > 0 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, ind + 1 ) then
						MESSAGEMAN:Broadcast("DirectionButton")
						self:queuecommand('UpdateInternal2')
					end
				end
			end
		end
		if params.Name == 'Back' then
			if GAMESTATE:GetNumPlayersEnabled()==0 then
				SCREENMAN:GetTopScreen():Cancel()
			else
				MESSAGEMAN:Broadcast("BackButton")
				SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -2)
			end
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
			UpdateInternal3(self, GAMESTATE:GetMasterPlayerNumber())
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
	}
}

local PlayerFrame = function(player)
	return Def.ActorFrame {
		Name=ToEnumShortString(player) .. "Frame",
		InitCommand=function(self) self:xy(_screen.cx+(160*(player==PLAYER_1 and -1 or 1)), _screen.cy):rotationy(-90) end,
		OnCommand=function(self) self:smooth(0.35):rotationy(0) end,
		OffCommand=function(self) self:bouncebegin(0.35):zoom(0) end,

		PlayerJoinedMessageCommand=function(self,param)
			if param.Player == player then
				self:zoom(1.15):bounceend(0.175):zoom(1)
			end
		end,
		children = LoadPlayerStuff(player)
	}
end

-- load SelectProfileFrames for both
if AutoStyle=="none" or AutoStyle=="versus" then
	for i, player in ipairs({PLAYER_1, PLAYER_2}) do
		t.children[#t.children+1] = PlayerFrame(player)
	end

-- load only for the MasterPlayerNumber
else
	t.children[#t.children+1] = PlayerFrame(GAMESTATE:GetMasterPlayerNumber())
end

return t