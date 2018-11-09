local StyleSelected = false
local af

local current_game = GAMESTATE:GetCurrentGame():GetName()
------------------------------------------------------------------------------------

local xshift = WideScale(42,52)
local choices = {
	{ name="single", pads={{3, -xshift-14}}, x=_screen.cx-_screen.w/4 },
	{ name="versus", pads={{2, -xshift-WideScale(60,70)}, {5, xshift-WideScale(60,70)}}, x=_screen.cx },
	{ name="double", pads={{4,-xshift-WideScale(60,70)}, {4, xshift-WideScale(60,70)}}, x=_screen.cx+_screen.w/4 },
}
if current_game=="dance" and ThemePrefs.Get("AllowDanceSolo") then
	choices[1].x = _screen.w/4-_screen.w/8
	choices[2].x = (_screen.w/4)*2-_screen.w/8
	choices[3].x = (_screen.w/4)*3-_screen.w/8
	choices[4] = { name="solo", pads={ {3, -xshift-14}}, x=_screen.w-_screen.w/8 }
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
			child.Enabled = true
		end
	end

	-- double for 1 credit
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" and GAMESTATE:GetPremium() == "Premium_DoubleFor1Credit" then
		-- if both players are already joined, disable 1 Player as a choice
		af:GetChild("")[1].Enabled = (#GAMESTATE:GetHumanPlayers() == 1)

		af:GetChild("")[3].Enabled = true

		if GAMESTATE:EnoughCreditsToJoin()
		or #GAMESTATE:GetHumanPlayers() == 2 then
			af:GetChild("")[2].Enabled = true
		end
	end

	-- premium off
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" and GAMESTATE:GetPremium() == "Premium_Off" then
		-- if both players are already joined, disable 1 Player as a choice
		af:GetChild("")[1].Enabled = (#GAMESTATE:GetHumanPlayers() == 1)

		if GAMESTATE:EnoughCreditsToJoin()
		or #GAMESTATE:GetHumanPlayers() == 2 then
			af:GetChild("")[2].Enabled = true
			af:GetChild("")[3].Enabled = true
		end
	end

	-- dance solo
	if current_game=="dance" and ThemePrefs.Get("AllowDanceSolo") then
		af:GetChild("")[4].Enabled = true
	end
end

-- get next enabled choice index to the right
local GetNextEnabledRight = function()
	for i=current_index+1, #choices+current_index-1 do
		local index = ((i-1) % #choices) + 1

		if af:GetChild("")[index].Enabled then
			current_index = index
			return
		end
	end
end

-- get next enabled choice index to the left
local GetNextEnabledLeft = function()
	for i=#choices+current_index-1,current_index+1,-1 do
		local index = ((i-1) % #choices) + 1

		if af:GetChild("")[index].Enabled then
			current_index = index
			return
		end
	end
end


local JoinOrUnjoinPlayersMaybe = function(style, player)
	-- if going into versus, ensure that both players are joined
	if style == "versus" then
		for player in ivalues({PLAYER_1, PLAYER_2}) do
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

	if player == PLAYER_1 then
		GAMESTATE:UnjoinPlayer(PLAYER_2)
	else
		GAMESTATE:UnjoinPlayer(PLAYER_1)
	end
end

local ManageCredits = function(style)

	-- no need to deduct additional credits; just move on
	if PREFSMAN:GetPreference("EventMode")
	or PREFSMAN:GetPreference("CoinMode") ~= "CoinMode_Pay"
	or (GAMESTATE:GetCoinMode() == "CoinMode_Pay" and GAMESTATE:GetPremium() == "Premium_2PlayersFor1Credit") then
		return
	end

	-- double for 1 credit; deduct 1 credit if entering versus
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay"
	and GAMESTATE:GetPremium() == "Premium_DoubleFor1Credit"
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

		if event.GameButton == "MenuRight" then
			GetNextEnabledRight()
			for i, child in ipairs( af:GetChild("") ) do
				if i == current_index then
					child:queuecommand("GainFocus")
				else
					child:queuecommand("LoseFocus")
				end
			end
			af:GetChild("Change"):play()

		elseif event.GameButton == "MenuLeft" then
			GetNextEnabledLeft()
			for i, child in ipairs( af:GetChild("") ) do
				if i == current_index then
					child:queuecommand("GainFocus")
				else
					child:queuecommand("LoseFocus")
				end
			end
			af:GetChild("Change"):play()

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
	CoinsChangedMessageCommand=function(self)
		EnableChoices()
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

		GAMESTATE:SetCurrentStyle(style)
		SL.Global.Gamestate.Style = GAMESTATE:GetCurrentStyle():GetName()

		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
}

for i,choice in ipairs(choices) do
	t[#t+1] = LoadActor("./choice.lua", {choice, i} )
end

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="Change", SupportPan=false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="Start", SupportPan=false }

return t