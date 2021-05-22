local SongOrCourse
local CurrentCourse

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

	-- Preload the Fallback Banner.
	Def.ActorFrame{
		InitCommand=function(self) self:playcommand("Set") end,
		OnCommand=function(self) self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
		SetCommand=function(self)
			SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			self:visible(true)
		end,
		LoadActor(THEME:GetPathB("ScreenSelectMusicDD", "overlay/default banner.png"))..{
			Name="FallbackBanner",
			OnCommand=cmd(setsize,418,164)
		},
	},
	
	-- Load the banner from the course and throw it on top of the fallback.
	Def.Sprite{
		Name="LoadFromSong",
		InitCommand=function(self) self:playcommand("Set") end,
		OnCommand=function(self) self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
		SetCommand=function(self)
			CurrentCourse = GAMESTATE:GetCurrentCourse()
			if SongOrCourse and SongOrCourse:HasBanner() then
				self:visible(true)
			else
				self:visible(false)
			end
			OnCommand=cmd(setsize,418,164)
			self:LoadFromSongBanner(CurrentCourse)
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