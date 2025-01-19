-- This is mostly copy/pasted directly from SM5's _fallback theme with
-- very minor modifications.

local t = Def.ActorFrame{
	InitCommand=function(self)
		-- In case we loaded the theme with SRPG8 and had Rainbow Mode enabled, disable it.
		if ThemePrefs.Get("VisualStyle") == "SRPG8" and ThemePrefs.Get("RainbowMode") == true then
			ThemePrefs.Set("RainbowMode", false)
			ThemePrefs.Save()
		end
	end
}

-- -----------------------------------------------------------------------

local function CreditsText( player )
	return LoadFont("Common Normal") .. {
		InitCommand=function(self)
			self:visible(false)
			self:name("Credits" .. PlayerNumberToString(player))
			ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen")
		end,
		VisualStyleSelectedMessageCommand=function(self) self:playcommand("UpdateVisible") end,
		UpdateTextCommand=function(self)
			-- this feels like a holdover from SM3.9 that just never got updated
			local str = ScreenSystemLayerHelpers.GetCreditsMessage(player)
			self:settext(str)
		end,
		UpdateVisibleCommand=function(self)
			local screen = SCREENMAN:GetTopScreen()
			local bShow = true

			local textColor = Color.White
			local shadowLength = 0

			if screen then
				bShow = THEME:GetMetric( screen:GetName(), "ShowCreditDisplay" )

				local screenName = screen:GetName()
				if screenName == "ScreenTitleMenu" or screenName == "ScreenTitleJoin" or screenName == "ScreenLogo" then
					if ThemePrefs.Get("VisualStyle") == "SRPG8" then
						textColor = color(SL.SRPG8.TextColor)
						shadowLength = 0.4
					end
				elseif (screen:GetName() == "ScreenEvaluationStage") or (screen:GetName() == "ScreenEvaluationNonstop") or (screen:GetName() == "ScreenGameplay") then
					-- ignore ShowCreditDisplay metric for ScreenEval
					-- only show this BitmapText actor on Evaluation if the player is joined
					bShow = GAMESTATE:IsHumanPlayer(player)
					--        I am not human^
					--        today, but there's always hope
					--        I'll see tomorrow

					-- dark text for RainbowMode
					if ThemePrefs.Get("RainbowMode") then
						textColor = Color.Black
					end
				end
			end

			self:visible( bShow )
			self:diffuse(textColor)
			self:shadowlength(shadowLength)
		end
	}
end

-- -----------------------------------------------------------------------
-- player avatars
-- see: https://youtube.com/watch?v=jVhlJNJopOQ

for player in ivalues(PlayerNumber) do
	t[#t+1] = Def.Sprite{
		ScreenChangedMessageCommand=function(self)   self:queuecommand("Update") end,
		PlayerJoinedMessageCommand=function(self, params)   if params.Player==player then self:queuecommand("Update") end end,
		PlayerUnjoinedMessageCommand=function(self, params) if params.Player==player then self:queuecommand("Update") end end,
		PlayerProfileSetMessageCommand=function(self, params) if params.Player==player then self:queuecommand("Update") end end,

		UpdateCommand=function(self)
			local path = GetPlayerAvatarPath(player)

			if path == nil and self:GetTexture() ~= nil then
				self:Load(nil):diffusealpha(0):visible(false)
				return
			end

			-- only read from disk if not currently set or if the path has changed
			if self:GetTexture() == nil or path ~= self:GetTexture():GetPath() then
				self:Load(path):finishtweening():linear(0.075):diffusealpha(1)

				local dim = 32
				local h   = (player==PLAYER_1 and left or right)
				local x   = (player==PLAYER_1 and    0 or _screen.w)

				self:horizalign(h):vertalign(bottom)
				self:xy(x, _screen.h):setsize(dim,dim)
			end

			local screen = SCREENMAN:GetTopScreen()
			if screen then
				if THEME:HasMetric(screen:GetName(), "ShowPlayerAvatar") then
					self:visible( THEME:GetMetric(screen:GetName(), "ShowPlayerAvatar") )
				else
					self:visible( THEME:GetMetric(screen:GetName(), "ShowCreditDisplay") )
				end
			end
		end,
	}
end

-- -----------------------------------------------------------------------

