local banner_directory = ThemePrefs.Get("VisualTheme")

return Def.ActorFrame{

	--quad behind the song group text

	Def.Quad{
		InitCommand=function(self)
			if GAMESTATE:IsCourseMode() then
				self:visible(false)
			end
			self:diffuse( color("#32434f") )
			self:xy(_screen.cx, 54.5-13)
			self:zoomto(292.5,17.5)
		end
	},

	-- quad behind the song/course title text
	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282F"); xy,_screen.cx, 59.5; zoomto, 292.5,20),
	},

	-- song group - "Hey, what pack is that from?"
	--We're using song group here, rather than folder, because I don't think it's necessary to know the folder that a song is in like it is on the music select screen (especially since the song folder will generally have the name of the song in it, and it'd just be redundant information). If I were to add the option for song folder, I'd make it yet another simply love preference. More freedom, more better.

	LoadFont("_miso")..{
		InitCommand=cmd(xy,_screen.cx,40; maxwidth, 335;zoom, 0.85 ),
		OnCommand=function(self)
			local song = GAMESTATE:GetCurrentSong()
			local text = ""
			if GAMESTATE:IsCourseMode() then
				self:visible(false)
			end
			if song then
				self:settext(song:GetGroupName());
			else
				self:settext("")
			end
		end
	},

	-- song/course title text
	LoadFont("_miso")..{
		InitCommand=cmd(xy,_screen.cx,59; maxwidth, 294 ),
		OnCommand=function(self)
			local songtitle = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()) or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()

			if songtitle then
				self:settext(songtitle)
			end
		end
	},

	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/".. banner_directory .."/banner" .. SL.Global.ActiveColorIndex .. " (doubleres).png"))..{
		OnCommand=cmd(xy, _screen.cx, 126.5; zoom, 0.7)
	},

	--song or course banner, if there is one
	Def.Banner{
		Name="Banner",
		InitCommand=function(self)
			if GAMESTATE:IsCourseMode() then
				self:LoadFromCourse( GAMESTATE:GetCurrentCourse() )
			else
				self:LoadFromSong( GAMESTATE:GetCurrentSong() )
			end
		end,
		OnCommand=cmd(xy, _screen.cx, 126.5; setsize,418,164; zoom, 0.7 )
	}
}
