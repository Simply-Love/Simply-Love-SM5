local TextColor = (ThemePrefs.Get("RainbowMode") and (not HolidayCheer()) and Color.Black) or Color.White

-- generate a string like "7741 songs in 69 groups, 10 courses"
local song_stats = ("%i %s %i %s, %i %s"):format(
	SONGMAN:GetNumSongs(),
	THEME:GetString("ScreenTitleMenu", "songs in"),
	SONGMAN:GetNumSongGroups(),
	THEME:GetString("ScreenTitleMenu", "groups"),
	#SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses")),
	THEME:GetString("ScreenTitleMenu", "courses")
)

-- -----------------------------------------------------------------------
-- People commonly have multiple copies of SL installed – sometimes different forks with unique features
-- sometimes due to concern that an update will cause them to lose data, sometimes accidentally, etc.

-- It is important to display the current theme's name to help users quickly assess what version of SL
-- they are using right now.  THEME:GetCurThemeName() provides the name of the theme folder from the
-- filesystem, so we'll show that.  It is guaranteed to be unique and users are likely to recognize it.
local sl_name = THEME:GetCurThemeName()

-- -----------------------------------------------------------------------
-- ProductFamily() returns "StepMania"
-- ProductVersion() returns the (stringified) version number (like "5.0.12" or "5.1.0")
-- so, start with a string like "StepMania 5.0.12" or "StepMania 5.1.0"
local sm_version = ("%s %s"):format(ProductFamily(), ProductVersion())

-- GetThemeVersion() is defined in ./Scripts/SL-Helpers.lua and returns the SL version from ThemeInfo.ini
local sl_version = GetThemeVersion()

-- "git" appears in ProductVersion() for non-release builds of StepMania.
-- If a non-release executable is being used, append date information about when it
-- was built to potentially help non-technical cabinet owners submit bug reports.
if ProductVersion():find("git") then
	local date = VersionDate()
	local year = date:sub(1,4)
	local month = date:sub(5,6)
	if month:sub(1,1) == "0" then month = month:gsub("0", "") end
	month = THEME:GetString("Months", "Month"..month)
	local day = date:sub(7,8)

	sm_version = ("%s, Built %s %s %s"):format(sm_version, day, month, year)
end

-- -----------------------------------------------------------------------

-- build a 3-line string to display info about this version of SL, this version of SM, and installed song content
local text = ("%s%s\n%s\n%s"):format(
	sl_name,  (sl_version and (" v" .. sl_version) or ""),
	sm_version,
	song_stats
)

return LoadFont("Common Normal")..{
	Text=text,
	InitCommand=function(self)
		self:zoom(0.8):y(-150):diffusealpha(0)
		self:playcommand("UpdateColor")
	end,
	OnCommand=function(self) self:sleep(0.2):linear(0.4):diffusealpha(1) end,
	UpdateColorCommand=function(self)
		local textColor = Color.White
		local shadowLength = 0
		if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
			textColor = Color.Black
		end
		if ThemePrefs.Get("VisualStyle") == "SRPG8" then
			textColor = color(SL.SRPG8.TextColor)
			shadowLength = 0.4
		end

		self:diffuse(textColor):shadowlength(shadowLength)
	end,
	VisualStyleSelectedMessageCommand=function(self)
		self:playcommand("UpdateColor")
	end,
}