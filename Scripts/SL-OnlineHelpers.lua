-- -----------------------------------------------------------------------
-- ALL ONLINE PLAY SOCKET STUFF

local isWaiting = false
local readyState = {
	["P1"] = true,
	["P2"] = true
}
local songSelected = false
-- Track Start button hold time for disconnect
local startHoldTime = {
	["P1"] = 0,
	["P2"] = 0
}
local lastDisconnectCountdown = nil
-- These screens are the ones we want to display the player's scores for.
local scoreScreens = {"ScreenGameplay", "ScreenEvaluationStage"}

local syncLockScreens = {
	["ScreenSelectMusic"] = true,
	["ScreenGameplay"] = true,
	["ScreenEvaluationStage"] = true,
}

local autoReadyScreens = {
	["ScreenSelectMusic"] = true,
	["ScreenEvaluationStage"] = true,
}

local knownDisconnectScreens = {
  ["ScreenTitleMenu"] = true,
  ["ScreenGameOver"] = true,
  ["ScreenNameEntryTraditional"] = true,
  ["ScreenOptionsService"] = true,
}

-- TESTING Variables
local host = "syncservice.groovestats.com"
local port = 1337

-- This input handler is used to lock input while we're waiting on the server to tell us to proceed.
-- It does nothing, but it's necessary to prevent the player from interacting with the screen
-- until everyone is ready.
-- Holding Start for 5 seconds will disconnect from the lobby.
local InputHandler = function(event)
	if SCREENMAN:GetTopScreen() and isWaiting and event.PlayerNumber then
		local pn = ToEnumShortString(event.PlayerNumber)
		if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
			startHoldTime[pn] = GetTimeSinceStart()
			lastDisconnectCountdown = nil
			if SCREENMAN:GetTopScreen():GetName() == "ScreenGameplay" then
				readyState[pn] = true
				MESSAGEMAN:Broadcast("UpdateMachineState")
			end
		elseif event.type == "InputEventType_Repeat" and event.GameButton == "Start" then
			-- Check if Start has been held for 5 seconds
			if startHoldTime[pn] > 0 then
				local holdDuration = GetTimeSinceStart() - startHoldTime[pn]
				local remainingSeconds = math.max(0, 5 - math.floor(holdDuration))
				if remainingSeconds ~= lastDisconnectCountdown then
					SM("Continue holding &START; for " .. remainingSeconds .. " more seconds to disconnect...")
					lastDisconnectCountdown = remainingSeconds
				end
				if holdDuration >= 5.0 then
					SM("Disconnected from lobby.")
					startHoldTime[pn] = 0
					lastDisconnectCountdown = nil
					isWaiting = false
					if SCREENMAN:GetTopScreen():GetName() == "ScreenGameplay" then
						SCREENMAN:GetTopScreen():PauseGame(false)
					end
					MESSAGEMAN:Broadcast("DisconnectOnline")
				end
			end
		elseif event.type == "InputEventType_Release" and event.GameButton == "Start" then
			startHoldTime[pn] = 0
			lastDisconnectCountdown = nil
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
		if GAMESTATE:IsSideJoined(player) then
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