-- what is aux?
t[#t+1] = LoadActor(THEME:GetPathB("ScreenSystemLayer","aux"))

-- Credits
t[#t+1] = Def.ActorFrame {
 	CreditsText( PLAYER_1 ),
	CreditsText( PLAYER_2 )
}

-- "Event Mode" or CreditText at lower-center of screen
t[#t+1] = LoadFont("Common Footer")..{
	InitCommand=function(self) self:xy(_screen.cx, _screen.h-16):zoom(0.5):horizalign(center) end,

	OnCommand=function(self) self:playcommand("Refresh") end,
	ScreenChangedMessageCommand=function(self) self:playcommand("Refresh") end,
	CoinModeChangedMessageCommand=function(self) self:playcommand("Refresh") end,
	CoinsChangedMessageCommand=function(self) self:playcommand("Refresh") end,
	VisualStyleSelectedMessageCommand=function(self) self:playcommand("Refresh") end,

	RefreshCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()

		-- if this screen's Metric for ShowCreditDisplay=false, then hide this BitmapText actor
		-- PS: "ShowCreditDisplay" isn't a real Metric as far as the engine is concerned.
		-- I invented it for Simply Love and it has (understandably) confused other themers.
		-- Sorry about this.
		if screen then
			self:visible( THEME:GetMetric( screen:GetName(), "ShowCreditDisplay" ) )
		end

		if PREFSMAN:GetPreference("EventMode") then
			self:settext( THEME:GetString("ScreenSystemLayer", "EventMode") )

		elseif GAMESTATE:GetCoinMode() == "CoinMode_Pay" then
			local credits = GetCredits()
			local text

			if credits.CoinsPerCredit > 1 then
				text = ("%s     %d     %d/%d"):format(
					THEME:GetString("ScreenSystemLayer", "CreditsCredits"),
					credits.Credits,
					credits.Remainder,
					credits.CoinsPerCredit
				)
			else
				text = ("%s     %d"):format(
					THEME:GetString("ScreenSystemLayer", "CreditsCredits"),
					credits.Credits
				)
			end

			self:settext(text)

		elseif GAMESTATE:GetCoinMode() == "CoinMode_Free" then
			self:settext( THEME:GetString("ScreenSystemLayer", "FreePlay") )

		elseif GAMESTATE:GetCoinMode() == "CoinMode_Home" then
			self:settext('')
		end

		local textColor = Color.White
		local screenName = screen:GetName()
		if screen ~= nil and (screenName == "ScreenTitleMenu" or screenName == "ScreenTitleJoin" or screenName == "ScreenLogo") then
			if ThemePrefs.Get("VisualStyle") == "SRPG8" then
				textColor = color(SL.SRPG8.TextColor)
			end
		end
		self:diffuse(textColor)
	end
}

-- -----------------------------------------------------------------------
-- Modules

local function LoadModules()
	-- A table that contains a [ScreenName] -> Table of Actors mapping.
	-- Each entry will then be converted to an ActorFrame with the actors as children.
	local modules = {}
	local files = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory().."Modules/")
	for file in ivalues(files) do
		-- Get the file extension (everything past the last period).
		local filetype = file:match("[^.]+$"):lower()
		if filetype == "lua" then
			local full_path = THEME:GetCurrentThemeDirectory().."Modules/"..file
			Trace("Loading module: "..full_path)

			-- Load the Lua file as proper lua.
			local loaded_module, error = loadfile(full_path)
			if loaded_module then
				local status, ret = pcall(loaded_module)
				if status then
					if ret ~= nil then
						for screenName, actor in pairs(ret) do
							if modules[screenName] == nil then
								modules[screenName] = {}
							end
							modules[screenName][#modules[screenName]+1] = actor
						end
					end
				else
					lua.ReportScriptError("Error executing module: "..full_path.." with error:\n    "..ret)
				end
			else
				lua.ReportScriptError("Error loading module: "..full_path.." with error:\n    "..error)
			end
		end
	end

	for screenName, table_of_actors in pairs(modules) do
		local module_af = Def.ActorFrame {
			ScreenChangedMessageCommand=function(self)
				local screen = SCREENMAN:GetTopScreen()
				if screen then
					local name = screen:GetName()
					if name == screenName then
						self:visible(true)
						self:queuecommand("Module")
					else
						self:visible(false)
					end
				else
					self:visible(false)
				end
			end,
		}
		for actor in ivalues(table_of_actors) do
			module_af[#module_af+1] = actor
		end
		t[#t+1] = module_af
	end
end

LoadModules()

-- -----------------------------------------------------------------------
-- The GrooveStats service info pane.
-- We put this in ScreenSystemLayer because if people move through the menus too fast,
-- it's possible that the available services won't be updated before one starts the set.
-- This allows us to set available services "in the background" as we're moving
-- through the menus.

local NewSessionRequestProcessor = function(res, gsInfo)
	if gsInfo == nil then return end
	
	local groovestats = gsInfo:GetChild("GrooveStats")
	local service1 = gsInfo:GetChild("Service1")
	local service2 = gsInfo:GetChild("Service2")
	local service3 = gsInfo:GetChild("Service3")

	service1:visible(false)
	service2:visible(false)
	service3:visible(false)

	SL.GrooveStats.IsConnected = false
	if res.error or res.statusCode ~= 200 then
		local error = res.error and ToEnumShortString(res.error) or nil
		if error == "Timeout" then
			groovestats:settext("Timed Out")
		elseif error or (res.statusCode ~= nil and res.statusCode ~= 200) then
			local text = ""
			if error == "Blocked" then
				text = "Access to GrooveStats Host Blocked"
			elseif error == "CannotConnect" then
				text = "Machine Offline"
			elseif error == "Timeout" then
				text = "Request Timed Out"
			else
				text = "Failed to Load 😞"
			end
			service1:settext(text):visible(true)


			-- These default to false, but may have changed throughout the game's lifetime.
			-- It doesn't hurt to explicitly set them to false.
			SL.GrooveStats.GetScores = false
			SL.GrooveStats.Leaderboard = false
			SL.GrooveStats.AutoSubmit = false
			groovestats:settext("❌ GrooveStats")

			DiffuseEmojis(service1:ClearAttributes())
		end
		DiffuseEmojis(groovestats:ClearAttributes())
		return
	end

	local data = JsonDecode(res.body)
	if data == nil then return end

	local services = data["servicesAllowed"]
	if services ~= nil then
		local serviceCount = 1

		if services["playerScores"] ~= nil then
			if services["playerScores"] then
				SL.GrooveStats.GetScores = true
			else
				local curServiceText = gsInfo:GetChild("Service"..serviceCount)
				curServiceText:settext("❌ Get Scores"):visible(true)
				serviceCount = serviceCount + 1
				SL.GrooveStats.GetScores = false
			end
		end

		if services["playerLeaderboards"] ~= nil then
			if services["playerLeaderboards"] then
				SL.GrooveStats.Leaderboard = true
			else
				local curServiceText = gsInfo:GetChild("Service"..serviceCount)
				curServiceText:settext("❌ Leaderboard"):visible(true)
				serviceCount = serviceCount + 1
				SL.GrooveStats.Leaderboard = false
			end
		end

		if services["scoreSubmit"] ~= nil then
			if services["scoreSubmit"] then
				SL.GrooveStats.AutoSubmit = true
			else
				local curServiceText = gsInfo:GetChild("Service"..serviceCount)
				curServiceText:settext("❌ Auto-Submit"):visible(true)
				serviceCount = serviceCount + 1
				SL.GrooveStats.AutoSubmit = false
			end
		end
	end

	local events = data["activeEvents"]
	local easter_eggs = PREFSMAN:GetPreference("EasterEggs")
	local game = GAMESTATE:GetCurrentGame():GetName()
	local style = ThemePrefs.Get("VisualStyle")
	if events ~= nil and easter_eggs and game == "dance" then
		local last_active_event = ThemePrefs.Get("LastActiveEvent")

		for event in ivalues(events) do
			if event["shortName"] == "SRPG8" then
				-- If we're already on the SRPG8 theme, then set the last_active_event
				-- if it's not already set to SRPG so that we don't bring up the prompt.
				if last_active_event ~= "SRPG8" and style == "SRPG8" then
					ThemePrefs.Set("LastActiveEvent", "SRPG8")
					last_active_event = "SRPG8"
				end
			
				if last_active_event ~= "SRPG8" then
					local top_screen = SCREENMAN:GetTopScreen()
					top_screen:SetNextScreenName("ScreenPromptToSetSrpgVisualStyle"):StartTransitioningScreen("SM_GoToNextScreen")
					break
				end
			end
		end
	end

	-- All services are enabled, display a green check.
	if SL.GrooveStats.GetScores and SL.GrooveStats.Leaderboard and SL.GrooveStats.AutoSubmit then
		groovestats:settext("✔ GrooveStats")
		SL.GrooveStats.IsConnected = true
	-- All services are disabled, display a red X.
	elseif not SL.GrooveStats.GetScores and not SL.GrooveStats.Leaderboard and not SL.GrooveStats.AutoSubmit then
		groovestats:settext("❌ GrooveStats")
		-- We would've displayed the individual failed services, but if they're all down then hide the group.
		service1:visible(false)
		service2:visible(false)
		service3:visible(false)
	-- Some combination of the two, we display a caution symbol.
	else
		groovestats:settext("⚠ GrooveStats")
		SL.GrooveStats.IsConnected = true
	end

	DiffuseEmojis(groovestats:ClearAttributes())
	DiffuseEmojis(service1:ClearAttributes())
	DiffuseEmojis(service2:ClearAttributes())
	DiffuseEmojis(service3:ClearAttributes())
end

local function DiffuseText(bmt)
	local textColor = Color.White
	local shadowLength = 0
	if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
		textColor = Color.Black
	end
	if ThemePrefs.Get("VisualStyle") == "SRPG8" then
		textColor = color(SL.SRPG8.TextColor)
		shadowLength = 0.4
	end

	bmt:diffuse(textColor):shadowlength(shadowLength)
end

t[#t+1] = Def.ActorFrame{
	Name="GrooveStatsInfo",
	InitCommand=function(self)
		-- Put the info in the top right corner.
		self:zoom(0.8):x(10):y(15)
	end,
	ScreenChangedMessageCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		if screen:GetName() == "ScreenTitleMenu" or screen:GetName() == "ScreenTitleJoin" then
			self:queuecommand("Reset")
			self:diffusealpha(0):sleep(0.2):linear(0.4):diffusealpha(1):visible(true)
			self:queuecommand("SendRequest")
		else
			self:visible(false)
		end
	end,

	LoadFont("Common Normal")..{
		Name="GrooveStats",
		Text="     GrooveStats",
		InitCommand=function(self)
			self:visible(ThemePrefs.Get("EnableGrooveStats"))
			self:horizalign(left)
			DiffuseText(self)
		end,
		VisualStyleSelectedMessageCommand=function(self) DiffuseText(self) end,
		ResetCommand=function(self)
			self:visible(ThemePrefs.Get("EnableGrooveStats"))
			self:settext("     GrooveStats")
		end
	},

	LoadFont("Common Normal")..{
		Name="Service1",
		Text="",
		InitCommand=function(self)
			self:visible(true):addy(18):horizalign(left)
			DiffuseText(self)
		end,
		VisualStyleSelectedMessageCommand=function(self) DiffuseText(self) end,
		ResetCommand=function(self) self:settext("") end
	},

	LoadFont("Common Normal")..{
		Name="Service2",
		Text="",
		InitCommand=function(self)
			self:visible(true):addy(36):horizalign(left)
			DiffuseText(self)
		end,
		VisualStyleSelectedMessageCommand=function(self) DiffuseText(self) end,
		ResetCommand=function(self) self:settext("") end
	},

	LoadFont("Common Normal")..{
		Name="Service3",
		Text="",
		InitCommand=function(self)
			self:visible(true):addy(54):horizalign(left)
			DiffuseText(self)
		end,
		VisualStyleSelectedMessageCommand=function(self) DiffuseText(self) end,
		ResetCommand=function(self) self:settext("") end
	},

	RequestResponseActor(5, 0)..{
		SendRequestCommand=function(self)
			if ThemePrefs.Get("EnableGrooveStats") then
				-- These default to false, but may have changed throughout the game's lifetime.
				-- Reset these variable before making a request.
				SL.GrooveStats.GetScores = false
				SL.GrooveStats.Leaderboard = false
				SL.GrooveStats.AutoSubmit = false
				self:playcommand("MakeGrooveStatsRequest", {
					endpoint="new-session.php?chartHashVersion="..SL.GrooveStats.ChartHashVersion,
					method="GET",
					timeout=10,
					callback=NewSessionRequestProcessor,
					args=self:GetParent()
				})
			end
		end
	}
}

-- -----------------------------------------------------------------------
-- Loads the UnlocksCache from disk for SRPG unlocks.
LoadUnlocksCache()


-- -----------------------------------------------------------------------
-- ALL ONLINE PLAY SOCKET STUFF

local isWaiting = false
local readyState = {
	["P1"] = true,
	["P2"] = true
}
local songSelected = false
-- These screens are the ones we want to display the player's scores for.
local scoreScreens = {"ScreenGameplay", "ScreenEvaluationStage"}

-- TESTING Variables
local url = "127.0.0.1"
local roomCode = ""
local action = "create" -- "create" or "join"
local autoConnect = true

-- This input handler is used to lock input while we're waiting on the server to tell us to proceed.
-- It does nothing, but it's necessary to prevent the player from interacting with the screen
-- until everyone is ready.
local InputHandler = function(event)
	if SCREENMAN:GetTopScreen() and SCREENMAN:GetTopScreen():GetName() == "ScreenGameplay" and isWaiting then
		if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
			local pn = ToEnumShortString(event.PlayerNumber)
			readyState[pn] = true

			MESSAGEMAN:Broadcast("UpdateMachineState")
		end
	end
	
	return false
end

local CreateRequest = function(event, data)
	return JsonEncode({
		event=event,
		data=data
	})
end

local GetJudgmentCounts = function(player)
	local counts = GetExJudgmentCounts(player)
	local translation = {
		["W0"] = "fantasticPlus",
		["W1"] = "fantastics",
		["W2"] = "excellents",
		["W3"] = "greats",
		["W4"] = "decents",
		["W5"] = "wayOffs",
		["Miss"] = "misses",
		["totalSteps"] = "totalSteps",
		["Mines"] = "minesHit",
		["totalMines"] = "totalMines",
		["Holds"] = "holdsHeld",
		["totalHolds"] = "totalHolds",
		["Rolls"] = "rollsHeld",
		["totalRolls"] = "totalRolls"
	}

	local judgmentCounts = {}

	for key, value in pairs(counts) do
		if translation[key] ~= nil then
			judgmentCounts[translation[key]] = value
		end
	end

	return judgmentCounts
end

local GetMachineState = function()
	-- NOTE(teejusb): Keep in mind that SCREENMAN:GetTopScreen() might return nil since we might be
	-- transitioning screens when we receive any messages from the server.

	local screen = SCREENMAN:GetTopScreen()
	-- Use a "NoScreen" fallback in case we're transitioning screens.
	local screenName = screen and screen:GetName() or "NoScreen"

	local players = {}
	for player in ivalues(GAMESTATE:GetEnabledPlayers()) do
		local profileName = "NoName"
		if (PROFILEMAN:IsPersistentProfile(player) and
				PROFILEMAN:GetProfile(player)) then
			profileName = PROFILEMAN:GetProfile(player):GetDisplayName()
		end

		local judgments = nil
		local score = nil
		local exScore = nil
		if screenName == "ScreenGameplay" or screenName == "ScreenEvaluationStage" then
			judgments = GetJudgmentCounts(player)
			local dance_points = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints()
			local percent = FormatPercentScore( dance_points ):gsub("%%", "")
			score = tonumber(percent)
			exScore = CalculateExScore(player)
		end

		local pn = ToEnumShortString(player)
		players[pn] = {
			playerId = pn,
			profileName = profileName,
			screenName=screenName,
			ready=readyState[pn],

			judgments = judgments,
			score = score,
			exScore = exScore,
			-- TODO(teejusb): Add song progression.
		}
	end

	-- If "P1"/"P2" is missing from players, then the player isn't enabled and the corresponding
	-- player1/player2 key will be nil.
	return {
		machine = {
			player1=players["P1"],
			player2=players["P2"]
		}
	}
end

local OrderPlayers = function(data)
	local updatedData = {
		players = {},

		-- Additional data that we can pre-calculate.
		aux = {
			-- Used to give input back to the players if we're waiting.
			allInSameScreen = true,
			-- Used to determine when to display the Ready/Not Ready state for players.
			allPlayersReady = true,
		}
	}

	--  Copy over the song info, if any.
	updatedData.songInfo = data.songInfo

	local firstScreen = nil
	-- Process the scoreScreens first so we can sort the players by score.
	for player in ivalues(data.players) do
		if firstScreen == nil then
			firstScreen = player.screenName
		end

		if player.screenName ~= firstScreen then
			updatedData.aux.allInSameScreen = false
		end

		if not player.ready then
			updatedData.aux.allPlayersReady = false
		end

		for screen in ivalues(scoreScreens) do
			if player.screenName == screen then
				updatedData.players[#updatedData.players+1] = player
				break
			end
		end
	end

	-- Sort the players by score.
	-- TODO(teejusb): Determine how to do toggle between score and exScore.
	table.sort(updatedData.players, function(a, b)
		-- a.score or b.score can be nil, so we need to handle that.
		if a.score == nil then
			return false
		end
		if b.score == nil then
			return true
		end
		return a.score > b.score
	end)

	-- Then add all the other players in other screens below.
	for player in ivalues(data.players) do
		if firstScreen == nil then
			firstScreen = player.screenName
		end

		if player.screenName ~= firstScreen then
			updatedData.aux.allInSameScreen = false
		end

		if not player.ready then
			updatedData.aux.allPlayersReady = false
		end

		local inScoreScreen = false
		for screen in ivalues(scoreScreens) do
			if player.screenName == screen then
				inScoreScreen = true
				break
			end
		end

		if not inScoreScreen then
			updatedData.players[#updatedData.players+1] = player
		end
	end

	return updatedData
end

local DisplayLobbyState = function(data, actor)
	-- NOTE(teejusb): Keep in mind that SCREENMAN:GetTopScreen() might return nil since we might be
	-- transitioning screens when we receive any messages from the server.
	local screen = SCREENMAN:GetTopScreen()
	local screenName = screen and screen:GetName() or "NoScreen"

	local updatedData = OrderPlayers(data)

	local lines = {}

	if isWaiting then
		if updatedData.aux.allPlayersReady then
			isWaiting = false
			-- Lift the lock.
			-- SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)

			-- The below does work, but it's currently possible that other screens are resetting this early.
			for player in ivalues(PlayerNumber) do
				SCREENMAN:set_input_redirected(player, false)
			end
		else
			lines[#lines+1] = "Waiting for players...\n"
		end
	end

	for player in ivalues(updatedData.players) do
		local displayedScreen = player.screenName ~= "NoScreen" and player.screenName:gsub("Screen", "") or "Transitioning"
		local readyText = ""
		if not updatedData.aux.allPlayersReady then
			readyText =" ["..(player.ready and "✔" or "❌").."]"
		end

		local playerAndScreen = (#lines+1)..'. '..player.profileName..readyText.." - in "..displayedScreen

		lines[#lines+1] = playerAndScreen
		for scoreScreen in ivalues(scoreScreens) do
			if player.screenName == scoreScreen then
				-- Display the score and EX score.
				local score = (player.score ~= nil and player.score) or 0
				local exScore = (player.exScore ~= nil and player.exScore) or 0

				local scoreStr = string.format("%.2f", score).."%"
				local exScoreStr = string.format("%.2f", exScore).."%"

				lines[#lines+1] = "    "..scoreStr.." - "..exScoreStr.." EX"
				break
			end
		end

		-- Add a new line between players.
		lines[#lines+1] = ""
	end

	if data.songInfo ~= nil then
		if not songSelected then
			local topScreen = SCREENMAN:GetTopScreen()
			if topScreen and topScreen:GetName() == "ScreenSelectMusic" then
				local song = SONGMAN:FindSong(data.songInfo.songPath)
				local wheel = topScreen:GetMusicWheel()
				if song and wheel then
					wheel:SelectSong(song)
					wheel:Move(1)
					wheel:Move(-1)
					wheel:Move(0)
				end
			end
		else
			lines[#lines+1] = "Song: "..data.songInfo.songPath
		end
	end

	-- This gets cleared out by the server when every player has arrived at the song selection screen.
	songSelected = (data.songInfo ~= nil)

	actor:GetChild("Display"):playcommand("UpdateText", {text=table.concat(lines, "\n")})
end

local HandleResponse = function(response, actor)
	local event = response.event
	local data = response.data

	if event == "lobbyState" then
		DisplayLobbyState(data, actor)
	end
end

t[#t+1] = Def.ActorFrame{
	Name="OnlineWebsocketHandler",
	InitCommand=function(self)
		self.socket = nil
		self.connected = false
	end,
	ConnectOnlineMessageCommand=function(self)
		if autoConnect and self.socket == nil then
			self.socket = NETWORK:WebSocket{
				url="ws://"..url..":3000",
				pingInterval=15,
				automaticReconnect=true,
				onMessage=function(msg)
					local msgType = ToEnumShortString(msg.type)
					if msgType == "Open" then
						self.connected = true
						if action == "join" then
							MESSAGEMAN:Broadcast("JoinLobby")
						elseif action == "create" then
							MESSAGEMAN:Broadcast("CreateLobby")
						end
					elseif msgType == "Message" then
						local response = JsonDecode(msg.data)
						HandleResponse(response, self)
					elseif msgType == "Close" then
						MESSAGEMAN:Broadcast("DisconnectOnline")
					end
				end,
			}

			self:GetChild("Display"):visible(true)
		end
	end,
	ScreenChangedMessageCommand=function(self)
		if self.connected and self.socket ~= nil then
			local screen = SCREENMAN:GetTopScreen()
			local screenName = screen and screen:GetName() or "NoScreen"

			-- When users navigate to any of these screens, we want to wait for the other player to be ready.
			if screenName == "ScreenSelectMusic" or screenName == "ScreenGameplay" or screenName == "ScreenEvaluationStage" then
				isWaiting = true

				-- The below does work, but it's currently possible that other screens are resetting this early.
				for player in ivalues(PlayerNumber) do
					SCREENMAN:set_input_redirected(player, true)
				end
			end

			if screenName == "ScreenGameplay" then
				readyState["P1"] = false
				readyState["P2"] = false
				-- Input callbacks get cleared out when we transition screens, so we don't need to worry about explicitly removing it.
				SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
				SCREENMAN:GetTopScreen():PauseGame(true)
			end

			MESSAGEMAN:Broadcast("UpdateMachineState")
		end
	end,
	UpdateMachineStateMessageCommand=function(self)
		if self.connected and self.socket ~= nil then	
			local request = CreateRequest("updateMachine", GetMachineState())
			self.socket:Send(request)
		end
	end,
	ExCountsChangedMessageCommand=function(self)
		if self.connected and self.socket ~= nil then	
			local request = CreateRequest("updateMachine", GetMachineState())
			self.socket:Send(request)
		end
	end,
	SongSelectedMessageCommand=function(self)
		if self.connected and self.socket ~= nil then
			local song = GAMESTATE:GetCurrentSong()
			-- GetSongDir returns /Songs/<Group>/<Song>/
			-- We convert it to: <Group>/<Song>
			local songPath = song:GetSongDir()
			songPath = songPath:sub(8, #songPath-1)

			local data = {
				songInfo = {
					songPath=songPath,
					title=song:GetDisplayFullTitle(),
					artist=song:GetDisplayArtist(),
					songLength=song:MusicLengthSeconds()
				}
			}
			local request = CreateRequest("selectSong", data)
			self.socket:Send(request)
		end
	end,
	JoinLobbyMessageCommand=function(self, params)
		if self.connected and self.socket ~= nil then
			local data = GetMachineState()
			data.code = params.code and params.code or roomCode
			data.password = params.password and params.password or ""
			local request = CreateRequest("joinLobby", data)
			self.socket:Send(request)
		end
	end,
	CreateLobbyMessageCommand=function(self)
		if self.connected and self.socket ~= nil then
			local data = GetMachineState()
			data.password = ""
			local request = CreateRequest("createLobby", data)
			self.socket:Send(request)
		end
	end,
	DisconnectOnlineMessageCommand=function(self)
		if self.socket ~= nil then
			self.socket:Close()
		end
		self.connected = false
		self.socket = nil
		self:GetChild("Display"):visible(false)
	end,

	Def.ActorFrame{
		Name="Display",
		InitCommand=function(self)
			self:visible(false)
		end,

		UpdateTextCommand=function(self, params)
			local screen = SCREENMAN:GetTopScreen()
			local screenName = screen and screen:GetName() or "NoScreen"

			local bg = self:GetChild("Background")
			local width = 200
			local height = SCREEN_HEIGHT

			-- Some generic constants for easy positioning.
			local LEFT = width/2
			local RIGHT = SCREEN_WIDTH - width/2
			local CENTER = _screen.cx

			-- If we're on a different screen, we'll just retain the last position.
			if screenName == "ScreenSelectMusic" then
				local p1Joined = GAMESTATE:IsSideJoined("PlayerNumber_P1")
				local p2Joined = GAMESTATE:IsSideJoined("PlayerNumber_P2")

				-- If both are joined then push it to the left so keep it out of the way.
				self:xy(LEFT, _screen.cy)
				bg:zoomto(width, height)
			elseif screenName == "ScreenEvaluationStage" or screenName == "ScreenGameplay" then
				local p1Joined = GAMESTATE:IsSideJoined("PlayerNumber_P1")
				local p2Joined = GAMESTATE:IsSideJoined("PlayerNumber_P2")

				if p1Joined and p2Joined then
					self:xy(CENTER, _screen.cy)
					bg:zoomto(width, height)
				elseif p1Joined then
					self:xy(RIGHT, _screen.cy)
					bg:zoomto(width, height)
				elseif p2Joined then
					self:xy(LEFT, _screen.cy)
					bg:zoomto(width, height)
				end
			end

			self:GetChild("Text"):playcommand("Resize", {width=width, height=height, text=params.text})
		end,

		Def.Quad{
			Name="Background",
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH / 3, SCREEN_HEIGHT):diffuse(0, 0, 0, 0.5):y(_screen.cy)
			end,
		},

		LoadFont("Common Normal").. {
			Name="Text",
			Text="",
			ResizeCommand=function(self, params)
				self:settext(params.text)
				-- We don't want text to be cut off.
				-- Incrementally adjust the zoom while checking the width until it fits.
				-- Not the prettiest solution but it works.
				for zoomVal=1.0, 0.1, -0.05 do
					self:zoom(zoomVal)
					self:settext(params.text)
					if self:GetWidth() * zoomVal <= params.width then
						break
					end
				end
			end
		},
	},
}


-- -----------------------------------------------------------------------
-- SystemMessage stuff.
-- Put it on top of everything
-- this is what appears when someone uses SCREENMAN:SystemMessage(text)
-- or MESSAGEMAN:Broadcast("SystemMessage", {text})
-- or SM(text)

local bmt = nil

-- SystemMessage ActorFrame
t[#t+1] = Def.ActorFrame {
	SystemMessageMessageCommand=function(self, params)
		bmt:settext( params.Message )

		self:playcommand( "On" )
		if params.NoAnimate then
			self:finishtweening()
		end
		self:playcommand( "Off", params )
	end,
	HideSystemMessageMessageCommand=function(self) self:finishtweening() end,

	-- background quad behind the SystemMessage
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(_screen.w, 30)
			self:horizalign(left):vertalign(top)
			self:diffuse(0,0,0,0)
		end,
		OnCommand=function(self)
			self:finishtweening():diffusealpha(0.85)
			self:zoomto(_screen.w, (bmt:GetHeight() + 16) * SL_WideScale(0.8, 1) )
		end,
		OffCommand=function(self, params)
			-- use 3.33 seconds as a default duration if none was provided as the second arg in SM()
			self:sleep(type(params.Duration)=="number" and params.Duration or 3.33):linear(0.25):diffusealpha(0)
		end,
	},

	-- BitmapText for the SystemMessage
	LoadFont("Common Normal")..{
		Name="Text",
		InitCommand=function(self)
			bmt = self

			self:maxwidth(_screen.w-20)
			self:horizalign(left):vertalign(top):xy(10, 10)
			self:diffusealpha(0):zoom(SL_WideScale(0.8, 1))
		end,
		OnCommand=function(self)
			self:finishtweening():diffusealpha(1)
		end,
		OffCommand=function(self, params)
			-- use 3 seconds as a default duration if none was provided as the second arg in SM()
			self:sleep(type(params.Duration)=="number" and params.Duration or 3):linear(0.5):diffusealpha(0)
		end,
	}
}
-- -----------------------------------------------------------------------

return t
