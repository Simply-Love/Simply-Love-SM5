local Player = ...
local style = GAMESTATE:GetCurrentStyle()
local styleType = style:GetStyleType()
local IsPlayingDouble = (styleType == 'StyleType_OnePlayerTwoSides' or styleType == 'StyleType_TwoPlayersSharedSides')

-- initialize each stage at a HealthState of "alive"
local prevHealth = "HealthState_Alive"

local danger = Def.Quad{
	Name="Danger" .. ToEnumShortString(Player),
	InitCommand=function(self)
		self:visible(not SL[ToEnumShortString(Player)].ActiveModifiers.HideLifebar)
		self:diffusealpha(0)

		if IsPlayingDouble or PREFSMAN:GetPreference("Center1Player") and GAMESTATE:GetNumSidesJoined() == 1 then
			self:stretchto(0,0,_screen.w,_screen.h)
		elseif not IsPlayingDouble and Player == PLAYER_1 then
			self:faderight(0.1); self:stretchto(0,0,_screen.cx,_screen.h)
		elseif not IsPlayingDouble and Player == PLAYER_2 then
			self:fadeleft(0.1); self:stretchto(_screen.cx,0,_screen.w,_screen.h)
		end
	end,
	HealthStateChangedMessageCommand=function(self, param)
		if param.PlayerNumber == Player then
			if param.HealthState == "HealthState_Danger" then
				self:playcommand("Danger")
				prevHealth = "HealthState_Danger"

			elseif param.HealthState == "HealthState_Dead" then
				self:playcommand("Dead")

			else
				if prevHealth == "HealthState_Danger" then
					self:playcommand("OutOfDanger")
				else
					self:playcommand("Hide")
				end
				prevHealth = "HealthState_Alive"
			end
		end
	end,
	DangerCommand=cmd(linear,0.3; diffusealpha,0.7; diffuseshift; effectcolor1,color("1,0,0.24,0.3"); effectcolor2,color("1,0,0,0.8")),
	DeadCommand=cmd(diffusealpha,0; stopeffect; stoptweening; diffuse,color("1,0,0"); linear,0.3; diffusealpha,0.8; linear,0.3; diffusealpha,0),
	OutOfDangerCommand=cmd(diffusealpha,0; stopeffect; stoptweening; diffuse,color("0,1,0"); linear,0.3; diffusealpha,0.8; linear,0.3; diffusealpha,0),
	HideCommand=cmd(stopeffect; stoptweening; linear,0.3; diffusealpha,0)
}

return danger