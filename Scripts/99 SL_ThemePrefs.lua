local SL_DefaultCustomPrefs =
{
	AllowFailingOutOfSet = false,
	AllowScreenEvalSummary = true,
	AllowScreenGameOver = true,
	AllowScreenNameEntry = true,
	NumberOfContinuesAllowed = 0,
		-- a nice pinkish-purple, by default
	SimplyLoveColor = 3,
}

SL_CustomPrefs= create_setting("SL_CustomPrefs", "SL_CustomPrefs.lua", SL_DefaultCustomPrefs, -1)
SL_CustomPrefs:load()

-- args to create_setting: name, filename, default_value, match_depth
-- name is used when reporting problems saving the setting.
-- filename is the file the settings will be saved in.
-- default_value is a table containing the default configuration.  This
--   table can contain numbers, strings, bools, or tables, indexed by numbers
--   or strings.
-- match_depth is the depth to which the elements of the loaded table must be
--   the same type as the elements of the default table.  This exists for
--   catching cases where you start out storing "like_cats" as a string
--   ('yes' or 'no'), and later switch to using a number.  Any element of the
--   loaded table that doesn't have the same type as the corresponding
--   element of the default table will be replaced with the value from the
--   default config.  So in the example with "like_cats", whether the user
--   previously set 'yes' or 'no', after it's changed to a number, they'll
--   have the new default value.
--   Since tables can contain tables, match_depth is a number that controls
--   how far into the config the matching will recurse.  match_depth of -1
--   means recurse all the way, 0 means not at all, 1 means only the first
--   layer, and so on.  You probably want to use a match_depth of -1 unless
--   you're Kyzentun.

-- How to use the setting:
-- All functions for the setting take a profile_slot argument to set which
-- loaded profile they operate on.
-- "ProfileSlot_Invalid" changes the config for global settings, outside of
--    any profile,
-- "ProfileSlot_Player1" changes the config for player 1's profile
-- "ProfileSlot_Player2" changes the config for palyer 2's profile,
-- "ProfileSlot_Machine" changes the config for the machine profile.
--
-- Before the setting can be used, it has to be loaded for the profile_slot
--   you want to use it for.
-- After it's loaded you must call get_data to fetch the config for a slot to
--   use or change its values.
-- If you change the config for a slot, you should call set_dirty for that
--   slot so that the setting knows that slot has been changed.
-- At a convenient time, call save to save a slot.  Slots are only saved if
--   they are are marked as dirty.  It's best to save when the player is
--   leaving the screen after having completed all configuration changes they
--   wish to make.

-- Side project:  Figure out whether you have enough users to make it worth
-- your time to migrate their options from the old system to the new.  If it
-- takes 30 seconds per user to set new options, and you have 200 users, then
-- it's worth making a migration system if the migration system takes less
-- than 100 minutes to implement and test. -Kyz


-- Stuff for option rows below.

local function SL_Pref_get_wrapper(pref_name)
	return function(pn) return SL_CustomPrefs:get_data()[pref_name] end
end

local function SL_Pref_set_wrapper(pref_name)
	return function(pn, value)
		SL_CustomPrefs:get_data()[pref_name]= value
		SL_CustomPrefs:set_dirty()
	end
end

function SL_Pref_bool_row(pref_name)
	return bool_option_row(
		pref_name, SL_Pref_get_wrapper(pref_name), SL_Pref_set_wrapper(pref_name),
		"Yes", "No", true, "OptionTitles")
end

function SL_Pref_int_row(pref_name, min, max)
	return int_range_option_row(
		pref_name, SL_Pref_get_wrapper(pref_name), SL_Pref_set_wrapper(pref_name),
		min, max, true)
end

-- This is why I hate metrics:
-- Stupid limitations like not being able to use commas.
-- If this code was in the metrics, it would be split on the commas and break.
function SL_NumContinuesRow()
	return SL_Pref_int_row('NumberOfContinuesAllowed', 0, 12)
end
