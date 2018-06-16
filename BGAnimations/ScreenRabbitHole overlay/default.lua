local af
local count = 17

local InputHandler = function(event)
	if count ~= 17 and (not event.PlayerNumber or not event.button) then return false end
	af:playcommand("InputEvent", event)
end

return Def.ActorFrame{
	InitCommand=function(self) af=self end,
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(InputHandler) end,
	OffCommand=function(self) ThemePrefs.Set( "RabbitHole", ThemePrefs.Get("RabbitHole")+1 ) end,
	-- LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/"..(ThemePrefs.Get("RabbitHole")%count+1).."/default.lua"))
	LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/"..count.."/default.lua"))
}