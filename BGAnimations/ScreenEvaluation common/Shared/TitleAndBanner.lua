local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualStyle")
local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()

local banner = {
	directory = (FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")),
	width = 418,
	zoom = 0.7,
}

-- the Quad containing the bpm and music rate doesn't appear in Casual mode
-- so nudge the song title and banner down a bit when in Casual
local y_offset = SL.Global.GameMode=="Casual" and 50 or 46


local af = Def.ActorFrame{ InitCommand=function(self) self:xy(_screen.cx, y_offset) end }

if SongOrCourse and SongOrCourse:HasBanner() then
	--song or course banner, if there is one
	af[#af+1] = Def.Banner{
		Name="Banner",
		InitCommand=function(self)
			if GAMESTATE:IsCourseMode() then
				self:LoadFromCourse( GAMESTATE:GetCurrentCourse() )
			else
				self:LoadFromSong( GAMESTATE:GetCurrentSong() )
			end
			self:y(66):setsize(banner.width, 164):zoom(banner.zoom)
		end,
	}
else
	--fallback banner
	af[#af+1] = LoadActor(banner.directory .. "/banner" .. SL.Global.ActiveColorIndex .. " (doubleres).png")..{
		InitCommand=function(self) self:y(66):zoom(banner.zoom) end
	}
end

-- quad behind the song/course title text
af[#af+1] = Def.Quad{
	InitCommand=function(self) 
		self:diffuse(color("#1E282F")):setsize(banner.width,25):zoom(banner.zoom)
		if ThemePrefs.Get("VisualStyle") == "Technique" then
			self:diffusealpha(0.5)
		end
	end,
}

-- song/course title text
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		local songtitle = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()) or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
		if songtitle then self:settext(songtitle):maxwidth(banner.width*banner.zoom) end
	end
}

return af