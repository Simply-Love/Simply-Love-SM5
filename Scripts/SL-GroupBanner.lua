----------------------------
-- Group Banner functions --
----------------------------
function GetGroupBanner()
	local path = '';
	if ThemePrefs.Get('NoBannerUseToGroupBanner') then
		local current = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong();
		if current then
			if GAMESTATE:IsCourseMode() then
				path = SONGMAN:GetCourseGroupBannerPath(current:GetGroupName());
			else
				path = SONGMAN:GetSongGroupBannerPath(current:GetGroupName());
			end
		end
	end
	return path;
end

function HasGroupBanner()
	return GetGroupBanner() ~= '';
end
