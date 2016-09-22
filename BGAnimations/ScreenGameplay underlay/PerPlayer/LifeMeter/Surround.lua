local player = ...
local p = ToEnumShortString(player)
local x = GetNotefieldX( player )
local full

local af = Def.ActorFrame{
	Name="LifeMeter_"..p,
	InitCommand=function(self)
		self:xy(x,0)
	end,
	HealthStateChangedMessageCommand=function(self,params)
		if (params.PlayerNumber == player) then
			if params.HealthState == "HealthState_Dead" then
				full:queuecommand("Dead")
			end
		end
	end,
	LifeChangedMessageCommand=function(self,params)
		if (params.Player == player) then
			local life = 1-params.LifeMeter:GetLife()
			full:playcommand("ChangeSize", {CropAmount=life })
		end
	end,

	Def.ActorFrame{
		Name="Full",
		InitCommand=function(self) full = self end,

		Def.Quad{
			Name="Left",
			InitCommand=function(self)
				self:horizalign(left):vertalign(top):xy( -GetNotefieldWidth()/2, 80):zoomto( 50, _screen.h-80 )
					:diffuserightedge(0,0,0,1):diffuseleftedge(0.666,0.666,0.666,1)
			end,
			ChangeSizeCommand=function(self, params)
				self:finishtweening():decelerate(0.2):croptop(params.CropAmount)
			end,
			DeadCommand=function(self)
				self:diffuseupperleft(1,0,0,0):diffuselowerleft(1,0,0,0):croptop(0)
					:accelerate(0.2):diffusealpha(1):decelerate(0.3):diffusealpha(0)
			end
		},
		Def.Quad{
			Name="Right",
			InitCommand=function(self)
				self:horizalign(right):vertalign(top):xy( GetNotefieldWidth()/2, 80):zoomto( 50, _screen.h-80 )
					:diffuseleftedge(0,0,0,1):diffuserightedge(0.666,0.666,0.666,1)
			end,
			ChangeSizeCommand=function(self, params)
				self:finishtweening():decelerate(0.2):croptop(params.CropAmount)
			end,
			DeadCommand=function(self)
				self:diffuseupperright(1,0,0,0):diffuselowerright(1,0,0,0):croptop(0)
					:accelerate(0.2):diffusealpha(1):decelerate(0.3):diffusealpha(0)
			end
		}
	},

}

return af