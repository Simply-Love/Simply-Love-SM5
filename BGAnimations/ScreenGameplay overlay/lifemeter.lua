-- life meter.
local Player = ...;
assert( Player );

local meterBaseLength = SCREEN_CENTER_X/2;
local meterFillLength = meterBaseLength-32;
local meterFillOffset = WideScale(96, 122.75);
local meterFillHeight = 20;

local newBPS;
local oldBPS;

local dpMeterWidth = 160;

-- only used for oni mode:
smLifeMeter = nil;
local oldHealth = nil;

local NumPlayers = GAMESTATE:GetNumPlayersEnabled();
local NumSides = GAMESTATE:GetNumSidesJoined();
local IsDoubles = (NumPlayers == 1 and NumSides == 2);



local meter = Def.ActorFrame{
	BeginCommand=function(self)
		if IsDoubles and Player ~= GAMESTATE:GetMasterPlayerNumber() then
			self:visible(false);
			return;
		else
			

			if GAMESTATE:IsPlayerEnabled(Player) then
				self:visible(true);
				-- oni
				if GAMESTATE:IsCourseMode()
					and GAMESTATE:GetPlayMode() == 'PlayMode_Oni' then
					smLifeMeter = SCREENMAN:GetTopScreen():GetLifeMeter(Player);
				end;
			elseif GAMESTATE:IsDemonstration() then
				-- don't hook up oni on demonstration
				self:visible(true);
			end;
		end;
	end;
	OnCommand=cmd(runcommandsonleaves,cmd(addy,-40;linear,0.2;addy,40));
	--OffCommand=cmd(runcommandsonleaves,cmd(linear,1;diffusealpha,0));

	-- frame
	Border(meterBaseLength-28, 24, 2)..{
		OnCommand=function(self)
			if GAMESTATE:IsPlayerEnabled(Player) then
				self:visible(true);
				-- oni
				if GAMESTATE:IsCourseMode()
					and GAMESTATE:GetPlayMode() == 'PlayMode_Oni' then
					smLifeMeter = SCREENMAN:GetTopScreen():GetLifeMeter(Player);
				end;
			else
				self:visible(false);
			end;
		end;
	};

	-- // start meter proper //
	Def.Quad{
		Name="MeterFill";
		InitCommand=cmd(zoomto,0,meterFillHeight;diffuse,PlayerColor(Player););
		BeginCommand=function(self)
			-- don't bother.
			if not GAMESTATE:IsPlayerEnabled(Player) then
				self:visible(false);
				return;
			end;
	
			self:horizalign(left);
			self:addx(-(SCREEN_WIDTH/4)+meterFillOffset);
	
		end;
	
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
	
		-- check life (LifeMeterBattery)
		BatteryLifeChangedMessageCommand=function(self,params)
			local life = params.CurrentHealth * meterFillLength;
			self:finishtweening();
			self:accelerate(0.05);
			self:zoomx( life );
		end;
	};

};



local function Update(self)

	local hot = self:GetChild("MeterHotOverlay");

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
