local SongOrCourse
local CurrentSong
local CurrentGroup
local GroupJawn
local GroupScrollBanners

local t = Def.ActorFrame{
	OnCommand=function(self)
		if IsUsingWideScreen() then
			self:zoom(0.7655)
			self:xy(_screen.cx, WideScale(62,62.75))
		else
			self:zoom(0.75)
			self:xy(_screen.cx - 166, 61)
		end
	end,

	Def.ActorFrame{
		CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
		CloseThisFolderHasFocusMessageCommand=function(self) self:playcommand("Set") end,
		SwitchFocusToGroupsMessageCommand=function(self) self:playcommand("Set") end,
		SwitchFocusToSongsMessageCommand=function(self) self:playcommand("Set") end,
		GroupsHaveChangedMessageCommand=function(self) self:visible(true):playcommand("Set")
		end,
		SetCommand=function(self)
			SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			BannerOfGroup = BannerOfGroup
			self:visible(true)
			
		end,

		LoadActor("default banner")..{
			Name="FallbackBanner",
			OnCommand=cmd(setsize,418,164)
		},
	},

	Def.Sprite{
		Name="LoadFromSong",
		CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
		CloseThisFolderHasFocusMessageCommand=function(self) self:visible(false) 
		end,
		GroupsHaveChangedMessageCommand=function(self) self:visible(false) end,
		SetCommand=function(self)
		CurrentSong = GAMESTATE:GetCurrentSong()
			if SongOrCourse and SongOrCourse:HasBanner() then
				self:visible(true)
			else
				self:visible(false)
			end
			OnCommand=cmd(setsize,418,164)
			self:LoadFromSongBanner(CurrentSong)
			self:zoomto(418,164)
		end
	},
	
	Def.Banner{
		Name="LoadFromGroup",
		CurrentSongChangedMessageCommand=function(self) GroupScrollBanners = false GroupJawn = false self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self) GroupScrollBanners = false GroupJawn = false self:playcommand("Set") end,
		GroupsHaveChangedMessageCommand=function(self) 
			GroupScrollBanners = true
			GroupJawn = false 
			self
			:playcommand("Set") 
			:visible(true)
			end,
		CloseThisFolderHasFocusMessageCommand=function(self) BannerOfGroup = NameOfGroup GroupJawn = true self:visible(true):playcommand("Set") end,
		SetCommand=function(self)
			if BannerOfGroup == nil then
				self:visible(false)
			elseif GroupJawn == true then
				self:visible(true)
				self:LoadFromSongGroup(BannerOfGroup)
			elseif GroupScrollBanners == true then
				self:visible(true)
				self:LoadFromSongGroup(BannerOfGroup)
			else
				self:visible(false)
			end
			OnCommand=cmd(setsize,418,164)
			self:zoomto(418,164)
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
		LoadFont("Miso/_miso")..{
			InitCommand=function(self) self:shadowlength(1):zoom(0.85) end,
			OnCommand=function(self)
				self:settext(("%g"):format(SL.Global.ActiveModifiers.MusicRate) .. "x " .. THEME:GetString("OptionTitles", "MusicRate"))
			end
		}
	}
}

return t