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
	local t = Def.ActorFrame {
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardBackground") ) .. {
			InitCommand=cmd(diffuse,cColor);
		};
		LoadActor( THEME:GetPathG("ScreenSelectProfile","CardFrame") );
	};
	return t
end


function LoadPlayerStuff(Player)
	local t = {}

	local pn = (Player == PLAYER_1) and 1 or 2


	t[#t+1] = Def.ActorFrame {
		Name = 'JoinFrame',
		LoadCard(Color.Black),

		LoadFont("_miso") .. {
			Text="Press &START; to join.",
			OnCommand=cmd(diffuseshift;effectcolor1,Color('White');effectcolor2,color("0.5,0.5,0.5")),
		},
	}

	t[#t+1] = Def.ActorFrame {
		Name='BigFrame',
		LoadCard(PlayerColor(Player))
	}

	t[#t+1] = Def.ActorFrame {
		Name = 'SmallFrame',
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

	t[#t+1] = Def.ActorFrame {
		Name="EffectFrame"
	}

	t[#t+1] = LoadFont("_miso") .. {
		Name='SelectedProfileText',
		InitCommand=cmd(y,160;)
	}

	return t;
end;

function UpdateInternal3(self, Player)
	local pn = (Player == PLAYER_1) and 1 or 2;
	local frame = self:GetChild(string.format('P%uFrame', pn));
	local scroller = frame:GetChild('Scroller');
	local seltext = frame:GetChild('SelectedProfileText');
	local joinframe = frame:GetChild('JoinFrame');
	local smallframe = frame:GetChild('SmallFrame');
	local bigframe = frame:GetChild('BigFrame');

	if GAMESTATE:IsHumanPlayer(Player) then
		frame:visible(true);
		if MEMCARDMAN:GetCardState(Player) == 'MemoryCardState_none' then
			--using profile if any
			joinframe:visible(false);
			smallframe:visible(true);
			bigframe:visible(true);
			seltext:visible(true);
			scroller:visible(true);
			local ind = SCREENMAN:GetTopScreen():GetProfileIndex(Player);
			if ind > 0 then
				scroller:SetDestinationItem(ind-1);
				seltext:settext(PROFILEMAN:GetLocalProfileFromIndex(ind-1):GetDisplayName());
			else
				if SCREENMAN:GetTopScreen():SetProfileIndex(Player, 1) then
					scroller:SetDestinationItem(0);
					self:queuecommand('UpdateInternal2');
				else
					joinframe:visible(true);
					smallframe:visible(false);
					bigframe:visible(false);
					scroller:visible(false);
					seltext:settext('No profile');
				end;
			end;
		else
			--using card
			smallframe:visible(false);
			scroller:visible(false);
			seltext:settext('CARD');
			SCREENMAN:GetTopScreen():SetProfileIndex(Player, 0);
		end;
	else
		joinframe:visible(true);
		scroller:visible(false);
		seltext:visible(false);
		smallframe:visible(false);
		bigframe:visible(false);
	end;
end;

local t = Def.ActorFrame {

	StorageDevicesChangedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	CodeMessageCommand = function(self, params)
		if params.Name == 'Start' or params.Name == 'Center' then
			MESSAGEMAN:Broadcast("StartButton");
			if not GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -1);
			else
				SCREENMAN:GetTopScreen():Finish();
			end;
		end;
		if params.Name == 'Up' or params.Name == 'Left' or params.Name == 'DownLeft' then
			if GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(params.PlayerNumber);
				if ind > 1 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, ind - 1 ) then
						MESSAGEMAN:Broadcast("DirectionButton");
						self:queuecommand('UpdateInternal2');
					end;
				end;
			end;
		end;
		if params.Name == 'Down' or params.Name == 'Right' or params.Name == 'DownRight' then
			if GAMESTATE:IsHumanPlayer(params.PlayerNumber) then
				local ind = SCREENMAN:GetTopScreen():GetProfileIndex(params.PlayerNumber);
				if ind > 0 then
					if SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, ind + 1 ) then
						MESSAGEMAN:Broadcast("DirectionButton");
						self:queuecommand('UpdateInternal2');
					end;
				end;
			end;
		end;
		if params.Name == 'Back' then
			if GAMESTATE:GetNumPlayersEnabled()==0 then
				SCREENMAN:GetTopScreen():Cancel();
			else
				MESSAGEMAN:Broadcast("BackButton");
				SCREENMAN:GetTopScreen():SetProfileIndex(params.PlayerNumber, -2);
			end;
		end;
	end;

	PlayerJoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	PlayerUnjoinedMessageCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	OnCommand=function(self, params)
		self:queuecommand('UpdateInternal2');
	end;

	UpdateInternal2Command=function(self)
		UpdateInternal3(self, PLAYER_1);
		UpdateInternal3(self, PLAYER_2);
	end;

	children = {
		Def.ActorFrame {
			Name = 'P1Frame';
			InitCommand=cmd(x,SCREEN_CENTER_X-160;y,SCREEN_CENTER_Y);
			OnCommand=cmd(zoom,0;bounceend,0.35;zoom,1);
			OffCommand=cmd(bouncebegin,0.35;zoom,0);
			PlayerJoinedMessageCommand=function(self,param)
				if param.Player == PLAYER_1 then
					(cmd(;zoom,1.15;bounceend,0.175;zoom,1.0;))(self);
				end;
			end;
			children = LoadPlayerStuff(PLAYER_1);
		};
		Def.ActorFrame {
			Name = 'P2Frame';
			InitCommand=cmd(x,SCREEN_CENTER_X+160;y,SCREEN_CENTER_Y);
			OnCommand=cmd(zoom,0;bounceend,0.35;zoom,1);
			OffCommand=cmd(bouncebegin,0.35;zoom,0);
			PlayerJoinedMessageCommand=function(self,param)
				if param.Player == PLAYER_2 then
					(cmd(zoom,1.15;bounceend,0.175;zoom,1.0;))(self);
				end;
			end;
			children = LoadPlayerStuff(PLAYER_2);
		};
		-- sounds
		LoadActor( THEME:GetPathS("Common","start") )..{
			StartButtonMessageCommand=cmd(play);
		};
		LoadActor( THEME:GetPathS("ScreenSelectMusic","select down") )..{
			BackButtonMessageCommand=cmd(play);
		};
		LoadActor( THEME:GetPathS("ScreenSelectMaster","change") )..{
			DirectionButtonMessageCommand=cmd(play);
		};
	};
}

return t