-- burying feelings
-- between these lines of Lua
-- until overflow

local af
local current = ThemePrefs.Get("HereInTheDarkness")

local InputHandler = function(event)
	if not event or not event.button then return false end
	af:playcommand("InputEvent", event)
end

local t = Def.ActorFrame{
	InitCommand=function(self) af=self end,
	OnCommand=function(self) if current ~= 19 then SCREENMAN:GetTopScreen():AddInputCallback(InputHandler) end end,
	OffCommand=function(self) if current < 21 then ThemePrefs.Set( "HereInTheDarkness", current+1 ) end end,
}

if current > 21 then
	if SL.Global.HereInTheDarkness then
		t[#t+1] = LoadActor("./"..SL.Global.HereInTheDarkness.."/default.lua")..{
			OffCommand=function(self) SL.Global.HereInTheDarkness = nil end
		}
	else
		t[#t+1] = Def.Actor{
			OnCommand=function(self)
				local topscreen = SCREENMAN:GetTopScreen()
				topscreen:SetNextScreenName("ScreenHereInTheDarknessSelect")
				topscreen:StartTransitioningScreen("SM_GoToNextScreen")
			end
		}
	end
else
	t[#t+1] = LoadActor("./"..current.."/default.lua")
end

return t