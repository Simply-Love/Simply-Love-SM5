local player = ...
local pn = ToEnumShortString(player)

local width = 16
local height = 250
local _x = _screen.cx + (player==PLAYER_1 and -1 or 1) * SL_WideScale(302, 400)
local oldlife = 0

-- if double
if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides"
-- or center1player preference is enabled and only one player is playing
or PREFSMAN:GetPreference("Center1Player") and #GAMESTATE:GetHumanPlayers() == 1 then
	_x =  _screen.cx + ((GetNotefieldWidth()/2 + 30) * (player==PLAYER_1 and -1 or 1))

-- for the highly-specific scenario where aspect ratio is ultrawide or wider
-- and both players are joined, and this player wants both a vertical lifemeter
-- and step stats, move their vertical lifemeter to the inside of the notefield
elseif GetScreenAspectRatio() > 21/9
and #GAMESTATE:GetHumanPlayers() > 1
and SL[pn].ActiveModifiers.DataVisualizations == "Step Statistics"
then
	_x = _screen.cx + (player==PLAYER_1 and -1 or 1) * 60
end

-- get SongPosition specific to this player so that
-- split BPMs are handled if there are any
local songposition = GAMESTATE:GetPlayerState(player):GetSongPosition()
local swoosh, velocity

local Update = function(self)
	if not swoosh then return end
	velocity = -(songposition:GetCurBPS() * 0.5)
	if songposition:GetFreeze() or songposition:GetDelay() then velocity = 0 end
	swoosh:texcoordvelocity(velocity, 0)
end

local meter = Def.ActorFrame{

	InitCommand=function(self)
		self:SetUpdateFunction(Update)
		    :align(0,0)
		    :y(height+10)
	end,

	-- frame
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(44, 18):diffuse(PlayerColor(player,true)):horizalign("left")
			if player==PLAYER_1 then
				self:x(_x+10)
			else
				self:x(_x-55)
			end
		end,
		HealthStateChangedMessageCommand=function(self,params)
			if params.PlayerNumber == player then
				if params.HealthState == 'HealthState_Hot' then
					self:zoomto(52, 18)
					self:accelerate(1)
					self:diffusealpha(0)
				else
					-- ~~man's~~ lifebar's not hot
					self:zoomto(44, 18):finishtweening():diffusealpha(1)
				end
			end
		end,
		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * 100
				self:finishtweening()
				self:bouncebegin(0.1):y(height/2-(life*2.5))
			end
		end,
	},
	
	-- percent
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(42, 16):diffuse(0,0,0,1):horizalign("left")
			if player==PLAYER_1 then
				self:x(_x+11)
			else
				self:x(_x-54)
			end
		end,
		HealthStateChangedMessageCommand=function(self,params)
			if params.PlayerNumber == player then
				if params.HealthState == 'HealthState_Hot' then
					self:zoomto(50, 16)
					self:accelerate(1)
					self:diffusealpha(0)
				else
					-- ~~man's~~ lifebar's not hot
					self:zoomto(42, 16):finishtweening():diffusealpha(1)
				end
			end
		end,
		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * 100
				self:finishtweening()
				self:bouncebegin(0.1):y(height/2-(life*2.5))
			end
		end,
	},
	Def.BitmapText {
		Font="Common Normal",
		InitCommand=function(self)
			self:diffuse(PlayerColor(player,true)):horizalign("left")
			if player==PLAYER_1 then
				self:x(_x+12)
			else
				self:x(_x-53)
			end
		end,
		HealthStateChangedMessageCommand=function(self,params)
			if params.PlayerNumber == player then
				if params.HealthState == 'HealthState_Hot' then
					self:accelerate(1):diffusealpha(0)
				else
					-- ~~man's~~ lifebar's not hot
					self:finishtweening():diffusealpha(1)
				end
			end
		end,
		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * 100
				self:finishtweening()
				self:bouncebegin(0.1):settext(("%.1f%%"):format(life)):y(height/2-(life*2.5))
			end
		end,
	},
	Def.Quad{ InitCommand=function(self) self:zoomto(width+2, height+2):x(_x) end },
	Def.Quad{ InitCommand=function(self) self:zoomto(width, height):x(_x):diffuse(0,0,0,1) end },

	Def.Quad{
		Name="MeterFill",
		InitCommand=function(self) self:zoomto(width,0):diffuse(PlayerColor(player,true)):align(0,1) end,
		OnCommand=function(self) self:xy( _x - width/2, height/2) end,
		
		-- check whether the player's LifeMeter is "Hot"
		-- in LifeMeterBar.cpp, the engine says a LifeMeter is Hot if the current
		-- LifePercentage is greater than or equal to the HOT_VALUE, which is
		-- defined in Metrics.ini under [LifeMeterBar] like HotValue=1.0
		HealthStateChangedMessageCommand=function(self,params)
			if params.PlayerNumber == player then
				if params.HealthState == 'HealthState_Hot' then
					if SL[pn].ActiveModifiers.RainbowMax then
						self:rainbow()
					else
						self:diffuse(1,1,1,1)
					end
				else
					-- ~~man's~~ lifebar's not hot
					if SL[pn].ActiveModifiers.RainbowMax then
						self:stopeffect()
					elseif not SL[pn].ActiveModifiers.ResponsiveColors then
						self:diffuse( PlayerColor(player,true) )
					end
				end
			end
		end,

		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * height
				local absLife = params.LifeMeter:GetLife()
				if SL[pn].ActiveModifiers.ResponsiveColors then
					if absLife >= 0.9 then
						self:diffuse(0, 1, (absLife - 0.9) * 10, 1)
					elseif absLife >= 0.5 then
						self:diffuse((0.9 - absLife) * 10 / 4, 1, 0, 1)
					else
						self:diffuse(1, (absLife - 0.2) * 10 / 3, 0, 1)
					end
				end
				self:finishtweening()
				self:bouncebegin(0.1):zoomy( life )
			end
		end,
	},

	-- a simple scrolling gradient texture applied on top of MeterFill
	LoadActor("swoosh.png")..{
		Name="MeterSwoosh",
		InitCommand=function(self)
			swoosh = self

			self:diffusealpha(0.2)
				 :horizalign( left )
				 :rotationz(-90)
				 :xy(_x, height/2)
		end,
		OnCommand=function(self)
			self:customtexturerect(0,0,1,1)
			--texcoordvelocity is handled by the Update function below
		end,
		LifeChangedMessageCommand=function(self,params)
			if(params.Player == player) then
				local life = params.LifeMeter:GetLife() * height
				local absLife = params.LifeMeter:GetLife()
				
				if (life > oldlife) or absLife == 1 then
					self:accelerate(0.5):diffusealpha(1)
				else
					self:accelerate(0.5):diffusealpha(0.2)
				end
				
				oldlife = life
				
				self:finishtweening()
				self:bouncebegin(0.1):zoomto( life, width )
			end
		end
	}
}

return meter

-- copyright 2008-2012 AJ Kelly/freem.
-- do not use this code in your own themes without my permission.