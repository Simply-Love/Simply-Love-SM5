local banner_directory = { Hearts="Hearts", Arrows="Arrows" }

local af = Def.ActorFrame{

	-- quad behind the song/course title text
	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282F"); xy,_screen.cx, 54.5; zoomto, 292.5,20),
	},

	-- song/course title text
	LoadFont("_miso")..{
		InitCommand=cmd(xy,_screen.cx,54; maxwidth, 294 ),
		OnCommand=function(self)
			local songtitle = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()) or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()

			if songtitle then
				self:settext(songtitle)
			end
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
		end,
		OnCommand=cmd(xy, _screen.cx, 121.5; setsize,418,164; zoom, 0.7 )
	}
else
	--fallback banner
	af[#af+1] = LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/" .. (banner_directory[ThemePrefs.Get("VisualTheme")] or "Hearts") .. "/banner" .. SL.Global.ActiveColorIndex .. " (doubleres).png"))..{
		InitCommand=function(self) self:xy( _screen.cx, 121.5):zoom(0.7) end
	}
end

return af