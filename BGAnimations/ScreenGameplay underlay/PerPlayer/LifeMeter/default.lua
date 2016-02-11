
-- life meter.
local Player = ...

local meterFillLength = 136
local meterFillHeight = 18
local meterXOffset

if Player == PLAYER_1 then
	meterXOffset = _screen.cx - WideScale(238, 288)
elseif Player == PLAYER_2 then
	meterXOffset = _screen.cx + WideScale(238, 288)
end


local newBPS, oldBPS

local NumPlayers = GAMESTATE:GetNumPlayersEnabled()
local NumSides = GAMESTATE:GetNumSidesJoined();
local IsDoubles = (NumPlayers == 1 and NumSides == 2);



local meter = Def.ActorFrame{

	InitCommand=cmd(horizalign, left),
	BeginCommand=function(self)
		if SL[ToEnumShortString(Player)].ActiveModifiers.HideLifebar then
			self:visible(false)
		end
	end,
	OnCommand=cmd(y, 20),

	-- frame
	Border(meterFillLength+4, meterFillHeight+4, 2)..{
		OnCommand=function(self)
			self:x(meterXOffset)
		end
	},

	-- // start meter proper //
	Def.Quad{
		Name="MeterFill";
		InitCommand=cmd(zoomto,0,meterFillHeight; diffuse,PlayerColor(Player); horizalign, left),
		OnCommand=cmd(x, meterXOffset - meterFillLength/2),

		-- check state of mind
		HealthStateChangedMessageCommand=function(self,params)
			if(params.PlayerNumber == Player) then
				if(params.HealthState == 'HealthState_Hot') then
					self:diffuse(color("1,1,1,1"))
				else
					self:diffuse(PlayerColor(Player))
				end
			end
		end,

		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if(params.Player == Player) then
				local life = params.LifeMeter:GetLife() * (meterFillLength)
				self:finishtweening()
				self:bouncebegin(0.1)
				self:zoomx( life )
			end
		end,
	},

	LoadActor("hot.png")..{
		Name="MeterHot",
		InitCommand=cmd(zoomto,meterFillLength,meterFillHeight; diffusealpha,0.2; horizalign, left; ),
		OnCommand=function(self)
			self:x(meterXOffset - meterFillLength/2);
			self:customtexturerect(0,0,1,1);
			--texcoordvelocity is handled by the Update function below
		end,
		HealthStateChangedMessageCommand=function(self,params)
			if(params.PlayerNumber == Player) then
				if(params.HealthState == 'HealthState_Hot') then
					self:diffusealpha(1)
				else
					self:diffusealpha(0.2)
				end
			end
		end,
		LifeChangedMessageCommand=function(self,params)
			if(params.Player == Player) then
				local life = params.LifeMeter:GetLife() * (meterFillLength)
				self:finishtweening()
				self:bouncebegin(0.1)
				self:zoomto( life, meterFillHeight )
			end
		end
	}
}



local function Update(self)

	local hot = self:GetChild("MeterHot")

	newBPS = GAMESTATE:GetSongBPS()
	local move = (newBPS*-1)/2
	if GAMESTATE:GetSongFreeze() then move = 0 end
	if hot then hot:texcoordvelocity(move,0) end

	oldBPS = newBPS
end

meter.InitCommand=cmd(SetUpdateFunction,Update)

return meter

-- copyright 2008-2012 AJ Kelly/freem.
-- do not use this code in your own themes without my permission.