local OrderPlayers = function(data, localScreenName)
	local updatedData = {
		players = {},

		-- Additional data that we can pre-calculate.
		aux = {
			-- Used to give input back to the players if we're waiting.
			allInSameScreen = true,
			-- Evaluation should stay locked only while any player is still in gameplay.
			anyInGameplay = false,
			-- Used to determine when to display the Ready/Not Ready state for players.
			allPlayersReady = true,
		}
	}

	--  Copy over the song info, if any.
	updatedData.songInfo = data.songInfo

	-- Use the current screen as the baseline to prevent
	-- incorrectly reporting all players as synchronized.
	local firstScreen = localScreenName
	-- Process the scoreScreens first so we can sort the players by score.
	for player in ivalues(data.players) do
		if firstScreen == nil then
			firstScreen = player.screenName
		end

		if player.screenName ~= firstScreen then
			updatedData.aux.allInSameScreen = false
		end

		if player.screenName == "ScreenGameplay" then
			updatedData.aux.anyInGameplay = true
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
		-- a.exScore or b.exScore can be nil, so we need to handle that.
		if a.exScore == nil then
			return false
		end
		if b.exScore == nil then
			return true
		end
		return a.exScore > b.exScore
	end)

	-- Then add all the other players in other screens below.
	for player in ivalues(data.players) do
		if firstScreen == nil then
			firstScreen = player.screenName
		end

		if player.screenName ~= firstScreen then
			updatedData.aux.allInSameScreen = false
		end

		if player.screenName == "ScreenGameplay" then
			updatedData.aux.anyInGameplay = true
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

	local updatedData = OrderPlayers(data, screenName)

	local lines = {}

	if isWaiting then
		local readyToUnlock = false
		if screenName == "ScreenGameplay" then
			-- Gameplay requires everyone to be in gameplay and manually ready-up.
			readyToUnlock = updatedData.aux.allInSameScreen and updatedData.aux.allPlayersReady
		elseif screenName == "ScreenEvaluationStage" then
			-- Evaluation should only be blocked while someone is still playing.
			readyToUnlock = not updatedData.aux.anyInGameplay
		elseif autoReadyScreens[screenName] then
			-- Other auto-ready screens require everyone to arrive at the same screen.
			readyToUnlock = updatedData.aux.allInSameScreen
		else
			readyToUnlock = updatedData.aux.allPlayersReady
		end

		if screenName == "ScreenSelectMusic" and data.songInfo ~= nil then
			-- If we're navigating back to screen select music (say from options),
			-- then don't lock input as we will have already synced before.
			-- In this case a song will have been selected already.
			-- However, if someone is still in EvaluationStage, we are transitioning
			-- eval -> music and should keep input locked until everyone arrives.
			local anyInEval = false
			for _, player in ipairs(updatedData.players) do
				if player.screenName == "ScreenEvaluationStage" then
					anyInEval = true
					break
				end
			end
			if not anyInEval then
				readyToUnlock = true
			end
		end

		if readyToUnlock then
			isWaiting = false
			-- Lift the lock.
			-- SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)

			-- The below does work, but it's currently possible that other screens are resetting this early.
			for player in ivalues(PlayerNumber) do
				SCREENMAN:set_input_redirected(player, false)
			end

			if screenName == "ScreenGameplay" then
				SCREENMAN:GetTopScreen():PauseGame(false)
			end
		else
			lines[#lines+1] = "Waiting for players to sync screens...\n"
			if screenName == "ScreenGameplay" then
				lines[#lines+1] = "Press &START; to ready up!\n"
			end
		end
	end
	for i, player in ipairs(updatedData.players) do
		local displayedScreen = player.screenName ~= "NoScreen" and player.screenName:gsub("Screen", "") or "Transitioning"
		local readyText = ""
		if screenName == "ScreenGameplay" and not updatedData.aux.allPlayersReady then
			readyText =" ["..(player.ready and "✔" or "❌").."]"
		end

		-- Only display the screen name of the players that are on a different
		-- screen than we are.
		local playerAndScreen = i..'. '..player.profileName..readyText
		if screenName ~= player.screenName then
			playerAndScreen = playerAndScreen.." - in "..displayedScreen
		end

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
				if not song and data.songInfo.songPath:split("/")[2] then
					song = SONGMAN:FindSong(data.songInfo.songPath:split("/")[2])
				end
				if song and wheel then
					wheel:SelectSong(song)
					wheel:Move(1)
					wheel:Move(-1)
					wheel:Move(0)
				end
			end
		else
      -- Only display the song in ScreenSelectMusic so that players know
      -- which songs they may need to navigate to.
      if screenName == "ScreenSelectMusic" then
        -- Split the song path into pack and song name for easier reading.
        -- It looks like "<pack>/<song>" so we can just split on the first "/"
        local songPathParts = data.songInfo.songPath:split("/")
        local pack = songPathParts[1] or "Unknown"
        local song = songPathParts[2] or "Unknown"

        -- Sometimes the pack or song can get quite long, so add ... if it's too long.
        local maxLength = 30
        if #pack > maxLength then
          pack = string.sub(pack, 1, maxLength) .. "..."
        end
        if #song > maxLength then
          song = string.sub(song, 1, maxLength) .. "..."
        end

        lines[#lines+1] = "Pack: "..pack
        lines[#lines+1] = "Song: "..song
      end
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
		actor.inLobby = true
		DisplayLobbyState(data, actor)
		MESSAGEMAN:Broadcast("OnlineLobbyState", data or {})
	elseif event == "lobbySearched" then
		MESSAGEMAN:Broadcast("LobbySearched", {
			lobbies = data and data.lobbies or {}
		})
	elseif event == "lobbyLeft" then
		actor.inLobby = false
		MESSAGEMAN:Broadcast("OnlineLobbyLeft", data or {})
	elseif event == "clientDisconnected" then
		actor.inLobby = false
		MESSAGEMAN:Broadcast("OnlineClientDisconnected", data or {})
	elseif event == "responseStatus" then
		MESSAGEMAN:Broadcast("OnlineResponseStatus", data or {})
	end
end

-- Only allow one instance of the online handler at a time.
-- Things can get a bit convoluted if we have many handlers trying to manage
-- multiple connections.
local onlineHandler = nil
local onlineHandlerInstance = nil
local onlineHandlerShuttingDown = false

GetOnlineHandlerInstance = function()
	return onlineHandlerInstance
end

CreateOnlineHandler = function() 
  if onlineHandler == nil then
    onlineHandler = Def.ActorFrame{
      Name="OnlineWebsocketHandler",
      InitCommand=function(self)
				onlineHandlerInstance = self
				onlineHandlerShuttingDown = false
        self.socket = nil
        self.connected = false
				self.inLobby = false
        self.errorMsg = nil
      end,
			OffCommand=function(self)
				onlineHandlerShuttingDown = true
				if self.socket ~= nil then
					self.socket:Close()
					self.socket = nil
				end
				self.connected = false
				self.inLobby = false
				self.errorMsg = nil
				local display = self:GetChild("Display")
				if display then
					display:GetChild("Text"):settext("")
				end
				if onlineHandlerInstance == self then
					onlineHandlerInstance = nil
				end
			end,
      ConnectOnlineMessageCommand=function(self)
        if self.socket == nil or self.errorMsg ~= nil then
					onlineHandlerShuttingDown = false
          self.socket = NETWORK:WebSocket{
            url="ws://"..host..":"..port,
            pingInterval=15,
            automaticReconnect=true,
            onMessage=function(msg)
							if onlineHandlerShuttingDown then
								return
							end

              local msgType = ToEnumShortString(msg.type)
              if msgType == "Open" then
                self.connected = true
								self.inLobby = false
                self.errorMsg = nil
                self:GetChild("Display"):visible(true)
              elseif msgType == "Message" then
                local response = JsonDecode(msg.data)
                HandleResponse(response, self)
              elseif msgType == "Close" then
								self.inLobby = false
                MESSAGEMAN:Broadcast("DisconnectOnline")
								self:GetChild("Display"):GetChild("Text"):settext("")
                self:GetChild("Display"):visible(false)
              elseif msgType == "Error" then
								self.inLobby = false
                self.errorMsg = msg.reason
								self:GetChild("Display"):GetChild("Text"):settext("")
                self:GetChild("Display"):visible(false)
              end
            end,
          }
        end
      end,
      ScreenChangedMessageCommand=function(self)
        if self.connected and self.socket ~= nil then
					if not self.inLobby then
						return
					end

          local screen = SCREENMAN:GetTopScreen()
          local screenName = screen and screen:GetName() or "NoScreen"

          if knownDisconnectScreens[screenName] then
            MESSAGEMAN:Broadcast("DisconnectOnline")
            return
          end

          -- Lock input while syncing arrival on key screens.
          if syncLockScreens[screenName] then
            isWaiting = true

            -- The below does work, but it's currently possible that other screens are resetting this early.
            for player in ivalues(PlayerNumber) do
              SCREENMAN:set_input_redirected(player, true)
            end
          end

		if autoReadyScreens[screenName] then
			for player in ivalues(GAMESTATE:GetEnabledPlayers()) do
				local pn = ToEnumShortString(player)
				readyState[pn] = true
			end
		end

          if screenName == "ScreenGameplay" then
			for player in ivalues(GAMESTATE:GetEnabledPlayers()) do
				local pn = ToEnumShortString(player)
				readyState[pn] = false
			end
            -- Input callbacks get cleared out when we transition screens, so we don't need to worry about explicitly removing it.
            SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
            SCREENMAN:GetTopScreen():PauseGame(true)
		elseif isWaiting then
			SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)

		end

          MESSAGEMAN:Broadcast("UpdateMachineState")
        end
      end,
      PlayerJoinedMessageCommand=function(self)
				if self.connected and self.socket ~= nil and self.inLobby then	
          local request = CreateRequest("updateMachine", GetMachineState())
          self.socket:Send(request)
        end
      end,
      PlayerUnjoinedMessageCommand=function(self)
				if self.connected and self.socket ~= nil and self.inLobby then	
          local request = CreateRequest("updateMachine", GetMachineState())
          self.socket:Send(request)
        end
      end,
      UpdateMachineStateMessageCommand=function(self)
				if self.connected and self.socket ~= nil and self.inLobby then	
          local request = CreateRequest("updateMachine", GetMachineState())
          self.socket:Send(request)
        end
      end,
      ExCountsChangedMessageCommand=function(self)
				if self.connected and self.socket ~= nil and self.inLobby then	
          local request = CreateRequest("updateMachine", GetMachineState())
          self.socket:Send(request)
        end
      end,
      SongSelectedMessageCommand=function(self)
				if self.connected and self.socket ~= nil and self.inLobby then
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
				self.inLobby = false
          local data = GetMachineState()
          data.code = params.code and params.code
          data.password = params.password and params.password or ""
          local request = CreateRequest("joinLobby", data)
          self.socket:Send(request)
        end
      end,
      CreateLobbyMessageCommand=function(self, params)
        if self.connected and self.socket ~= nil then
				self.inLobby = false
          local data = GetMachineState()
          data.password = params.password and params.password or ""
          local request = CreateRequest("createLobby", data)
          self.socket:Send(request)
        end
      end,
			SearchLobbyMessageCommand=function(self)
				if self.connected and self.socket ~= nil then
					local request = CreateRequest("searchLobby", {})
					self.socket:Send(request)
				end
			end,
			LeaveLobbyMessageCommand=function(self)
				if self.connected and self.socket ~= nil then
					local request = CreateRequest("leaveLobby", {})
					self.socket:Send(request)
				end
			end,
      DisconnectOnlineMessageCommand=function(self)
				onlineHandlerShuttingDown = true
				isWaiting = false
        if self.socket ~= nil then
          self.socket:Close()
        end
				for player in ivalues(PlayerNumber) do
					SCREENMAN:set_input_redirected(player, false)
				end
        self.connected = false
				self.inLobby = false
        self.socket = nil
				self:GetChild("Display"):GetChild("Text"):settext("")
        self:GetChild("Display"):visible(false)
      end,

      Def.ActorFrame{
        Name="Display",
        InitCommand=function(self)
          self:visible(false)

					local width = 200
					local LEFT = width/2
					self:xy(LEFT, _screen.cy)
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
            self:zoomto(SCREEN_WIDTH / 3, SCREEN_HEIGHT):diffuse(0, 0, 0, 0.5)
          end,
        },

        LoadFont("Common Normal").. {
          Name="Text",
          Text="",
          InitCommand=function(self)
            self:diffuse(Color.Yellow)
          end,
          ResizeCommand=function(self, params)
            self:settext(params.text)
            DiffuseEmojis(self)
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
  end

  return onlineHandler
end
