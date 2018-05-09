-- quietly turning
local haiku = {
	"here in the darkness\nthat knows no end, the earth turns,\nquiet like our hearts",
	"forever pressing\nforward through vast, barren space\nwith us aboard it",
	"hoping that one day\nall the turning will make sense\nin getting us here"
}
local naps = { 4, 13, 22 }

local af = Def.ActorFrame{}
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
end


af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/2/quietly-turning.ogg"),
	OnCommand=function(self) self:play() end
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/2/earth.png"),
	InitCommand=function(self) self:halign(0):valign(1):xy(0,_screen.h):zoom(0.5):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(1):smooth(2):diffusealpha(1) end
}

for i=1,#haiku do
	af[#af+1] = Def.BitmapText{
		Font="_miso",
		Text=haiku[i],
		InitCommand=function(self) self:halign(0):valign(0):xy((_screen.cx-100) + i*60, 25+(i-1)*80):zoom(0.85):diffusealpha(0) end,
		OnCommand=function(self) self:sleep( naps[i] ):smooth(3):diffusealpha(1) end
	}
end

return af