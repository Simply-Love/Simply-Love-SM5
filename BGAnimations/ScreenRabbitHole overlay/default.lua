local af
local current = ThemePrefs.Get("RabbitHole")

local InputHandler = function(event)
	if not event or not event.button then return false end
	af:playcommand("InputEvent", event)
end

local t = Def.ActorFrame{
	InitCommand=function(self) af=self end,
	OnCommand=function(self) if current ~= 19 then SCREENMAN:GetTopScreen():AddInputCallback(InputHandler) end end,
	OffCommand=function(self) if current < 21 then ThemePrefs.Set( "RabbitHole", current+1 ) end end,
}

if current > 21 then
	if SL.Global.RabbitHole then
		t[#t+1] = LoadActor("./"..SL.Global.RabbitHole.."/default.lua")..{
			OffCommand=function(self) SL.Global.RabbitHole = nil end
		}
	else
		t[#t+1] = Def.Actor{
			OnCommand=function(self)
				local topscreen = SCREENMAN:GetTopScreen()
				topscreen:SetNextScreenName("ScreenRabbitHoleSelect")
				topscreen:StartTransitioningScreen("SM_GoToNextScreen")
			end
		}
	end
else
	t[#t+1] = LoadActor("./"..current.."/default.lua")
end

return t