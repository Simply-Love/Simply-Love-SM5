function NameEntryTraditionalCodes()
	
	if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
		return	"Backspace,MenuLeft,MenuRight,Enter"
	else
		return "Backspace,Left,Right,MenuLeft,MenuRight,Enter"
	end
	
end

function ScreenSelectMusicSortCode2()
	if GAMESTATE:GetCurrentGame():GetName() == "pump" then
		return "DownLeft-DownRight"
	else
		return "Left-Right"
	end
end