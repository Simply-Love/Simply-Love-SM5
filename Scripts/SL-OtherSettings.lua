-- Lua stuff that didn't fit anywhere else...

function GetCredits()
	local coins=GAMESTATE:GetCoins();
	local coinsPerCredit=PREFSMAN:GetPreference('CoinsPerCredit');
	local credits=math.floor(coins/coinsPerCredit);
	local remainder=math.mod(coins,coinsPerCredit);
	local r = {
		Credits=credits,
		Remainder=remainder,
		CoinsPerCredit=coinsPerCredit
	};
	return r;
end	
	

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