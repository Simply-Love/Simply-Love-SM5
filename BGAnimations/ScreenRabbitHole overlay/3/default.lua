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
		self:smooth(1):diffuse(0,0,0,1):queuecommand("NextScreen")
	end
end
af.NextScreenCommand=function(self)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end


af[#af+1] = LoadActor("./quietly-turning.ogg")..{
	OnCommand=function(self) self:play() end
}

af[#af+1] = LoadActor("./earth.png")..{
	InitCommand=function(self) self:halign(0):valign(1):xy(0,_screen.h):zoom(0.5):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(1):smooth(2):diffusealpha(1) end
}

for i=1,#haiku do
	af[#af+1] = Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text=haiku[i],
		InitCommand=function(self) self:halign(0):valign(0):xy((_screen.cx-100) + i*60, 25+(i-1)*80):zoom(0.85):diffusealpha(0) end,
		OnCommand=function(self) self:sleep( naps[i] ):smooth(3):diffusealpha(1) end
	}
end

return af