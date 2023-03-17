local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualStyle")
local banner_directory = FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")

local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()

local bannerWidth = 418
local bannerHeight = 164

local t = Def.ActorFrame{
	OnCommand=function(self)
		if IsUsingWideScreen() then
			self:zoom(0.7655)
			self:xy(_screen.cx - 170, 96)
		else
			self:zoom(0.75)
			self:xy(_screen.cx - 166, 96)
		end
	end
}

-- fallback banner
t[#t+1] = Def.Sprite{
	Name="FallbackBanner",
	Texture=banner_directory.."/banner"..SL.Global.ActiveColorIndex.." (doubleres).png",
	InitCommand=function(self) self:setsize(bannerWidth, bannerHeight) end,

	CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,

	SetCommand=function(self)
		-- if ShowBanners preference is false, always just show the fallback banner
		-- don't bother assessing whether to draw or not draw
		if PREFSMAN:GetPreference("ShowBanners") == false then return end

		if SongOrCourse and SongOrCourse:HasBanner() then
			self:visible(false)
		else
			self:visible(true)
		end
	end
}

if PREFSMAN:GetPreference("ShowBanners") then
	t[#t+1] = Def.ActorProxy{
		Name="BannerProxy",
		BeginCommand=function(self)
			local banner = SCREENMAN:GetTopScreen():GetChild('Banner')
			self:SetTarget(banner)
		end
	}
end

-- the MusicRate Quad and text
t[#t+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:visible( SL.Global.ActiveModifiers.MusicRate ~= 1 ):y(75)
	end,

	--quad behind the music rate text
	Def.Quad{
		InitCommand=function(self) self:diffuse( color("#1E282FCC") ):zoomto(418,14) end
	},

	--the music rate text
	LoadFont("Common Normal")..{
		InitCommand=function(self) self:shadowlength(1):zoom(0.85) end,
		OnCommand=function(self)
			self:settext(("%g"):format(SL.Global.ActiveModifiers.MusicRate) .. "x " .. THEME:GetString("OptionTitles", "MusicRate"))
		end
	}
}

if not GAMESTATE:IsCourseMode() then
	t[#t+1] = Def.Sprite {
		OnCommand=function(self)
			self:draworder(101)
			self:playcommand("SetCD")
		end,
		OffCommand=function(self)
			self:bouncebegin(0.15)
		end,
		CurrentSongChangedMessageCommand=function(self) self:playcommand("SetCD") end,
		SwitchFocusToGroupsMessageCommand=function(self) self:GetChild("CdTitle"):visible(false) end,
		SetCDCommand=function(self)
			SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			if SongOrCourse and SongOrCourse:HasCDTitle() then
				self:visible(true)
				self:Load( GAMESTATE:GetCurrentSong():GetCDTitlePath() )
				local dim1, dim2 = math.max(self:GetWidth(), self:GetHeight()), math.min(self:GetWidth(), self:GetHeight())
				local ratio = math.max(dim1 / dim2, 2.5)

				local toScale = self:GetWidth() > self:GetHeight() and self:GetWidth() or self:GetHeight()
				self:xy((bannerWidth - 30) / 2, (bannerHeight - 30)/ 2)
				self:zoom(22 / toScale * ratio)
				self:finishtweening():addrotationy(0):linear(.5):addrotationy(360)
			else
				self:visible(false)
			end
		end
	}
end

return t