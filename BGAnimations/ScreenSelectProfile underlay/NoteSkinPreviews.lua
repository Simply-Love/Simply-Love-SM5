local args = ...
local af = args.af

local already_loaded = {}

for profile in ivalues(args.profile_data) do
	if profile.noteskin ~= nil and profile.noteskin ~= "" and not FindInTable(profile.noteskin, already_loaded) then
		table.insert(already_loaded, profile.noteskin)
		af[#af+1] = LoadActor(THEME:GetPathB("","_modules/NoteSkinPreview.lua"), {noteskin_name=profile.noteskin})
	end
end