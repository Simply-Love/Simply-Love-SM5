local TextColor = (ThemePrefs.Get("RainbowMode") and (not HolidayCheer()) and Color.Black) or Color.White

-- generate a string like "7741 songs in 69 groups, 10 courses"
local SongStats = ("%i %s %i %s, %i %s"):format(
	SONGMAN:GetNumSongs(),
	THEME:GetString("ScreenTitleMenu", "songs in"),
	SONGMAN:GetNumSongGroups(),
	THEME:GetString("ScreenTitleMenu", "groups"),
	#SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses")),
	THEME:GetString("ScreenTitleMenu", "courses")
)

-- - - - - - - - - - - - - - - - - - - - -
-- use the current game (dance, pump, etc.) to load the apporopriate logo
-- SL currently has logo assets for: dance, pump, techno
--   use the techno logo asset for less common games (para, kb7, etc.)
local game = GAMESTATE:GetCurrentGame():GetName()
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


-- -----------------------------------------------------------------------
-- preliminary Lua setup is done
-- now define actors to be passed back to the SM engine

local af = Def.ActorFrame{
	InitCommand=function(self)
		--see: ./Scripts/SL_Init.lua
		InitializeSimplyLove()

		self:Center()
	end,
	OffCommand=function(self) self:smooth(0.65):diffusealpha(0) end,
}

-- SIMPLY [something]
af[#af+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/"..image.." (doubleres).png"))..{
	Name="Simply Text",
	InitCommand=function(self)
		self:zoom(0.7):vertalign(top)
		self:y(-102):shadowlength(0.75)
	end,
	OffCommand=function(self) self:linear(0.5):shadowlength(0) end
}

-- decorative arrows
af[#af+1] = LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
	InitCommand=function(self)
		self:y(-16)

		-- get a reference to the SIMPLY [something] graphic
		-- it's rasterized text in the Wendy font like "SIMPLY LOVE" or "SIMPLY THONK" or etc.
		local simply = self:GetParent():GetChild("Simply Text")

		-- zoom the logo's width to match the width of the text graphic
		-- zoomtowidth() performs a "horizontal" zoom (on the x-axis) to meet a provided pixel quantity
		--    and leaves the y-axis zoom as-is, potentially skewing/squishing the appearance of the asset
		self:zoomtowidth( simply:GetZoomedWidth() )

		-- so, get the horizontal zoom factor of these decorative arrows
		-- and apply it to the y-axis as well to maintain proportions
		self:zoomy( self:GetZoomX() )
	end
}

-- SM version, SL version, song stats
af[#af+1] = Def.ActorFrame{
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
}

-- the best way to spread holiday cheer is singing loud for all to hear
if HolidayCheer() then
	af[#af+1] = Def.Sprite{
		Texture=THEME:GetPathB("ScreenTitleMenu", "underlay/hat.png"),
		InitCommand=function(self) self:zoom(0.225):xy( 130, -self:GetHeight()/2 ):rotationz(15):queuecommand("Drop") end,
		DropCommand=function(self) self:decelerate(1.333):y(-110) end,
	}
end

return af