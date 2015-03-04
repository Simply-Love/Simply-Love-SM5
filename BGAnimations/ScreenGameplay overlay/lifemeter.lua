-- life meter.
local Player = ...;
assert( Player );

local meterFillLength = 136;
local meterFillHeight = 18;
local meterXOffset = _screen.cx;

if Player == PLAYER_1 then
	meterXOffset = meterXOffset - WideScale(238, 288);
elseif Player == PLAYER_2 then
	meterXOffset = meterXOffset + WideScale(238, 288)
end


local newBPS, oldBPS;

local NumPlayers = GAMESTATE:GetNumPlayersEnabled();
local NumSides = GAMESTATE:GetNumSidesJoined();
local IsDoubles = (NumPlayers == 1 and NumSides == 2);



local meter = Def.ActorFrame{
	
	InitCommand=cmd(horizalign, left;);
	
	BeginCommand=function(self)
		if IsDoubles and Player ~= GAMESTATE:GetMasterPlayerNumber() then
			self:visible(false);
			return;
		else
			if not SL[ToEnumShortString(Player)].ActiveModifiers.HideLifebar and
					GAMESTATE:IsPlayerEnabled(Player) then
				self:visible(true);
			end;
		end;
	end;
	OnCommand=cmd(y, 30);

	-- frame
	Border(meterFillLength+4, meterFillHeight+4, 2)..{
		OnCommand=function(self)
			self:x(meterXOffset);
			if not SL[ToEnumShortString(Player)].ActiveModifiers.HideLifebar and
					GAMESTATE:IsPlayerEnabled(Player) then
				self:visible(true);
			else
				self:visible(false);
			end;
		end;
	};

	-- // start meter proper //
	Def.Quad{
		Name="MeterFill";
		InitCommand=cmd(zoomto,0,meterFillHeight;diffuse,PlayerColor(Player); horizalign, left;);
		BeginCommand=function(self)
			-- don't bother.
			if SL[ToEnumShortString(Player)].ActiveModifiers.HideLifebar or
					not GAMESTATE:IsPlayerEnabled(Player) then
				self:visible(false);
				return;
			end;
		end;
		OnCommand=cmd(x, meterXOffset - meterFillLength/2);
		-- check state of mind
		HealthStateChangedMessageCommand=function(self,params)
			if(params.PlayerNumber == Player) then
				if(params.HealthState == 'HealthState_Hot') then
					self:diffuse(color("1,1,1,1"));
				else
					self:diffuse(PlayerColor(Player));
				end;
			end;
		end;
	
		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if(params.Player == Player) then
				local life = params.LifeMeter:GetLife() * (meterFillLength);
				self:finishtweening();
				self:bouncebegin(0.1);
				self:zoomx( life );
			end;
		end;
	};
	
	LoadActor("hot.png")..{
		Name="MeterHot";
		InitCommand=cmd(zoomto,meterFillLength,meterFillHeight; diffusealpha,0.2; horizalign, left; );
		OnCommand=function(self)
			self:x(meterXOffset - meterFillLength/2);
			
			if not SL[ToEnumShortString(Player)].ActiveModifiers.HideLifebar and
					GAMESTATE:IsPlayerEnabled(Player) then
				self:customtexturerect(0,0,1,1);
				--texcoordvelocity is handled by the Update function below
			else
				self:visible(false);
			end
		end;
		HealthStateChangedMessageCommand=function(self,params)
			if(params.PlayerNumber == Player) then
				if(params.HealthState == 'HealthState_Hot') then
					self:diffusealpha(1);
				else
					self:diffusealpha(0.2);
				end;
			end;
		end;
		LifeChangedMessageCommand=function(self,params)
			if(params.Player == Player) then
				local life = params.LifeMeter:GetLife() * (meterFillLength);
				self:finishtweening();
				self:bouncebegin(0.1);
				self:zoomto( life, meterFillHeight );
			end;
		end;
	};
};



local function Update(self)

	local hot = self:GetChild("MeterHot");

	newBPS = GAMESTATE:GetSongBPS();
	local move = (newBPS*-1)/2;
	if GAMESTATE:GetSongFreeze() then move = 0; end;
	if hot then hot:texcoordvelocity(move,0); end;

	oldBPS = newBPS;
end;

meter.InitCommand=cmd(SetUpdateFunction,Update)

return meter;

-- copyright 2008-2012 AJ Kelly/freem.
-- do not use this code in your own themes without my permission.
