local pages = LoadActor("./Thanks.lua")
local bgm_bpm = 100

local af = Def.ActorFrame{
	OnCommand=function(self)
		self:queuecommand("ShowPage1")
		SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./InputHandler.lua", {self, #pages}) )
	end
}

-- header text
af[#af+1] = Def.BitmapText{
	Name="PageNumber",
	Font="_wendy small",
	InitCommand=function(self) self:diffusealpha(0):zoom( WideScale(0.5,0.6) ):xy( _screen.cx, 15 ) end,
	OnCommand=function(self) self:sleep(0.1):decelerate(0.33):diffusealpha(1):playcommand("Update",{page=1}) end,
	OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
	UpdateCommand=function(self, params) self:sleep(0.5):settext(THEME:GetString("ScreenEvaluationSummary","Page").." "..params.page.."/"..#pages ) end
}

if IsUsingWideScreen() then
	-- left arrow
	af[#af+1] = LoadActor("arrow (doubleres).png")..{
		Name="LeftArrow",
		InitCommand=function(self)
			self:zoom(0.35):xy((22*PREFSMAN:GetPreference("DisplayAspectRatio")), (_screen.h-32)/2 + self:GetHeight()*self:GetZoom() + 6 )
				:rotationz(180):visible(false)
			if ThemePrefs.Get("RainbowMode") then self:diffuse(0,0,0,1)	end
		end,
		OnCommand=function(self) self:pulse():effectmagnitude(1.1,1,1):effectperiod(60/bgm_bpm) end
	}
	-- right arrow
	af[#af+1] = LoadActor("arrow (doubleres).png")..{
		Name="RightArrow",
		InitCommand=function(self)
			self:zoom(0.35):xy(_screen.w-(22*PREFSMAN:GetPreference("DisplayAspectRatio")), (_screen.h-32)/2 + self:GetHeight()*self:GetZoom() + 6 )
			if ThemePrefs.Get("RainbowMode") then self:diffuse(0,0,0,1)	end
		end,
		OnCommand=function(self) self:pulse():effectmagnitude(1.1,1,1):effectperiod(60/bgm_bpm) end
	}
end


for i=1,#pages do

	af[#af+1] = Def.ActorFrame{
		Name="Page"..i,
		InitCommand=function(self) self:visible(false):Center() end,
		HideCommand=function(self) self:visible(false) end,
		["ShowPage"..i.."Command"]=function(self) self:visible(true) end

	}..LoadActor("Page.lua", pages[i])

end

return af