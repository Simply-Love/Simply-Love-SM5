-- -----------------------------------------------------------------------
-- local helper function to transform a StepMania version string ("5.0.12") into a table of numbers { 5, 0, 12 }

local getProductVersion = function()
	if type(ProductVersion) ~= "function" then return {} end

	-- get the version string, e.g. "5.0.11" or "5.1.0" or "5.2-git-96f9771" or etc.
	local version = ProductVersion()
	if type(version) ~= "string" then return {} end

	-- remove the build suffix from the version string
	-- debug build are suffixed with "-git-$something" or "-UNKNOWN" if the
	-- git hash is not available for some reason
	version = version:gsub("-.*", "")

	-- parse the version string into a table
	local v = {}
	for i in version:gmatch("[^%.]+") do
		table.insert(v, tonumber(i))
	end

	return v
end

-- IsProductVersion() accepts multiple number arguments representing StepMania family, major, and minor releases
-- returns true if the user's StepMania engine version matches arguments
-- returns false if not
--
-- all arguments are optional and IsProductVersion() will only check the engine's version number
-- for as many arguments as are provided
--
-- for example, if the user's SM version is "5.0.12"
--   IsProductVersion(5, 0, 11) will return false
--   IsProductVersion(5, 0, 12) will return true
--   IsProductVersion(5, 0)     will return true
--   IsProductVersion(5, 1)     will return false

function IsProductVersion(...)
	local version = getProductVersion()

	for i = 1, select('#', ...) do
		if select(i, ...) ~= version[i] then
			return false
		end
	end

	return true
end

function IsMinimumProductVersion(...)
	local version = getProductVersion()

	for i = 1, select('#', ...) do
		local n = select(i, ...)
		if not version[i] or version[i] < n then
			return false
		elseif version[i] > n then
			return true
		end
	end

	return true
end


function IsStepMania()
	if type(ProductFamily) ~= "function" then return false end
	return ProductFamily() == "StepMania"
end


function IsOutFox()
	if type(ProductFamily) ~= "function" then return false end
	return ProductFamily() == "OutFox"
end


function IsITGmania()
	if type(ProductFamily) ~= "function" then return false end
	return ProductFamily() == "ITGmania"
end


-- -----------------------------------------------------------------------
-- use StepManiaVersionIsSupported() to check if Simply Love supports the version of SM5 in use

StepManiaVersionIsSupported = function()
	-- SM5.0.12 is supported (latest stable release)
	-- SM5.1.x is supported
	-- SM5.2 is not supported because it saw significant
	--       backwards-incompatible API changes and is now abandoned
	if IsStepMania() then
		return IsProductVersion(5, 0, 12) or IsProductVersion(5, 1)
	end

	-- OutFox >= 0.4 is supported (beta status because it's not open source yet)
	if IsOutFox() then
		return IsMinimumProductVersion(0, 4)
	end

	-- ITGmania >= 0.6.0
	if IsITGmania() then
		return IsMinimumProductVersion(0, 7, 0)
	end

	return false
end

-- -----------------------------------------------------------------------
-- game types like "kickbox" and "lights" aren't supported in Simply Love, so we
-- use this function to hardcode a list of game modes that are supported, and use it
-- in ScreenInit overlay.lua to redirect players to ScreenSelectGame if necessary.
--
-- (Because so many people have accidentally gotten themselves into lights mode without
-- having any idea they'd done so, and have then messaged me saying the theme was broken.)

CurrentGameIsSupported = function()
	-- a hardcoded list of games that Simply Love supports
	local support = {
		dance  = true,
		pump   = true,
		techno = true,
		para   = true,
		kb7    = true
	}
	-- return true or nil
	return support[GAMESTATE:GetCurrentGame():GetName()]
end

-- -----------------------------------------------------------------------
-- read the theme version from ThemeInfo.ini to display on ScreenTitleMenu underlay
-- this allows players to more easily identify what version of the theme they are currently using

GetThemeVersion = function()
	local file = IniFile.ReadFile( THEME:GetCurrentThemeDirectory() .. "ThemeInfo.ini" )
	if file then
		if file.ThemeInfo and file.ThemeInfo.Version then
			return file.ThemeInfo.Version
		end
	end
	return false
end

-- -----------------------------------------------------------------------
-- NOTE: This is the preferred way to check for RTT support, but we cannot rely on it to
--   accurately tell us whether the current system atually supports RTT!
--   Some players on Linux and [some version of] SM5.1-beta reported that DISPLAY:SupportsRenderToTexture()
--   returned false, when render to texture was definitely working for them.
--   I'm leaving this check here, but commented out, both as "inline instruction" for current SM5 themers
--   and so that it can be easily uncommented and used ~~when we are trees again~~ at a future date.

-- SupportsRenderToTexture = function()
-- 	-- ensure the method exists and, if so, ensure that it returns true
-- 	return DISPLAY.SupportsRenderToTexture and DISPLAY:SupportsRenderToTexture()
-- end


-- -----------------------------------------------------------------------
-- SM5's d3d implementation does not support render to texture. The DISPLAY
-- singleton has a method to check this but it doesn't seem to be implemented
-- in RageDisplay_D3D which is, ironically, where it's most needed.  So, this.

SupportsRenderToTexture = function()
	-- This is not a sensible way to assess this; it is a hack and should be removed at a future date.
	if HOOKS:GetArchName():lower():match("windows")
	and PREFSMAN:GetPreference("VideoRenderers"):sub(1,3):lower() == "d3d" then
		return false
	end

	return true
end
