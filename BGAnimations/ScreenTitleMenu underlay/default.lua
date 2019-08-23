local TextColor = ThemePrefs.Get("RainbowMode") and Color.Black or Color.White

local SongStats = SONGMAN:GetNumSongs() .. " songs in "
SongStats = SongStats .. SONGMAN:GetNumSongGroups() .. " groups, "
SongStats = SongStats .. #SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses")) .. " courses"

-- - - - - - - - - - - - - - - - - - - - -
local game = GAMESTATE:GetCurrentGame():GetName();
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

-- - - - - - - - - - - - - - - - - - - - -
-- People commonly have multiple copies of SL installed – sometimes different forks with unique features
-- sometimes due to concern that an update will cause them to lose data, sometimes accidentally, etc.

-- It is important to display the current theme's name to help users quickly assess what version of SL
-- they are using right now.  THEME:GetCurThemeName() provides the name of the theme folder from the
-- filesystem, so we'll show that.  It is guaranteed to be unique and users are likely to recognize it.
local sl_name = THEME:GetCurThemeName()

-- - - - - - - - - - - - - - - - - - - - -
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

-- - - - - - - - - - - - - - - - - - - - -
local style = ThemePrefs.Get("VisualTheme")
local image = "TitleMenu"

-- see: watch?v=wxBO6KX9qTA etc.
if FILEMAN:DoesFileExist("/Themes/"..sl_name.."/Graphics/_VisualStyles/"..ThemePrefs.Get("VisualTheme").."/TitleMenuAlt (doubleres).png") then
	if math.random(1,100) <= 10 then image="TitleMenuAlt" end
end

local af = Def.ActorFrame{
	InitCommand=function(self)
		--see: ./Scripts/SL_Initialize.lua
		InitializeSimplyLove()

		self:Center()
	end,
	OffCommand=cmd(linear,0.5; diffusealpha, 0),

	Def.ActorFrame{
		InitCommand=function(self) self:zoom(0.8):y(-120):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(0.2):linear(0.4):diffusealpha(1) end,

		LoadFont("Common Normal")..{
			Text=sm_version .. "       " .. sl_name .. (sl_version and (" v" .. sl_version) or ""),
			InitCommand=function(self) self:y(-20):diffuse(TextColor) end,
		},
		LoadFont("Common Normal")..{
			Text=SongStats,
			InitCommand=function(self) self:diffuse(TextColor) end,
		}
	},

	LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
		InitCommand=function(self)
			self:y(-16):zoom( game=="pump" and 0.2 or 0.205 )
		end
	},

	LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/"..image.." (doubleres).png"))..{
		InitCommand=function(self) self:x(2):zoom(0.7):shadowlength(0.75) end,
		OffCommand=function(self) self:linear(0.5):shadowlength(0) end
	}
}

-- the best way to spread holiday cheer is singing loud for all to hear
if PREFSMAN:GetPreference("EasterEggs") and MonthOfYear()==11 then
	af[#af+1] = Def.Sprite{
		Texture=THEME:GetPathB("ScreenTitleMenu", "underlay/hat.png"),
		InitCommand=function(self) self:zoom(0.225):xy( 130, -self:GetHeight()/2 ):rotationz(15):queuecommand("Drop") end,
		DropCommand=function(self) self:decelerate(1.333):y(-110) end,
	}
end

return af