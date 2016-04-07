local StaticPath = "Save/Static.ini"

local CreateStatic = function()
	local f = RageFileUtil.CreateRageFile()

	if f:Open(StaticPath, 2) then
		f:Write( "" )
	else
		local fError = f:GetError()
		Trace( "[FileUtils] Error writing to ".. fullFilename ..": ".. fError )
		f:ClearError()
	end

	f:destroy()
end

-- if a Static.ini already exists, either from previously running this theme,
-- or from the user manually creating one, then don't do anything here.
-- Just leave it.  If, however, no Static.ini is found...

if not FILEMAN:DoesFileExist( StaticPath ) then

	-- IniFile.ReadFile() just breaks progress if nothing is found at StaticPath
	-- so ensure that a(n empty) file exists, first.
	CreateStatic()

	-- then, read that file in so we can work with it...
	local file = IniFile.ReadFile( StaticPath )


	-- The following preferences will be manipulated using PREFSMAN:SetPreference()
	-- while a user uses Simply Love, so I'm hardcoding them here to be written out to
	-- Static.ini as needed.
	-- It is always possible (encouraged, even) that the user might switch themes, and in doing
	-- so, s/he might be stuck with preferences set by this Theme.  Get around this by looking
	-- up whatever values s/he has set in Preferences.ini for these particular preferences,
	-- and writing them to Static.ini.
	--
	-- In general, themes should NOT set preferences, but there is no other way for me
	-- to achieve multiple GameModes like Casual, Competitive, and StomperZ...

	-- preferences that should be saved, as is
	local Preferences_To_Save = {
		"RegenComboAfterMiss",
		"MaxRegenComboAfterMiss",
		"MinTNSToHideNotes",
		"HarshHotLifePenalty",
	}

	-- Some preferences are floating-point values and should
	-- be rounded to 6 decimal places prior to being written
	-- to disk.
	local Preferences_To_Save_And_Round = {
		"TimingWindowAdd",
		"TimingWindowSecondsHold",
		"TimingWindowSecondsMine",
		"TimingWindowSecondsRoll",
		"TimingWindowSecondsW1",
		"TimingWindowSecondsW2",
		"TimingWindowSecondsW3",
		"TimingWindowSecondsW4",
		"TimingWindowSecondsW5",
	}

	file["Options"] = {}

	for i, pref in ipairs(Preferences_To_Save) do
		if file["Options"][pref] == nil then
			file["Options"][pref] = PREFSMAN:GetPreference(pref)
		end
	end
	for i, pref in ipairs(Preferences_To_Save_And_Round) do
		if file["Options"][pref] == nil then
			file["Options"][pref] = round(PREFSMAN:GetPreference(pref), 6)
		end
	end


	IniFile.WriteFile( StaticPath, file )
end