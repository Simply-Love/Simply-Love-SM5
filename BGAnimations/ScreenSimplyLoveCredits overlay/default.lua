local pages = LoadActor("./Thanks.lua")

local af = Def.ActorFrame{
	InitCommand=function(self) af = self end,
	OnCommand=function(self)
		self:queuecommand("ShowPage1")
		SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./InputHandler.lua", {self, #pages}) )
	end,
	OffCommand=function(self)
		if ThemePrefs.Get("RabbitHole")==0 then
			ThemePrefs.Set("RabbitHole", 1)
			ThemePrefs.Save()
		end
	end
}

-- header text
af[#af+1] = Def.BitmapText{
	Font="_wendy small",
	InitCommand=cmd(diffusealpha,0; zoom, WideScale(0.5,0.6); xy, _screen.cx, 15 ),
	OnCommand=function(self) self:sleep(0.1):decelerate(0.33):diffusealpha(1):playcommand("Update",{page=1}) end,
	OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
	UpdateCommand=function(self, params) self:sleep(0.5):settext(THEME:GetString("ScreenEvaluationSummary","Page").." "..params.page.."/"..#pages ) end
}

for i=1,#pages do

	af[#af+1] = Def.ActorFrame{
		Name="Page"..i,
		InitCommand=function(self) self:visible(false):Center() end,
		HideCommand=function(self) self:visible(false) end,
		["ShowPage"..i.."Command"]=function(self) self:visible(true) end

	}..LoadActor("Page.lua", pages[i])

end

return af