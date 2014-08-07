-- Lua stuff that didn't fit anywhere else...

function GetCredits()
	local coins = GAMESTATE:GetCoins()
	local coinsPerCredit = PREFSMAN:GetPreference('CoinsPerCredit')
	local credits = math.floor(coins/coinsPerCredit)
	local remainder = coins % coinsPerCredit
	
	local r = {
		Credits=credits,
		Remainder=remainder,
		CoinsPerCredit=coinsPerCredit
	}
	return r
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
	return t
end


function GetStepsTypeForThisGame(type)
	local game = GAMESTATE:GetCurrentGame():GetName();
	-- capitalize the first letter
	game = game:gsub("^%l", string.upper);
	
	return "StepsType_" .. game .. "_" .. type;
end