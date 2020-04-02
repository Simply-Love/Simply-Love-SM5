-- there aren't meaningful life delta values in Casual
-- so these danger/fail flashes should never be possible there
if SL.Global.GameMode == "Casual" then return end

-- ------------------------------------------------------------------

local player = ...

-- Don't bother loading any code for Danger if FailType for this player is FailType_Off
local failtype = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):FailSetting()
if failtype == "FailType_Off" then return end

-- ------------------------------------------------------------------

local pn = ToEnumShortString(player)

local style = GAMESTATE:GetCurrentStyle()
local styleType = style:GetStyleType()
local IsPlayingDouble = (styleType == 'StyleType_OnePlayerTwoSides' or styleType == 'StyleType_TwoPlayersSharedSides')

-- Is there any reason to have this use GAMESTATE:GetPlayerState(player):GetHealthState() ?
-- I guess I should look into it eventually. For now, assuming that the player has started
-- this stage with a HealthState of "Alive" works okay.
local prevHealth = "HealthState_Alive"

local danger = Def.Quad{
	Name="Danger" .. pn,
	InitCommand=function(self)
		self:visible(not SL[pn].ActiveModifiers.HideLifebar)
		self:diffusealpha(0)

		if IsPlayingDouble or PREFSMAN:GetPreference("Center1Player") and GAMESTATE:GetNumSidesJoined() == 1 then
			self:stretchto(0,0,_screen.w,_screen.h)
		elseif not IsPlayingDouble and player == PLAYER_1 then
			self:faderight(0.1):stretchto(0,0,_screen.cx,_screen.h)
		elseif not IsPlayingDouble and player == PLAYER_2 then
			self:fadeleft(0.1):stretchto(_screen.cx,0,_screen.w,_screen.h)
		end
	end,
	DangerCommand=function(self) self:linear(0.3):diffusealpha(0.7):diffuseshift():effectcolor1(1, 0, 0.24, 0.1):effectcolor2(1, 0, 0, 0.35) end,
	DeadCommand=function(self) self:diffusealpha(0):stopeffect():stoptweening():diffuse(1,0,0,1):linear(0.3):diffusealpha(0.8):linear(0.3):diffusealpha(0) end,
	OutOfDangerCommand=function(self) self:diffusealpha(0):stopeffect():stoptweening():diffuse(0,1,0,1):linear(0.3):diffusealpha(0.8):linear(0.3):diffusealpha(0) end,
	HideCommand=function(self) self:stopeffect():stoptweening():linear(0.3):diffusealpha(0) end
}

-- if the player has HideDanger enabled, we only want to flash the red Quad if they fail
if SL[pn].ActiveModifiers.HideDanger then

	danger.HealthStateChangedMessageCommand=function(self, param)
		if param.PlayerNumber == player and param.HealthState == "HealthState_Dead" then
			self:playcommand("Dead")
		end
	end

else
	danger.HealthStateChangedMessageCommand=function(self, param)
		if param.PlayerNumber == player then
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
	end
end

return danger