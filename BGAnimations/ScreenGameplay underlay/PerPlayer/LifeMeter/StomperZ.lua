local player = ...
local p = ToEnumShortString(player)
local x = GetNotefieldX( player )
local under, over, full

local af = Def.ActorFrame{
	Name="LifeMeter_"..p,
	InitCommand=function(self)
		self:xy(x,0)
	end,
	HealthStateChangedMessageCommand=function(self,params)
		if(params.PlayerNumber == player) then
			if(params.HealthState == 'HealthState_Hot') then
				full:queuecommand("Hot")
			elseif params.HealthState == "HealthState_Dead" then
				full:queuecommand("Dead")
			else
				full:queuecommand("NotHot")
			end
		end
	end,
	LifeChangedMessageCommand=function(self,params)
		if(params.Player == player) then
			local life = params.LifeMeter:GetLife()

			if life >= 0.5 then
				over:playcommand("ChangeSize", {CropAmount=scale(life, 0.5,1,  1,0) })
				under:playcommand("ChangeSize", {CropAmount=0 })
			else
				over:playcommand("ChangeSize", {CropAmount=1 })
				under:playcommand("ChangeSize", {CropAmount=scale(life, 0,0.5,  1,0) })
			end
		end
	end,


	Def.ActorFrame{
		Name="Under",
		InitCommand=function(self) under = self end,

		Def.Quad{
			Name="Left",
			InitCommand=function(self)
				self:horizalign(left):vertalign(top):xy( -GetNotefieldWidth(player)/2, 40):zoomto( 50, _screen.h-40 ):diffuserightedge(0,0,0,1)
					:diffuseupperleft(color("#00c263")):diffuselowerleft(color("#00c263"))
			end,
			ChangeSizeCommand=function(self, params)
				self:finishtweening():decelerate(0.2):croptop(params.CropAmount)
			end
		},
		Def.Quad{
			Name="Right",
			InitCommand=function(self)
				self:horizalign(right):vertalign(top):xy( GetNotefieldWidth(player)/2, 40):zoomto( 50, _screen.h-40 ):diffuseleftedge(0,0,0,1)
					:diffuseupperright(color("#00c263")):diffuselowerright(color("#00c263"))
			end,
			ChangeSizeCommand=function(self, params)
				self:finishtweening():decelerate(0.2):croptop(params.CropAmount)
			end
		}
	},

	Def.ActorFrame{
		Name="Over",
		InitCommand=function(self) over = self end,

		Def.Quad{
			Name="Left",
			InitCommand=function(self)
				self:horizalign(left):vertalign(top):xy( -GetNotefieldWidth(player)/2, 40):zoomto( 50, _screen.h-40 ):diffuserightedge(0,0,0,1)
					:diffuseupperleft(color("#0073ff")):diffuselowerleft(color("#0073ff"))
			end,
			ChangeSizeCommand=function(self, params)
				self:finishtweening():decelerate(0.2):croptop(params.CropAmount)
			end
		},
		Def.Quad{
			Name="Right",
			InitCommand=function(self)
				self:horizalign(right):vertalign(top):xy( GetNotefieldWidth(player)/2, 40):zoomto( 50, _screen.h-40 ):diffuseleftedge(0,0,0,1)
					:diffuseupperright(color("#0073ff")):diffuselowerright(color("#0073ff"))
			end,
			ChangeSizeCommand=function(self, params)
				self:finishtweening():decelerate(0.2):croptop(params.CropAmount)
			end
		}
	},
	Def.ActorFrame{
		Name="Full",
		InitCommand=function(self) full = self end,

		Def.Quad{
			Name="Left",
			InitCommand=function(self)
				self:horizalign(left):vertalign(top):xy( -GetNotefieldWidth(player)/2, 40):zoomto( 50, _screen.h-40 ):diffuserightedge(0,0,0,1)
					:diffuseupperleft(color("#6517e0")):diffuselowerleft(color("#6517e0"))
			end,
			HotCommand=function(self, params)
				self:decelerate(1):diffusealpha(1)
			end,
			NotHotCommand=function(self)
				self:diffusealpha(0)
			end,
			DeadCommand=function(self)
				self:diffuseupperleft(1,0,0,0):diffuselowerleft(1,0,0,0)
					:accelerate(0.2):diffusealpha(1):decelerate(0.4):diffusealpha(0)
			end
		},
		Def.Quad{
			Name="Right",
			InitCommand=function(self)
				self:horizalign(right):vertalign(top):xy( GetNotefieldWidth(player)/2, 40):zoomto( 50, _screen.h-40 ):diffuseleftedge(0,0,0,1)
					:diffuseupperright(color("#6517e0")):diffuselowerright(color("#6517e0"))
			end,
			HotCommand=function(self, params)
				self:decelerate(1):diffusealpha(1)
			end,
			NotHotCommand=function(self)
				self:diffusealpha(0)
			end,
			DeadCommand=function(self)
				self:diffuseupperright(1,0,0,0):diffuselowerright(1,0,0,0)
					:accelerate(0.2):diffusealpha(1):decelerate(0.4):diffusealpha(0)
			end
		}
	},

}

return af