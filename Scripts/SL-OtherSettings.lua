function NameEntryTraditionalCodes()
	
	if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
		return	"Backspace,MenuLeft,MenuRight,MenuLeftReleased,MenuRightReleased,Enter"
	else
		return "Backspace,Left,Right,LeftReleased,RightReleased,MenuLeft,MenuRight,MenuLeftReleased,MenuRightReleased,Enter"
	end
	
end

function ScreenSelectMusicSortCode2()
	if GAMESTATE:GetCurrentGame():GetName() == "pump" then
		return "DownLeft-DownRight"
	else
		return "MenuLeft-MenuRight"
	end
end