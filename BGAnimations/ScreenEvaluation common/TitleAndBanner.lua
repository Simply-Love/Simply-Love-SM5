local banner = {
	directory = { Hearts="Hearts", Arrows="Arrows" },
	width = 418,
	zoom = 0.7,
}

local af = Def.ActorFrame{
	InitCommand=function(self) self:xy(_screen.cx, 46) end,

	-- quad behind the song/course title text
	Def.Quad{
		InitCommand=function(self) self:diffuse(color("#1E282F")):setsize(banner.width,25):zoom(banner.zoom) end,
	},

	-- song/course title text
	LoadFont("_miso")..{
		InitCommand=function(self)
			local songtitle = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()) or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
			if songtitle then self:settext(songtitle):maxwidth(banner.width*banner.zoom) end
		end
	}
}

local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()

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
	af[#af+1] = LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/" .. (banner.directory[ThemePrefs.Get("VisualTheme")] or "Hearts") .. "/banner" .. SL.Global.ActiveColorIndex .. " (doubleres).png"))..{
		InitCommand=function(self) self:y(66):zoom(banner.zoom) end
	}
end

return af