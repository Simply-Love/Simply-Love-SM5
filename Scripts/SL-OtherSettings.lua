function NameEntryTraditionalCodes()
	
	if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
		return	"Backspace,MenuLeft,MenuRight,Enter"
	else
		return "Backspace,Left,Right,MenuLeft,MenuRight,Enter"
	end
	
end