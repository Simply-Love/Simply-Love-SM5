local StaticPath = "Save/Static.ini"
local file = IniFile.ReadFile( StaticPath )


-- This table contains various SM5 Preferences and their default values.
-- These particular preferences will be manipulated using PREFSMAN:SetPreference()
-- while a user uses Simply Love, so I'm hardcoding them here to be written out to
-- Static.ini as needed.
--
-- If no Static.ini file is found, one is written using these values.
--
-- If an empty Static.ini file is found, these values are added to it.
--
-- If a corresponding key/value pair is found already existing in Static.ini under
-- the "Options" section, those values are left alone; presumably the user wants them.

local SM5_DEFAULTS = {
	TimingWindowAdd = 0.000000,
	RegenComboAfterMiss=5,
	MaxRegenComboAfterMiss=5,
	MinTNSToHideNotes=W3,
	TimingWindowSecondsHold=0.250000,
	TimingWindowSecondsMine=0.090000,
	TimingWindowSecondsRoll=0.500000,
	TimingWindowSecondsW1=0.022500,
	TimingWindowSecondsW2=0.045000,
	TimingWindowSecondsW3=0.090000,
	TimingWindowSecondsW4=0.135000,
	TimingWindowSecondsW5=0.180000,
}

if file["Options"] == nil then
	file["Options"] = {}
end

for key, value in pairs(SM5_DEFAULTS) do
	if file["Options"][key] == nil then
		file["Options"][key] = value
	end
end

IniFile.WriteFile( StaticPath, file )