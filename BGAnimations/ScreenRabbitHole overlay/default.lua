local af
local current = ThemePrefs.Get("RabbitHole")

local InputHandler = function(event)
	if not event or not event.button then return false end
	af:playcommand("InputEvent", event)
end

local t = Def.ActorFrame{
	InitCommand=function(self) af=self end,
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(InputHandler) end,
	OffCommand=function(self) if current < 20 then ThemePrefs.Set( "RabbitHole", current+1 ) end end,
}

if SL.Global.RabbitHole then
	t[#t+1] = LoadActor("./"..SL.Global.RabbitHole.."/default.lua")..{
		OffCommand=function(self) SL.Global.RabbitHole = nil end
	}
else
	t[#t+1] = LoadActor("./"..current.."/default.lua")
end

return t