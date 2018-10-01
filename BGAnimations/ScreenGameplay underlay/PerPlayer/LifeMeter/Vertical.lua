local player = ...

local width = 16
local height = 250
local _x = width * WideScale(1, 3.5)
if PREFSMAN:GetPreference("Center1Player") and #GAMESTATE:GetHumanPlayers() == 1 then _x = width * WideScale(10,16) end
if player == PLAYER_2 then _x = _screen.w - _x end


local swoosh, move

local Update = function(self)
	move = -GAMESTATE:GetSongBPS()/2
	if GAMESTATE:GetSongFreeze() then move = 0 end
	if swoosh then swoosh:texcoordvelocity(move, 0) end
end

local meter = Def.ActorFrame{

	InitCommand=function(self)
		self:SetUpdateFunction(Update)
			:align(0,0)
			:y(height+10)
	end,

	-- frame
	Def.Quad{
		InitCommand=function(self) self:zoomto(width+2, height+2):x(_x) end
	},

	Def.Quad{
		InitCommand=function(self) self:zoomto(width, height):x(_x):diffuse(0,0,0,1) end
	},

	-- // start meter proper //
	Def.Quad{
		Name="MeterFill";
		InitCommand=function(self) self:zoomto(width,0):diffuse(PlayerColor(player)):align(0,1) end,
		OnCommand=function(self) self:xy( _x - width/2, height/2) end,

		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if(params.Player == player) then
				local life = params.LifeMeter:GetLife() * height
				self:finishtweening()
				self:bouncebegin(0.1)
				self:zoomy( life )
			end
		end,
	},

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
			self:customtexturerect(0,0,1,1);
			--texcoordvelocity is handled by the Update function below
		end,
		LifeChangedMessageCommand=function(self,params)
			if(params.Player == player) then
				local life = params.LifeMeter:GetLife() * height
				self:finishtweening()
				self:bouncebegin(0.1)
				self:zoomto( life, width )
			end
		end
	}
}

return meter

-- copyright 2008-2012 AJ Kelly/freem.
-- do not use this code in your own themes without my permission.