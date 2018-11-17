local banner_directory = { Hearts="Hearts", Arrows="Arrows" }
local SongOrCourse, banner

local t = Def.ActorFrame{
	OnCommand=function(self)
		if IsUsingWideScreen() then
			self:zoom(0.7655)
			self:xy(_screen.cx - 170, 112)
		else
			self:zoom(0.75)
			self:xy(_screen.cx - 166, 112)
		end
	end,

	Def.ActorFrame{
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set"),
		SetCommand=function(self)
			SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			if SongOrCourse and SongOrCourse:HasBanner() then
				self:visible(false)
			else
				self:visible(true)
			end
		end,

		LoadActor("colored_banners/".. (banner_directory[ThemePrefs.Get("VisualTheme")] or "Hearts") .."/banner".. SL.Global.ActiveColorIndex .." (doubleres).png")..{
			Name="FallbackBanner",
			OnCommand=cmd(rotationy,180; setsize,418,164; diffuseshift; effectoffset,3; effectperiod, 6; effectcolor1, 1,1,1,0; effectcolor2, 1,1,1,1)
		},

		LoadActor("colored_banners/".. (banner_directory[ThemePrefs.Get("VisualTheme")] or "Hearts") .."/banner".. SL.Global.ActiveColorIndex .." (doubleres).png")..{
			Name="FallbackBanner",
			OnCommand=cmd(diffuseshift; effectperiod, 6; effectcolor1, 1,1,1,0; effectcolor2, 1,1,1,1; setsize, 418,164)
		},
	},

	Def.Sprite{
		Name="GroupBanner",
		OnCommand=cmd(setsize,418,164;visible,false;playcommand,"Set"),
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set"),
		SetCommand=function(self)
			SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong();
			if SongOrCourse and not SongOrCourse:HasBanner() and HasGroupBanner() then
				self:Load(GetGroupBanner());
				self:setsize(418,164);
				self:visible(true);
			else
				self:visible(false);
			end
		end,
	},

	Def.ActorProxy{
		Name="BannerProxy",
		OnCommand=cmd(setsize,418,164),
		BeginCommand=function(self)
			banner = SCREENMAN:GetTopScreen():GetChild('Banner')
			self:SetTarget(banner)
		end
	},

	-- the MusicRate Quad and text
	Def.ActorFrame{
		InitCommand=function(self)
			self:visible( SL.Global.ActiveModifiers.MusicRate ~= 1 ):y(75)
		end,

		--quad behind the music rate text
		Def.Quad{
			InitCommand=function(self) self:diffuse( color("#1E282FCC") ):zoomto(418,14) end
		},

		--the music rate text
		LoadFont("_miso")..{
			InitCommand=function(self) self:shadowlength(1):zoom(0.85) end,
			OnCommand=function(self)
				self:settext(("%g"):format(SL.Global.ActiveModifiers.MusicRate) .. "x " .. THEME:GetString("OptionTitles", "MusicRate"))
			end
		}
	}
}

return t