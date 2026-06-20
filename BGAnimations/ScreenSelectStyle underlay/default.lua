local StyleSelected = false
local af

local current_game = GAMESTATE:GetCurrentGame():GetName()
------------------------------------------------------------------------------------

local choices = {
	{
		name="single",
		x=_screen.cx-SL_WideScale(160, 214),
		pads = {
			{color=GetHexColor(SL.Global.ActiveColorIndex, true), offset=0}
		}
	},
	{
		name="versus",
		x=_screen.cx,
		pads = {
			{color=GetHexColor(SL.Global.ActiveColorIndex-1, true), offset=-SL_WideScale(42,51)},
			{color=GetHexColor(SL.Global.ActiveColorIndex+2, true), offset= SL_WideScale(42,51)}
		}
	},
	{
		name="double",
		x=_screen.cx+SL_WideScale(160, 214),
		pads = {
			{color=GetHexColor(SL.Global.ActiveColorIndex+1, true), offset=-SL_WideScale(42,51)},
			{color=GetHexColor(SL.Global.ActiveColorIndex+1, true), offset= SL_WideScale(42,51)}
		}
	},
}

if current_game=="dance" and ThemePrefs.Get("AllowDanceSolo") then
	choices[1].x = _screen.cx - SL_WideScale(210,245)
	choices[2].x = _screen.cx - SL_WideScale(75,90)
	choices[3].x = _screen.cx + SL_WideScale(75,90)
	choices[4] = { name="solo", pads={ {color=GetHexColor(SL.Global.ActiveColorIndex, true), offset=0}}, x=_screen.cx + SL_WideScale(210,245) }

-- double is not a valid style in kb7 and para
elseif current_game=="kb7" or current_game=="para" then
	choices[1].x = _screen.cx-SL_WideScale(106, 140)
	choices[2].x = _screen.cx+SL_WideScale(106, 140)
	table.remove(choices, 3)
end

-- either 1 (single) or 2 (versus)
local current_index = #GAMESTATE:GetHumanPlayers()

------------------------------------------------------------------------------------

