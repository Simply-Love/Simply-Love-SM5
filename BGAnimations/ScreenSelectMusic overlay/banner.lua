local t = Def.ActorFrame{
	OnCommand=function(self)
		if IsUsingWideScreen() then
			self:zoom(0.7655)
			self:xy(_screen.cx - 173, 112)
		else
			self:zoom(0.74)
			self:xy(_screen.cx - 163, 112)
		end
	end,

	LoadActor("colored_banners/banner"..SimplyLoveColor()..".png")..{
		Name="FallbackBanner",
		OnCommand=cmd(rotationy,180; setsize,418,164; diffuseshift; effectoffset,3; effectperiod, 6; effectcolor1, 1,1,1,0; effectcolor2, 1,1,1,1),
		HideCommand=cmd(visible,false),
		ShowCommand=cmd(visible,true)
	},

	LoadActor("colored_banners/banner"..SimplyLoveColor()..".png")..{
		Name="FallbackBanner",
		OnCommand=cmd(diffuseshift; effectperiod, 6; effectcolor1, 1,1,1,0; effectcolor2, 1,1,1,1; setsize, 418,164),
		HideCommand=cmd(visible,false),
		ShowCommand=cmd(visible,true)
	},

	Def.Banner{
		Name="Banner",
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set"),
		SetCommand=function(self)
			local Group = SCREENMAN:GetTopScreen():GetChild("MusicWheel"):GetSelectedSection()
			local SongOrCourse

			if GAMESTATE:IsCourseMode() then
				SongOrCourse = GAMESTATE:GetCurrentCourse()
			else
				SongOrCourse = GAMESTATE:GetCurrentSong()
			end
			-- try to load a song banner first,
			-- if one is not avaiable, try to load a group banner
			-- if one is not available, hide this sprite, and rely
			-- fallback banner(s) loaded above
			if SongOrCourse then
				self:LoadFromSong(SongOrCourse)
				self:visible(true)
				self:setsize(418,164)
			elseif Group then
				self:visible(true)
				self:LoadFromSongGroup(Group)
				self:setsize(418,164)
			else
				self:visible(false)
			end
		end
	}
}

return t