local cancel = THEME:GetString("ScreenSelectMusicCasual", "FooterTextSingleSong")
if PREFSMAN:GetPreference("ThreeKeyNavigation") then cancel = THEME:GetString("ScreenSelectMusicCasual", "FooterTextSingleSong3Key") end

return LoadFont("_miso")..{
	InitCommand=function(self) self:xy(_screen.cx, _screen.h - 16):zoom(0.7):diffusealpha(0) end,
	SwitchFocusToGroupsMessageCommand=function(self)
		self:diffusealpha(0):settext(THEME:GetString("ScreenSelectMusicCasual", "FooterTextGroups")):linear(0.15):diffusealpha(1)
	end,
	SwitchFocusToSongsMessageCommand=function(self)
		self:diffusealpha(0):settext(THEME:GetString("ScreenSelectMusicCasual", "FooterTextSongs")):linear(0.15):diffusealpha(1)
	end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		self:diffusealpha(0):settext( cancel ):linear(0.15):diffusealpha(1)
	end,
}