local EnableChoices = function()

	-- everything is enabled
	if PREFSMAN:GetPreference("EventMode")
	or GAMESTATE:GetCoinMode() ~= "CoinMode_Pay"
	or GAMESTATE:GetCoinMode() == "CoinMode_Pay" and GAMESTATE:GetPremium() == "Premium_2PlayersFor1Credit" then
		for i, child in ipairs( af:GetChild("") ) do
			child:aux(1)
		end
		return
	end


	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" then

		-- if both players are already joined, disable "1 Player" as a choice
		af:GetChild("")[1]:aux( (#GAMESTATE:GetHumanPlayers() == 1) and 1 or 0)

		-- double for 1 credit
		if GAMESTATE:GetPremium() == "Premium_DoubleFor1Credit" then

			-- maybe enable "2 Players"
			if GAMESTATE:EnoughCreditsToJoin()
			or #GAMESTATE:GetHumanPlayers() == 2 then
				af:GetChild("")[2]:aux(1)
			else
				af:GetChild("")[2]:aux(0)
			end

			-- enable "Double"
			af:GetChild("")[3]:aux(1)

		-- premium off
		elseif GAMESTATE:GetPremium() == "Premium_Off" then

			if GAMESTATE:EnoughCreditsToJoin()
			or #GAMESTATE:GetHumanPlayers() == 2 then
				-- enable "2 Players" and "Double"
				af:GetChild("")[2]:aux(1)
				af:GetChild("")[3]:aux(1)
			else
				-- disable "2 Players" and "Double"
				af:GetChild("")[2]:aux(0)
				af:GetChild("")[3]:aux(0)
			end
		end
	end



	-- dance solo
	if current_game=="dance" and ThemePrefs.Get("AllowDanceSolo") then
		af:GetChild("")[4]:aux(1)
	end
end

-- pass in a postive integer to get the next enabled choice to the right
-- pass in a negative integer to get the next enabled choice to the left
local GetNextEnabledChoice = function(dir)
	local start = dir > 0 and current_index+1 or #choices+current_index-1
	local stop = dir > 0 and #choices+current_index-1 or current_index+1

	for i=start, stop, dir do
		local index = ((i-1) % #choices) + 1

		if af:GetChild("")[index]:getaux()==1 then
			current_index = index
			return
		end
	end
end

local JoinOrUnjoinPlayersMaybe = function(style, player)
	-- if going into versus, ensure that both players are joined
	if style == "versus" then
		for player in ivalues( PlayerNumber ) do
			if not GAMESTATE:IsHumanPlayer(player) then GAMESTATE:JoinPlayer(player) end
		end
		return
	end

	-- if either player pressed START to choose a style, that player will have
	-- been passed into this function, and we want to unjoin the other player
	-- now for the sake of single or double
	-- if time ran out, no one will have pressed START, so unjoin whichever player
	-- isn't the MasterPlayerNumber
	player = player or GAMESTATE:GetMasterPlayerNumber()

	-- it's possible that PLAYER_1 was the MPN, but then PLAYER_2 selected single on this screen
	-- ensure that player is actually joined now to avoid having no one joined in ScreenSelectPlayMode
	if not GAMESTATE:IsHumanPlayer(player) then GAMESTATE:JoinPlayer(player) end

	-- OtherPlayer convenience table defined in _fallback/Scripts/00 init.lua
	GAMESTATE:UnjoinPlayer(OtherPlayer[player])
end

local ManageCredits = function(style)

	-- no need to deduct additional credits; just move on
	if PREFSMAN:GetPreference("EventMode")
	or PREFSMAN:GetPreference("CoinMode") ~= "CoinMode_Pay"
	or (GAMESTATE:GetCoinMode() == "CoinMode_Pay" and GAMESTATE:GetPremium() == "Premium_2PlayersFor1Credit") then
		return
	end

	-- double for 1 credit; deduct 1 credit if entering versus and only 1 player has been joined so far
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay"
	and GAMESTATE:GetPremium() == "Premium_DoubleFor1Credit"
	and #GAMESTATE:GetHumanPlayers() == 1
	and style == "versus" then
		GAMESTATE:InsertCoin( -GAMESTATE:GetCoinsNeededToJoin() )
		return
	end

	-- double for 1 credit; insert 1 credit if entering double and 2 players were joined from the title screen
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay"
	and GAMESTATE:GetPremium() == "Premium_DoubleFor1Credit"
	and #GAMESTATE:GetHumanPlayers() == 2
	and style == "double" then
		GAMESTATE:InsertCredit()
		return
	end

	-- premium off; deduct 1 credit if entering versus or double
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay"
	and GAMESTATE:GetPremium() == "Premium_Off"
	and #GAMESTATE:GetHumanPlayers() == 1
	and (style=="versus" or style=="double") then
		GAMESTATE:InsertCoin( -GAMESTATE:GetCoinsNeededToJoin() )
		return
	end
end

------------------------------------------------------------------------------------

local function input(event)
	if not event or not event.PlayerNumber or not event.button then
		return false
	end

	-- handle the case of joining an unjoined player in CoinMode_Pay
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay"
	and GAMESTATE:GetPremium() ~= "Premium_2PlayersFor1Credit"
	and GAMESTATE:EnoughCreditsToJoin()
	and not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
			-- join the player
			GAMESTATE:JoinPlayer(event.PlayerNumber)
			-- deduct a credit (it might be added back later if choosing double and DoubleFor1Credit is on)
			GAMESTATE:InsertCoin( -GAMESTATE:GetCoinsNeededToJoin() )
			-- play a sound
			af:GetChild("Start"):play()
		end
		return false
	end

	-- normal input handling
	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			local prev_index = current_index
			GetNextEnabledChoice(event.GameButton=="MenuRight" and 1 or -1)

			for i, child in ipairs( af:GetChild("") ) do
				if i == current_index then
					child:queuecommand("GainFocus")
				else
					child:queuecommand("LoseFocus")
				end
			end
			if prev_index ~= current_index then af:GetChild("Change"):play() end

		elseif event.GameButton == "Start" then
			StyleSelected = true
			af:GetChild("Start"):play()
			af:playcommand("Finish", {PlayerNumber=event.PlayerNumber})

		elseif event.GameButton == "Back" then
			topscreen:RemoveInputCallback(input)
			topscreen:Cancel()
		end
	end

	return false
end

------------------------------------------------------------------------------------

local t = Def.ActorFrame{
	InitCommand=function(self)
		af = self
		self:queuecommand("Capture")
		EnableChoices()
		self:playcommand("Enable")

		for i, child in ipairs( self:GetChild("") ) do
			if i == current_index then
				child:queuecommand("GainFocus")
			end
		end
	end,
	OnCommand=function(self)
		if PREFSMAN:GetPreference("MenuTimer") then
			self:queuecommand("Listen")
		end
	end,
	CoinModeChangedMessageCommand=function(self) self:playcommand("CoinsChanged") end,
	CoinsChangedMessageCommand=function(self)
		EnableChoices()
		-- if the current choice is no longer valid after the coin change
		if self:GetChild("")[current_index]:getaux()==0 then
			-- get the next valid choice to the right
			GetNextEnabledChoice(1)
			-- force all choices to LoseFocus
			self:playcommand("LoseFocus")
			-- and queue the new current choice to GainFocus
			self:GetChild("")[current_index]:queuecommand("GainFocus")
		end
		self:playcommand("Enable")
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()
		if seconds <= 0 and not StyleSelected then
			StyleSelected = true
			self:playcommand("Finish")
		else
			self:sleep(0.25)
			self:queuecommand("Listen")
		end
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	FinishCommand=function(self, params)
		local style = choices[current_index].name

		ManageCredits(style)
		JoinOrUnjoinPlayersMaybe(style, (params and params.PlayerNumber or nil))

		-- ah, yes, techno mode
		-- techo doesn't have styles like "single" and "double", it has "single8", "versus8", and "double8"
		if current_game=="techno" then style = style.."8" end

		-- set this now, but keep in mind that the style can change during a game session in a number
		-- of ways, like latejoin (when available) and using SSM's SortMenu to change styles mid-game
		GAMESTATE:SetCurrentStyle(style)

		for i=1, #choices do
			if i ~= current_index then
				af:GetChild("")[i]:playcommand("NotChosen")
			else
				af:GetChild("")[i]:playcommand("Chosen")
			end
		end

		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
}

for i,choice in ipairs(choices) do
	t[#t+1] = LoadActor("./choice.lua", {choice, i} )
end

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="Change", IsAction=true, SupportPan=false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="Start", IsAction=true, SupportPan=false }

return t
