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
		dance  = true,
		pump   = true,
		techno = true,
		para   = true,
		kb7    = true
	}
	-- return true or nil
	return support[GAMESTATE:GetCurrentGame():GetName()]
end