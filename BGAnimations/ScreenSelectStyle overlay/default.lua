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

local starting_index = 1
local current_index = starting_index

local change_sound, start_sound

------------------------------------------------------------------------------------

local EnableChoices = function()
	
	-- everything is enabled
	if PREFSMAN:GetPreference("EventMode")
	or PREFSMAN:GetPreference("CoinMode") ~= "CoinMode_Pay"
	or GAMESTATE:GetCoinMode() == "CoinMode_Pay" and PREFSMAN:GetPreference("Premium") == "Premium_2PlayersFor1Credit" then
		for i, child in ipairs( af:GetChild("") ) do
			child.Enabled = true
		end
	end

	-- double for 1 credit
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" and PREFSMAN:GetPreference("Premium") == "Premium_DoubleFor1Credit" then
		af:GetChild("")[1].Enabled = true
		af:GetChild("")[3].Enabled = true
		if GAMESTATE:EnoughCreditsToJoin() then
			af:GetChild("")[2].Enabled = true
		end
	end
	
	-- premium off
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" and PREFSMAN:GetPreference("Premium") == "Premium_Off" then
		af:GetChild("")[1].Enabled = true
		if GAMESTATE:EnoughCreditsToJoin() then
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

local JoinInputMaybe = function(style)
	-- if GAMESTATE:GetNumSidesJoined()==2 then return end
	
	-- no need to deduct credits; just join player and move on
	if (PREFSMAN:GetPreference("EventMode")
	or PREFSMAN:GetPreference("CoinMode") ~= "CoinMode_Pay"
	or GAMESTATE:GetCoinMode() == "CoinMode_Pay" and PREFSMAN:GetPreference("Premium") == "Premium_2PlayersFor1Credit")
	and style == "versus" then
		for player in ivalues({PLAYER_1, PLAYER_2}) do
			if not GAMESTATE:IsHumanPlayer(player) then GAMESTATE:JoinPlayer(player) end
		end
		return
	end
	
	-- double for 1 credit
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" 
	and PREFSMAN:GetPreference("Premium") == "Premium_DoubleFor1Credit"
	and style == "versus" then
		for player in ivalues({PLAYER_1, PLAYER_2}) do
			if not GAMESTATE:IsHumanPlayer(player) then 
				GAMESTATE:JoinPlayer(player)
			end
		end
		-- deduct 1 credit
		GAMESTATE:InsertCoin( -GAMESTATE:GetCoinsNeededToJoin() )
		return
	end
	
	-- premium off
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" 
	and PREFSMAN:GetPreference("Premium") == "Premium_Off" 
	and (style=="versus" or style=="double") then
		-- if going to versus, join the unjoined player
		if style=="versus" then
			for player in ivalues({PLAYER_1, PLAYER_2}) do
				if not GAMESTATE:IsHumanPlayer(player) then 
					GAMESTATE:JoinPlayer(player)
				end
			end
		end
		
		-- either way, deduct 1 credit
		GAMESTATE:InsertCoin( -GAMESTATE:GetCoinsNeededToJoin() )
	end
	
end

------------------------------------------------------------------------------------

local function input(event)
	if not event or not event.PlayerNumber or not event.button then
		return false
	end

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
			af:GetChild("Start"):play()
			af:playcommand("Finish")

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
			if i == starting_index then
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
	FinishCommand=function(self)		
		local style = choices[current_index].name
		if style ~= "single" then JoinInputMaybe(style) end
		
		-- ah, yes, techno mode
		if current_game=="techno" then style = style.."8" end
		
		GAMESTATE:SetCurrentStyle(style)
		SL.Global.Gamestate.Style = GAMESTATE:GetCurrentStyle():GetName()

		SCREENMAN:GetTopScreen():RemoveInputCallback(input)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
	
	children = {}
}

for i,choice in ipairs(choices) do
	t.children[#t.children+1] = LoadActor("./choice.lua", {choice, i} )
end

t.children[#t.children+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="Change", SupportPan=false }
t.children[#t.children+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="Start", SupportPan=false }

return t