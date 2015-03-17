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

function GetStepsTypeForThisGame(type)
	local game = GAMESTATE:GetCurrentGame():GetName()
	-- capitalize the first letter
	game = game:gsub("^%l", string.upper)

	return "StepsType_" .. game .. "_" .. type
end

-- shim to suppress errors resulting from SM3.95 charts
function Actor:hidden(self, flag)
	-- if a value other than 0 or 1 was passed, don't do anything...
	if flag == 0 or flag == 1 then
		self:visible(math.abs(flag - 1))
	end
end