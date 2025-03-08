local player = ...
local pn = ToEnumShortString(player)

local width = 16
local height = 250
local _x = _screen.cx + (player==PLAYER_1 and -1 or 1) * SL_WideScale(302, 400)

-- if double
if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides"
-- or center1player preference is enabled and only one player is playing
or PREFSMAN:GetPreference("Center1Player") and #GAMESTATE:GetHumanPlayers() == 1 then
	_x =  _screen.cx + ((GetNotefieldWidth()/2 + 10) * (player==PLAYER_1 and -1 or 1))

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
	Def.Quad{ InitCommand=function(self) self:zoomto(width+2, height+2):x(_x) end },
	Def.Quad{ InitCommand=function(self) self:zoomto(width, height):x(_x):diffuse(0,0,0,1) end },

	Def.Quad{
		Name="MeterFill",
		InitCommand=function(self) self:zoomto(width,0):diffuse(PlayerColor(player,true)):align(0,1) end,
		OnCommand=function(self) self:xy( _x - width/2, height/2) end,

		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * height
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
				self:finishtweening()
				self:bouncebegin(0.1):zoomto( life, width )
			end
		end
	}
}

return meter

-- copyright 2008-2012 AJ Kelly/freem.
-- do not use this code in your own themes without my permission.