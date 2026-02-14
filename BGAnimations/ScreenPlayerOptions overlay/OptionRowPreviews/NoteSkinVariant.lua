local t = ...

-- Add noteskin actors to the primary AF and hide them immediately.
-- We'll refer to these later via ActorProxy in ./Graphics/OptionRow Frame.lua
for noteskin in ivalues( CustomOptionRow("NoteSkin").Choices ) do
	local variants = NOTESKIN:GetVariantNamesForNoteSkin(noteskin)
	t[#t+1] = LoadActor(THEME:GetPathB("","_modules/NoteSkinPreview.lua"), {noteskin_name=noteskin, using_variant=true})
	if variants and #variants > 0 then
		for _, variant in ipairs(variants) do
			t[#t+1] = LoadActor(THEME:GetPathB("","_modules/NoteSkinPreview.lua"), {noteskin_name=variant, using_variant=true})
		end
	end
end