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

function ScreenSelectMusicSortCode2()
	if GAMESTATE:GetCurrentGame():GetName() == "pump" then
		return "DownLeft-DownRight"
	else
		return "MenuLeft-MenuRight"
	end
end

function SelectColorScrollerItems()
	if IsUsingWideScreen() then
		return 12
	else
		return 5
	end
end


-- woo, hax
function EmptyOptionRow()
	local t = {
		Name = "Fake",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = {""},
		LoadSelections = function(self, list, pn)
			list[1] = true
		end,
		SaveSelections = function(self, list, pn) end
	}
	setmetatable(t, t)
	return t
end