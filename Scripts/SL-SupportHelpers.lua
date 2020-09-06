-- Hi there. 🌊
--
-- If you're here to remove or modify StepManiaVersionIsSupported because the
-- StepMania version you use isn't supported – I get where you're coming from.
--
-- It can be frustrating when you just want to play a free game and there seems
-- to be arbitrary walls up preventing that.  I get that that is what this
-- probably feels like.
--
-- For now, Simply Love supports SM5.0.12 and beta releases of SM5.1 from
-- the main StepMania project, which can be found on GitHub at
-- https://github.com/stepmania/stepmania/
--
-- Other forks, older builds, other projects, etc. are blocked here, regardless
-- of their compatibility with Simply Love.  I am only one human person, and I've
-- taken on too much responsibility here with moving the post-ITG community forward
-- in a responsible, open, and inclusive manner.
--
-- I've done very little with my life that I am proud of, but I am confident that
-- this Simply Love project has helped dance game enthusiasts from all over the world
-- enjoy a silly arrow game together, as a community.
--
-- Regardless of their location or language, regardless of their access to specific
-- hardware with limited availability, almost anyone can install and use and benefit
-- from Simply Love.  This is a good thing, and I am proud of this.
--
-- Supporting this is not easy. It's almost always easier to do a quick fix that works
-- for one circumstance – one particular machine, one particular hardware device, one
-- one particular community.  Writing code and designing software that accommodates the
-- broadest community is hard, but it's critically important.  It's the responsibility
-- I've gradually assumed over the years I've worked on Simply Love.
--
-- So, if you're here to remove of modify StepManiaVersionIsSupported as a quick fix,
-- I'll ask you to consider giving back to the broader community instead.
--
-- What features does your fork have that mainline StepMania doesn't?  Can they be
-- brought into mainline StepMania?  Maybe you don't know, maybe you're not a developer,
-- but maybe you know someone who does or is.  Ask.  Get things moving.  Contribute.
-- Everyone will be better off because you helped.
--
-- I appreciate your understanding.  Maybe we can share a dance in the future. :)
--
--                                                                quietly-turning
--                                                                4 July 2020

-- -----------------------------------------------------------------------
-- use StepManiaVersionIsSupported() to check if Simply Love supports the version of SM5 in use

StepManiaVersionIsSupported = function()

	-- ensure that we're using StepMania
	if type(ProductFamily) ~= "function" or ProductFamily():lower() ~= "stepmania" then return false end

	-- ensure that a global ProductVersion() function exists before attempting to call it
	if type(ProductVersion) ~= "function" then return false end

	-- get the version string, e.g. "5.0.11" or "5.1.0" or "5.2-git-96f9771" or etc.
	local version = ProductVersion()
	if type(version) ~= "string" then return false end

	-- remove the git hash if one is present in the version string
	version = version:gsub("-git-.+", "")

	-- split the remaining version string on periods; store each segment in a temp table
	local t = {}
	for i in version:gmatch("[^%.]+") do
		table.insert(t, tonumber(i))
	end

	-- if we didn't detect SM5.x.x then Something Is Terribly Wrong.
	if not (t[1] and t[1]==5) then return false end

	-- SM5.0.x is supported
	-- SM5.1.x is supported
	-- SM5.2 is not supported because it saw significant backwards-incompatible API changes and is now abandoned
	-- SM5.3 is not supported for now because it is not open source
	if not (t[2] and (t[2]==0 or t[2]==1)) then return false end

	-- if we're in SM5.0.x, then check for a third segment
	if t[2]==0 then
		-- SM5.0.12 is supported because SM5.1 is "still in beta" and many users are reluctant to install beta software
		-- anything older than SM5.0.12 is not supported
		if not (t[3] and t[3]==12) then return false end
	end

	return true
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
		dance   = true,
		pump    = true,
		techno  = true,
		para    = true,
		kb7     = true,
		horizon = true
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
