local active_index = 0
local list_selected = false
local options = { "Available Lobbies", "Refresh List", "Create Lobby", "Go Back" }
local t = nil
local connected = false
local has_error = false
local input_added = false

local holding = {
	["MenuRight"]=false,
	["MenuLeft"]=false,
}

local candidates = {}

local mode = "browse"
local joined_active_index = 0
local joined_lobby_code = ""
local joined_lobby_players = {}
local leaving_lobby = false
local showing_leave_confirm = false
local leave_confirm_index = 0

local create_lobby_password = ""
local join_lobby_password = ""
local join_lobby_code = ""
local password_prompt_mode = "create"
local show_password_in_lobby = false
local showing_password_prompt = false
local password_char_limit = 4
local password_chars = {
	"❌", "✔",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
}
local password_wheel = setmetatable({}, sick_wheel_mt)
local password_character_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name
			local af = Def.ActorFrame{
				Name=name,
				InitCommand=function(subself)
					self.container = subself
					subself:diffusealpha(0)
				end,
				OnCommand=function(self) self:linear(0.2):diffusealpha(1) end,
				Def.BitmapText{
					Font="Wendy/_wendy white",
					InitCommand=function(subself)
						self.bmt = subself
						subself:zoom(0.8):diffuse(0.75,0.75,0.75,1)
					end,
				}
			}
			return af
		end,
		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			if item_index <= 0 or item_index >= num_items-1 then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end
			self.bmt:diffuse(has_focus and 1 or 0.3, has_focus and 1 or 0.3, has_focus and 1 or 0.3, 1)
			self.container:linear(0.075)
			self.container:x(52 * (item_index - math.ceil(num_items/2)))
		end,
		set = function(self, character)
			if character then
				self.bmt:settext(character)
			end
		end
	}
}

SL.Global.Online = SL.Global.Online or {}

-- Just for testing
local sample_lobby = {
	code = "ABCD",
	playerCount = 1,
	isPasswordProtected = true,
}

local function GetPromptPassword()
	if password_prompt_mode == "join" then
		return join_lobby_password
	end
	return create_lobby_password
end

local function SetPromptPassword(value)
	if password_prompt_mode == "join" then
		join_lobby_password = value
	else
		create_lobby_password = value
	end
end

local InputHandler = function(event)
  if not event.PlayerNumber or not event.button then return false end

  if event.type == "InputEventType_FirstPress" then
		if showing_leave_confirm then
			if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
				leave_confirm_index = (leave_confirm_index + (event.GameButton=="MenuRight" and 1 or -1)) % 2
				SOUND:PlayOnce(THEME:GetPathS("ScreenSelectMaster", "change"))
				t:GetChild("LeaveConfirmPrompt"):playcommand("Hover")
			elseif event.GameButton == "Start" then
				if leave_confirm_index == 1 then
					SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))
					showing_leave_confirm = false
					t:GetChild("LeaveConfirmPrompt"):visible(false)
					MESSAGEMAN:Broadcast("DisconnectOnline")
					connected = false
					mode = "browse"
					leaving_lobby = false
					joined_lobby_code = ""
					joined_lobby_players = {}
					local topScreen = SCREENMAN:GetTopScreen()
					if topScreen then
						topScreen:SetNextScreenName("ScreenSelectMusic")
						topScreen:StartTransitioningScreen("SM_GoToNextScreen")
					end
				else
					SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
					showing_leave_confirm = false
					t:GetChild("LeaveConfirmPrompt"):visible(false)
				end
			elseif event.GameButton == "Select" or event.GameButton == "Back" then
				SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
				showing_leave_confirm = false
				t:GetChild("LeaveConfirmPrompt"):visible(false)
			end
			return false
		end

		if showing_password_prompt then
			if event.GameButton == "MenuRight" then
				password_wheel:scroll_by_amount(1)
				SOUND:PlayOnce(THEME:GetPathS("ScreenSelectMaster", "change"))
			elseif event.GameButton == "MenuLeft" then
				password_wheel:scroll_by_amount(-1)
				SOUND:PlayOnce(THEME:GetPathS("ScreenSelectMaster", "change"))
			elseif event.GameButton == "Start" then
				local selected_char = password_wheel:get_info_at_focus_pos()
				if selected_char == "✔" then
					if password_prompt_mode == "join" and join_lobby_code == "" then
						SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
						return false
					end
					showing_password_prompt = false
					t:GetChild("PasswordPrompt"):visible(false)
					t:GetChild("LobbyContent"):visible(false)
					if password_prompt_mode == "join" then
						t:playcommand("SetStatus", {
							text="Joining lobby...",
							showSpinner=true,
							showPrompt=false
						})
						MESSAGEMAN:Broadcast("JoinLobby", {
							code=join_lobby_code,
							password=join_lobby_password
						})
						-- Clear out passwords after attempting to join a lobby for security
						join_lobby_password = ""
					else
						t:playcommand("SetStatus", {
							text="Creating lobby...",
							showSpinner=true,
							showPrompt=false
						})
						MESSAGEMAN:Broadcast("CreateLobby", {password=create_lobby_password})
					end
					SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))
				elseif selected_char == "❌" then
					local password = GetPromptPassword()
					if password:len() > 0 then
						SetPromptPassword(password:sub(1, -2))
						SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
					end
					t:queuecommand("UpdatePasswordText")
				else
					local password = GetPromptPassword()
					if password:len() < password_char_limit then
						SetPromptPassword(password .. selected_char)
						SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))
						if GetPromptPassword():len() >= password_char_limit then
							password_wheel:scroll_to_pos(2)
						end
					else
						SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
					end
					t:queuecommand("UpdatePasswordText")
				end
			elseif event.GameButton == "Select" or event.GameButton == "Back" then
				local password = GetPromptPassword()
				if password:len() > 0 then
					SetPromptPassword(password:sub(1, -2))
					SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
					t:queuecommand("UpdatePasswordText")
				end
			end
			return false
		end

		if has_error and event.GameButton == "Start" then
			local topScreen = SCREENMAN:GetTopScreen()
			if topScreen then
				topScreen:SetNextScreenName("ScreenSelectMusic")
				topScreen:StartTransitioningScreen("SM_GoToNextScreen")
			end
			return false
		end

		if not connected then
			return false
		end

		if mode == "joined" then
			if leaving_lobby then
				return false
			end

			if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
				joined_active_index = (joined_active_index + (event.GameButton=="MenuRight" and 1 or -1)) % 3
				SOUND:PlayOnce(THEME:GetPathS("ScreenSelectMaster", "change"))
				t:queuecommand("Hover")
			elseif event.GameButton == "Start" then
				SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))
				if joined_active_index == 0 then
					show_password_in_lobby = not show_password_in_lobby
					t:queuecommand("UpdateJoinedLobbyText")
				elseif joined_active_index == 1 then
					leave_confirm_index = 0
					showing_leave_confirm = true
					t:GetChild("LeaveConfirmPrompt"):visible(true)
					t:GetChild("LeaveConfirmPrompt"):playcommand("Hover")
				elseif joined_active_index == 2 then
					local topScreen = SCREENMAN:GetTopScreen()
					if topScreen then
						topScreen:SetNextScreenName("ScreenSelectMusic")
						topScreen:StartTransitioningScreen("SM_GoToNextScreen")
					end
				end
			end
			return false
		end

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			holding[event.GameButton] = true
			if holding[event.GameButton == "MenuRight" and "MenuLeft" or "MenuRight"] then
				-- Same as Select below.
				if list_selected then
					list_selected = false
					SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
					t:queuecommand("LoseFocus")
					t:queuecommand("Hover")
				end
			else
				if not list_selected then
					active_index = (active_index + (event.GameButton=="MenuRight" and 1 or -1)) % #options
					SOUND:PlayOnce(THEME:GetPathS("ScreenSelectMaster", "change"))
					t:queuecommand("Hover")
				else
					if event.GameButton == "MenuRight" then
						t:queuecommand("NextLobby")
					else
						t:queuecommand("PrevLobby")
					end
				end
			end
		elseif event.GameButton == "Start" then
			if list_selected then
				local lobbyList = t:GetChild("LobbyContent") and t:GetChild("LobbyContent"):GetChild("LobbyList")
				if lobbyList then
					SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))
					lobbyList:playcommand("SelectLobby")
				else
					SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
				end
				return false
			end

			if active_index == 0 then
				if #candidates > 0 then
					list_selected = true
					SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))
					t:queuecommand("GainFocus")
					t:queuecommand("Selected")
				else
					SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
				end
			elseif active_index == 1 then
				SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))

				-- Uncomment the below to inject a sample lobby for testing purposes when refreshing the lobby list. --- IGNORE ---
				-- t:playcommand("SetStatus", {
				-- 	text="Loaded sample lobby (test mode).",
				-- 	showSpinner=false,
				-- 	showPrompt=false
				-- })
				-- MESSAGEMAN:Broadcast("LobbySearched", {
				-- 	lobbies = {sample_lobby}
				-- })
				-- return false

				local onlineHandler = GetOnlineHandlerInstance()
				if onlineHandler and onlineHandler.connected then
					t:playcommand("SetStatus", {
						text="Searching lobbies...",
						showSpinner=true,
						showPrompt=false
					})
					MESSAGEMAN:Broadcast("SearchLobby")
				else
					connected = false
					has_error = false
					attempted = false
					wait_time = 0
					t:GetChild("LobbyContent"):visible(false)
					t:playcommand("SetStatus", {
						text="Refreshing lobby list...",
						showSpinner=true,
						showPrompt=false
					})
					t:queuecommand("CheckConnect")
				end
			elseif active_index == 3 then
				SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))
				local topScreen = SCREENMAN:GetTopScreen()
				if topScreen then
					topScreen:SetNextScreenName("ScreenSelectMusic")
					topScreen:StartTransitioningScreen("SM_GoToNextScreen")
				end
			elseif active_index == 2 then
				SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))
				password_prompt_mode = "create"
				create_lobby_password = ""
				show_password_in_lobby = false
				showing_password_prompt = true
				t:GetChild("PasswordPrompt"):visible(true)
				password_wheel:scroll_to_pos(3)
				t:queuecommand("UpdatePasswordPromptUI")
				t:queuecommand("UpdatePasswordText")
			end
		elseif event.GameButton == "Select" or event.GameButton == "Back" then
			if list_selected then
				list_selected = false
				SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
				t:queuecommand("LoseFocus")
				t:queuecommand("Hover")
			end
		end
	elseif event.type == "InputEventType_Release" then
		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			holding[event.GameButton] = false
		end
	end
end

local wait_time = 0
local attempted = false
local af = Def.ActorFrame{
  OnCommand=function(self)
		t=self
    self:Center()
		if not input_added and SCREENMAN:GetTopScreen() then
			SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
			input_added = true
		end
		create_lobby_password = ""
		password_wheel:set_info_set(password_chars, 3)
		self:playcommand("SetStatus", {
			text="Initializing online connection...",
			showSpinner=true
		})
		self:queuecommand("CheckConnect")
  end,
	OffCommand=function(self)
		local onlineHandler = GetOnlineHandlerInstance()
		if onlineHandler and onlineHandler.connected and not onlineHandler.inLobby then
			MESSAGEMAN:Broadcast("DisconnectOnline")
		end
	end,
	HoverCommand=function(self)
		self:GetChild("LobbyContent"):playcommand("Hover")
		self:GetChild("JoinedLobbyContent"):playcommand("Hover")
	end,
	UpdatePasswordTextCommand=function(self)
		local text = GetPromptPassword()
		if text == "" then
			text = "(empty)"
		end
		local prompt = self:GetChild("PasswordPrompt")
		if prompt then
			prompt:GetChild("PasswordValue"):settext(text)
		end
	end,
	UpdatePasswordPromptUICommand=function(self)
		local prompt = self:GetChild("PasswordPrompt")
		if not prompt then return end

		local title = prompt:GetChild("PromptTitle")
		local hint = prompt:GetChild("PromptHint")
		local footer = prompt:GetChild("PromptFooter")

		if password_prompt_mode == "join" then
			if title then title:settext("Enter Lobby Password") end
			if hint then hint:settext("Use &MENULEFT;/&MENURIGHT; to pick characters, &START; to select, &SELECT; to delete.") end
			if footer then footer:settext("❌ removes a character. ✔ joins lobby.") end
		else
			if title then title:settext("Create Lobby Password (Optional)") end
			if hint then hint:settext("Use &MENULEFT;/&MENURIGHT; to pick characters, &START; to select, &SELECT; to delete.") end
			if footer then footer:settext("❌ removes a character. ✔ confirms.") end
		end
	end,
	UpdateJoinedLobbyTextCommand=function(self)
		local joinedContent = self:GetChild("JoinedLobbyContent")
		local codeValue = self:GetChild("JoinedLobbyContent"):GetChild("JoinedLobbyCodeValue")
		if codeValue then
			codeValue:settext(joined_lobby_code ~= "" and joined_lobby_code or "(pending)")
		end

		local lines = {}
		for i, player in ipairs(joined_lobby_players) do
			local profile = player.profileName or player.name or player.playerId or ("Player "..i)
			local ready = player.ready and " ✔" or ""
			lines[#lines+1] = i..". "..profile..ready
		end

		local playersText = self:GetChild("JoinedLobbyContent"):GetChild("JoinedLobbyPlayers")
		if playersText then
			playersText:settext(#lines > 0 and table.concat(lines, "\n") or "Waiting for players...")
		end

		local codeLabel = joinedContent and joinedContent:GetChild("JoinedLobbyCodeLabel")
		local passwordLabel = joinedContent and joinedContent:GetChild("JoinedLobbyPasswordLabel")
		local passwordValue = joinedContent and joinedContent:GetChild("JoinedLobbyPasswordValue")
		local hasPassword = create_lobby_password ~= ""
		local passwordHidden = hasPassword and (not show_password_in_lobby)
		if passwordLabel and passwordValue then
			if not hasPassword then
				passwordLabel:visible(false)
				passwordValue:visible(false)
			else
				local value = passwordHidden and string.rep("+", 4) or create_lobby_password
				passwordLabel:visible(true)
				passwordValue:visible(true)
				passwordValue:settext(value)
			end
		end

		if joinedContent then
			local function get_zoomed_width(actor)
				if not actor then return 0 end
				return actor:GetWidth() * actor:GetZoomX()
			end

			local function place_label_left_if_needed(labelActor, valueActor, defaultLabelX, valueX)
				if not labelActor or not valueActor then return end
				local valueWidth = get_zoomed_width(valueActor)
				local valueLeftEdge = valueX - valueWidth
				local gap = 12
				local desiredLabelX = math.min(defaultLabelX, valueLeftEdge - gap)
				local minLabelX = -285
				labelActor:x(math.max(minLabelX, desiredLabelX))
			end

			place_label_left_if_needed(codeLabel, codeValue, -10, 50)
			if hasPassword then
				place_label_left_if_needed(passwordLabel, passwordValue, -10, 50)
			else
				if passwordLabel then passwordLabel:x(-10) end
			end
		end

		local toggleButton = self:GetChild("JoinedLobbyContent"):GetChild("TogglePasswordButton")
		local toggleText = toggleButton and toggleButton:GetChild("TogglePasswordText")
		if toggleText then
			toggleText:settext(passwordHidden and "Show Password" or "Hide Password")
			toggleText:visible(hasPassword)
		end

		if toggleButton then
			toggleButton:visible(hasPassword)
		end
	end,
	SetStatusCommand=function(self, params)
		self:GetChild("NetworkStatus"):visible(true)
		self:GetChild("NetworkStatus"):playcommand("Set", params)
	end,
	CheckConnectCommand=function(self)
		local onlineHandler = GetOnlineHandlerInstance()
		if onlineHandler then
			-- If no connection exists, first (re)establish the connection.
			-- Only try once per screen load to avoid infinite loops of trying to connect.
			if not attempted and (not onlineHandler.socket or onlineHandler.errorMsg ~= nil) then
				self:playcommand("SetStatus", {
					text="Connecting to online service...",
					showSpinner=true
				})
				MESSAGEMAN:Broadcast("ConnectOnline")
				attempted = true
			end

			if not onlineHandler.connected and onlineHandler.errorMsg == nil then
				wait_time = wait_time + 1
				self:playcommand("SetStatus", {
					text="Connecting to online service... ("..wait_time.."s)",
					showSpinner=true
				})
				self:sleep(1):queuecommand("CheckConnect")
			else
				self:queuecommand("Display")
			end
		else
			self:playcommand("SetStatus", {
				text="Initializing online handler...",
				showSpinner=true
			})
			self:sleep(0.25):queuecommand("CheckConnect")
		end
	end,
	DisplayCommand=function(self)
		local onlineHandler = GetOnlineHandlerInstance()
		if onlineHandler then
			if onlineHandler.connected then
				connected = true
				has_error = false
				self:playcommand("SetStatus", {
					text="Connected to online service.",
					showSpinner=false,
					showPrompt=false
				})
				self:GetChild("NetworkStatus"):visible(false)
				self:GetChild("LobbyContent"):visible(mode ~= "joined")
				self:GetChild("JoinedLobbyContent"):visible(mode == "joined")
				local emptyText = self:GetChild("LobbyContent"):GetChild("EmptyStateText")
				if emptyText then
					emptyText:visible(#candidates == 0)
				end
				MESSAGEMAN:Broadcast("SearchLobby")
				self:queuecommand("Hover")
			end

			if onlineHandler.errorMsg ~= nil then
				connected = false
				has_error = true
				self:playcommand("SetStatus", {
					text="Error connecting to online service:\n"..onlineHandler.errorMsg,
					showSpinner=false,
					showPrompt=true,
					promptText="Press &START; to return to Select Music."
				})
				self:GetChild("LobbyContent"):visible(false)
			end
		end
	end,
	LobbySearchedMessageCommand=function(self, params)
		candidates = params and params.lobbies or {}

		local lobbyContent = self:GetChild("LobbyContent")
		if lobbyContent then
			local lobbyList = lobbyContent:GetChild("LobbyList")
			if lobbyList then
				lobbyList:playcommand("UpdateData", {data=candidates})
			end

			local lobbyCount = lobbyContent:GetChild("LobbyCount")
			if lobbyCount then
				local total = #candidates
				lobbyCount:settext(total > 0 and ("1/"..total) or "0/0")
			end

			local emptyText = lobbyContent:GetChild("EmptyStateText")
			if emptyText then
				emptyText:visible(#candidates == 0)
			end
		end

		self:GetChild("NetworkStatus"):visible(false)
		self:GetChild("LobbyContent"):visible(mode ~= "joined")
		self:GetChild("JoinedLobbyContent"):visible(mode == "joined")
		self:queuecommand("Hover")
	end,
	OnlineLobbyStateMessageCommand=function(self, params)
		mode = "joined"
		leaving_lobby = false
		showing_leave_confirm = false
		list_selected = false
		showing_password_prompt = false
		password_prompt_mode = "create"
		join_lobby_code = ""
		join_lobby_password = ""
		joined_lobby_code = params and params.code or ""
		joined_lobby_players = params and params.players or {}

		self:queuecommand("UpdateJoinedLobbyText")

		self:GetChild("PasswordPrompt"):visible(false)
		self:GetChild("NetworkStatus"):visible(false)
		self:GetChild("LobbyContent"):visible(false)
		self:GetChild("JoinedLobbyContent"):visible(true)
		joined_active_index = 0
		self:queuecommand("Hover")
	end,
	OnlineLobbyJoinSelectedMessageCommand=function(self, params)
		if not params or not params.code then
			SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
			return
		end

		join_lobby_code = params.code
		if params.isPasswordProtected then
			password_prompt_mode = "join"
			join_lobby_password = ""
			showing_password_prompt = true
			self:GetChild("PasswordPrompt"):visible(true)
			password_wheel:scroll_to_pos(3)
			self:queuecommand("UpdatePasswordPromptUI")
			self:queuecommand("UpdatePasswordText")
		else
			showing_password_prompt = false
			self:GetChild("PasswordPrompt"):visible(false)
			self:GetChild("LobbyContent"):visible(false)
			self:playcommand("SetStatus", {
				text="Joining lobby...",
				showSpinner=true,
				showPrompt=false
			})
			MESSAGEMAN:Broadcast("JoinLobby", {
				code=params.code,
				password=params.password or ""
			})
		end
	end,
	OnlineLobbyLeftMessageCommand=function(self, params)
		if params == nil or params.left == nil or params.left then
			leaving_lobby = false
			showing_leave_confirm = false
			mode = "browse"
			joined_lobby_code = ""
			joined_lobby_players = {}
			self:GetChild("JoinedLobbyContent"):visible(false)
			self:GetChild("LobbyContent"):visible(true)
			self:GetChild("NetworkStatus"):visible(false)
			self:playcommand("SetStatus", {
				text="Left lobby.",
				showSpinner=false,
				showPrompt=false
			})
			self:queuecommand("Hover")
		end
	end,
	OnlineResponseStatusMessageCommand=function(self, params)
		if params and params.event == "createLobby" and params.success == false then
			mode = "browse"
			self:GetChild("JoinedLobbyContent"):visible(false)
			self:GetChild("LobbyContent"):visible(true)
			self:playcommand("SetStatus", {
				text=params.message and ("Create lobby failed:\n"..params.message) or "Create lobby failed.",
				showSpinner=false,
				showPrompt=false
			})
		elseif params and params.event == "joinLobby" and params.success == false then
			mode = "browse"
			self:GetChild("JoinedLobbyContent"):visible(false)
			self:GetChild("LobbyContent"):visible(true)
			self:playcommand("SetStatus", {
				text=params.message and ("Join lobby failed:\n"..params.message) or "Join lobby failed.",
				showSpinner=false,
				showPrompt=false
			})
		elseif params and params.event == "leaveLobby" and params.success == false then
			leaving_lobby = false
			showing_leave_confirm = false
			self:playcommand("SetStatus", {
				text=params.message and ("Leave lobby failed:\n"..params.message) or "Leave lobby failed.",
				showSpinner=false,
				showPrompt=false
			})
		end
	end,

	Def.ActorFrame{
		Name="LobbyContent",
		InitCommand=function(self)
			self:visible(false)
		end,
  
		LoadFont("Common Normal")..{
			Text="&MENULEFT;/&MENURIGHT; to Choose | &START; to Select | &SELECT; or &MENULEFT;+&MENURIGHT; to Return",
			InitCommand=function(self)
				self:y(180)
			end
		},

		Def.ActorFrame{
			Name="LobbyList",
			InitCommand=function(self)
				self:x(-120)
				self.idx = 0
			end,
			OnCommand=function(self)
				self:playcommand("UpdateData", {data=candidates})
			end,

			Def.Quad{
				InitCommand=function(self)
					self:zoomto(360,340):y(-20):diffuse(Color.White)
				end,
				HoverCommand=function(self)
					if not list_selected then
						self:diffuse(active_index == self:GetParent().idx and Color.Yellow or Color.White)
					end
				end,
				SelectedCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and Color.Green or Color.White)
				end
			},

			Def.Quad{
				InitCommand=function(self)
					self:zoomto(360-2,340-2):y(-20):diffuse(Color.Black)
				end
			},

			Def.Quad{
				InitCommand=function(self)
					self:zoomto(350, 1):y(-150):diffuse(Color.White)
				end
			},

			LoadFont("Common Bold")..{
				Text="Available Lobbies",
				InitCommand=function(self)
					self:horizalign(left):x(-170):y(-170):zoom(0.5)
				end,
				HoverCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and GetHexColor(SL.Global.ActiveColorIndex) or Color.White)
				end
			},

			LoadFont("Common Normal")..{
				Name="LobbyCount",
				Text="0/0",
				InitCommand=function(self)
					self:horizalign(right):x(170):y(-170)
				end,
				UpdateIndexCommand=function(self, params)
					self:settext(params.idx .. "/" .. params.total)
				end
			},

			LoadActor("LobbyInfo.lua")
		},

		LoadFont("Common Normal")..{
			Name="EmptyStateText",
			Text="No lobbies found.",
			InitCommand=function(self)
				self:horizalign(center):xy(-120, -120):zoom(1.4):diffuse(Color.White):visible(false)
			end
		},

		Def.ActorFrame{
			InitCommand=function(self)
				local idx = 2
				local width = 200
				local height = 40
				local spacing = 20
				local mid = #options / 2
				self:y((idx - 1 - mid) * (spacing + height))
				self:x(180)
				self.idx = idx - 1
			end,
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(200, 40):diffuse(Color.White)
				end,
				HoverCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and Color.Yellow or Color.White)
				end,
				SelectedCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and Color.Green or Color.White)
				end
			},

			Def.Quad{
				InitCommand=function(self)
					self:zoomto(198, 38):diffuse(Color.Black)
				end
			},

			LoadFont("Common Bold")..{
				Text="Refresh List",
				InitCommand=function(self)
					self:zoom(0.5)
				end,
				HoverCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and GetHexColor(SL.Global.ActiveColorIndex) or Color.White)
				end
			},
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(200, 40):diffuse(color("#424242")):diffusealpha(0)
				end,
				SelectedCommand=function(self)
					if active_index ~= self:GetParent().idx then
						-- Gray out the button if it's not selected, since it won't do anything.
						self:diffusealpha(0.70)
					else
						self:diffusealpha(0)
					end
				end,
				LoseFocusCommand=function(self)
					self:diffusealpha(0)
				end
			},
		},

		Def.ActorFrame{
			InitCommand=function(self)
				local idx = 3
				local width = 200
				local height = 40
				local spacing = 20
				local mid = #options / 2
				self:y((idx - 1 - mid) * (spacing + height))
				self:x(180)
				self.idx = idx - 1
			end,

			Def.Quad{
				InitCommand=function(self)
					self:zoomto(200, 40):diffuse(Color.White)
				end,
				HoverCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and Color.Yellow or Color.White)
				end,
				SelectedCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and Color.Green or Color.White)
				end
			},

			Def.Quad{
				InitCommand=function(self)
					self:zoomto(198, 38):diffuse(Color.Black)
				end
			},

			LoadFont("Common Bold")..{
				Text="Create Lobby",
				InitCommand=function(self)
					self:zoom(0.5)
				end,
				HoverCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and GetHexColor(SL.Global.ActiveColorIndex) or Color.White)
				end
			},
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(200, 40):diffuse(color("#424242")):diffusealpha(0)
				end,
				SelectedCommand=function(self)
					if active_index ~= self:GetParent().idx then
						-- Gray out the button if it's not selected, since it won't do anything.
						self:diffusealpha(0.70)
					else
						self:diffusealpha(0)
					end
				end,
				LoseFocusCommand=function(self)
					self:diffusealpha(0)
				end
			},
		},

		Def.ActorFrame{
			InitCommand=function(self)
				local idx = 4
				local width = 200
				local height = 40
				local spacing = 20
				local mid = #options / 2
				self:y((idx - 1 - mid) * (spacing + height))
				self:x(180)
				self.idx = idx - 1
			end,

			Def.Quad{
				InitCommand=function(self)
					self:zoomto(200, 40):diffuse(Color.White)
				end,
				HoverCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and Color.Yellow or Color.White)
				end,
				SelectedCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and Color.Green or Color.White)
				end
			},

			Def.Quad{
				InitCommand=function(self)
					self:zoomto(198, 38):diffuse(Color.Black)
				end
			},

			LoadFont("Common Bold")..{
				Text="Go Back",
				InitCommand=function(self)
					self:zoom(0.5)
				end,
				HoverCommand=function(self)
					self:diffuse(active_index == self:GetParent().idx and GetHexColor(SL.Global.ActiveColorIndex) or Color.White)
				end
			},
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(200, 40):diffuse(color("#424242")):diffusealpha(0)
				end,
				SelectedCommand=function(self)
					if active_index ~= self:GetParent().idx then
						-- Gray out the button if it's not selected, since it won't do anything.
						self:diffusealpha(0.70)
					else
						self:diffusealpha(0)
					end
				end,
				LoseFocusCommand=function(self)
					self:diffusealpha(0)
				end
			},
		},
	},

	Def.ActorFrame{
		Name="PasswordPrompt",
		InitCommand=function(self)
			self:visible(false)
		end,

		Def.Quad{
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):diffuse(0,0,0,0.75)
			end
		},
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(560, 210):diffuse(0,0,0,0.9)
			end
		},
		LoadFont("Common Normal")..{
			Name="PromptTitle",
			Text="Create Lobby Password (Optional)",
			InitCommand=function(self)
				self:y(-72):zoom(0.85)
			end
		},
		LoadFont("Common Normal")..{
			Name="PromptHint",
			Text="Use &MENULEFT;/&MENURIGHT; to pick characters, &START; to select, &SELECT; to delete.",
			InitCommand=function(self)
				self:y(-46):zoom(0.55)
			end
		},
		LoadFont("Common Bold")..{
			Name="PasswordValue",
			Text="(empty)",
			InitCommand=function(self)
				self:y(-14):zoom(0.6)
			end
		},
		password_wheel:create_actors("PasswordWheel", 7, password_character_mt, 50, 38),
		LoadFont("Common Normal")..{
			Name="PromptFooter",
			Text="❌ removes a character. ✔ confirms.",
			InitCommand=function(self)
				self:y(90):zoom(0.6)
			end
		},
	},

	Def.ActorFrame{
		Name="JoinedLobbyContent",
		InitCommand=function(self)
			self:visible(false)
		end,

		Def.Quad{
			InitCommand=function(self)
				self:zoomto(360,340):x(-120):y(-20):diffuse(Color.White)
			end
		},
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(358,338):x(-120):y(-20):diffuse(Color.Black)
			end
		},
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(350, 1):x(-120):y(-150):diffuse(Color.White)
			end
		},
		LoadFont("Common Bold")..{
			Text="Joined Lobby",
			InitCommand=function(self)
				self:horizalign(left):x(-290):y(-170):zoom(0.5)
			end
		},
		LoadFont("Common Normal")..{
			Name="JoinedLobbyCodeLabel",
			Text="Lobby Code:",
			InitCommand=function(self)
				self:horizalign(right):x(-10):y(-170):zoom(1)
			end
		},
		LoadFont("Common Bold")..{
			Name="JoinedLobbyCodeValue",
			Text="(pending)",
			InitCommand=function(self)
				self:horizalign(right):x(50):y(-170):zoom(0.5)
			end
		},
		LoadFont("Common Normal")..{
			Name="JoinedLobbyPlayers",
			Text="Waiting for players...",
			InitCommand=function(self)
				self:horizalign(left):x(-290):y(-100):zoom(1):maxwidth(560)
			end
		},
		LoadFont("Common Normal")..{
			Name="JoinedLobbyPasswordLabel",
			Text="Password:",
			InitCommand=function(self)
				self:horizalign(right):x(-10):y(-130):zoom(1):visible(false)
			end
		},
		LoadFont("Common Bold")..{
			Name="JoinedLobbyPasswordValue",
			Text="",
			InitCommand=function(self)
				self:horizalign(right):x(50):y(-130):zoom(0.5):visible(false)
			end
		},

		Def.ActorFrame{
			Name="TogglePasswordButton",
			InitCommand=function(self)
				self:xy(180, -60)
				self.idx = 0
			end,
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(200, 40):diffuse(Color.White)
				end,
				HoverCommand=function(self)
					self:diffuse(joined_active_index == self:GetParent().idx and Color.Yellow or Color.White)
				end
			},
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(198, 38):diffuse(Color.Black)
				end
			},
			LoadFont("Common Bold")..{
				Name="TogglePasswordText",
				Text="Show Password",
				InitCommand=function(self)
					self:zoom(0.5)
				end,
				HoverCommand=function(self)
					self:diffuse(joined_active_index == self:GetParent().idx and GetHexColor(SL.Global.ActiveColorIndex) or Color.White)
				end
			}
		},

		Def.ActorFrame{
			InitCommand=function(self)
				self:xy(180, 0)
				self.idx = 1
			end,
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(200, 40):diffuse(Color.White)
				end,
				HoverCommand=function(self)
					self:diffuse(joined_active_index == self:GetParent().idx and Color.Yellow or Color.White)
				end
			},
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(198, 38):diffuse(Color.Black)
				end
			},
			LoadFont("Common Bold")..{
				Text="Leave Lobby",
				InitCommand=function(self)
					self:zoom(0.5)
				end,
				HoverCommand=function(self)
					self:diffuse(joined_active_index == self:GetParent().idx and GetHexColor(SL.Global.ActiveColorIndex) or Color.White)
				end
			}
		},

		Def.ActorFrame{
			InitCommand=function(self)
				self:xy(180, 60)
				self.idx = 2
			end,
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(200, 40):diffuse(Color.White)
				end,
				HoverCommand=function(self)
					self:diffuse(joined_active_index == self:GetParent().idx and Color.Yellow or Color.White)
				end
			},
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(198, 38):diffuse(Color.Black)
				end
			},
			LoadFont("Common Bold")..{
				Text="Select Music",
				InitCommand=function(self)
					self:zoom(0.5)
				end,
				HoverCommand=function(self)
					self:diffuse(joined_active_index == self:GetParent().idx and GetHexColor(SL.Global.ActiveColorIndex) or Color.White)
				end
			}
		},
	},

	Def.ActorFrame{
		Name="LeaveConfirmPrompt",
		InitCommand=function(self)
			self:visible(false)
		end,
		HoverCommand=function(self)
			self:GetChild("CancelButton"):playcommand("Hover")
			self:GetChild("ConfirmButton"):playcommand("Hover")
		end,

		Def.Quad{
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):diffuse(0,0,0,0.6)
			end
		},
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(500, 180):diffuse(0,0,0,0.9)
			end
		},
		LoadFont("Common Normal")..{
			Text="Disconnect from the lobby and return to Select Music?",
			InitCommand=function(self)
				self:y(-42):zoom(1)
			end
		},

		Def.ActorFrame{
			Name="CancelButton",
			InitCommand=function(self)
				self:x(-90):y(30)
			end,
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(150, 40):diffuse(Color.White)
				end,
				HoverCommand=function(self)
					self:diffuse(leave_confirm_index == 0 and Color.Yellow or Color.White)
				end
			},
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(148, 38):diffuse(Color.Black)
				end
			},
			LoadFont("Common Bold")..{
				Text="Cancel",
				InitCommand=function(self)
					self:zoom(0.5)
				end,
				HoverCommand=function(self)
					self:diffuse(leave_confirm_index == 0 and GetHexColor(SL.Global.ActiveColorIndex) or Color.White)
				end
			}
		},

		Def.ActorFrame{
			Name="ConfirmButton",
			InitCommand=function(self)
				self:x(90):y(30)
			end,
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(150, 40):diffuse(Color.White)
				end,
				HoverCommand=function(self)
					self:diffuse(leave_confirm_index == 1 and Color.Yellow or Color.White)
				end
			},
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(148, 38):diffuse(Color.Black)
				end
			},
			LoadFont("Common Bold")..{
				Text="Disconnect",
				InitCommand=function(self)
					self:zoom(0.5)
				end,
				HoverCommand=function(self)
					self:diffuse(leave_confirm_index == 1 and GetHexColor(SL.Global.ActiveColorIndex) or Color.White)
				end
			}
		}
	},



	-- Keep this on top of everything else so that it doesn't get covered up by any other elements.
	Def.ActorFrame{
		Name="NetworkStatus",
		InitCommand=function(self)
			self:y(-130)
		end,
		SetCommand=function(self, params)
			if not params then return end
			local showPrompt = params.showPrompt == true
			self:GetChild("Spinner"):visible(params.showSpinner == true)
			self:GetChild("StatusText"):settext(params.text or "")
			self:GetChild("PromptText"):visible(showPrompt)
			self:GetChild("PromptText"):settext(showPrompt and (params.promptText or "") or "")

			local statusWidth = self:GetChild("StatusText"):GetWidth()
			local promptWidth = showPrompt and self:GetChild("PromptText"):GetWidth() or 0
			local width = math.min(math.max(math.max(statusWidth, promptWidth) + 50, 360), 620)
			local height = showPrompt and 78 or 52
			self:GetChild("Background"):zoomto(width, height)
			self:GetChild("Spinner"):x(-width/2 + 22)
		end,

		Def.Quad{
			Name="Background",
			InitCommand=function(self)
				self:zoomto(280, 44):diffuse(0,0,0,0.75)
			end
		},
		Def.Sprite{
			Name="Spinner",
			Texture=THEME:GetPathG("", "LoadingSpinner 10x3.png"),
			Frames=Sprite.LinearFrames(30,1),
			InitCommand=function(self)
				self:x(-118):zoom(0.14):diffuse(GetHexColor(SL.Global.ActiveColorIndex, true)):visible(false)
			end,
			VisualStyleSelectedMessageCommand=function(self)
				self:diffuse(GetHexColor(SL.Global.ActiveColorIndex, true))
			end
		},
		LoadFont("Common Normal")..{
			Name="StatusText",
			Text="",
			InitCommand=function(self)
				self:maxwidth(560):zoom(0.82):diffuse(Color.White):y(-10)
			end
		},
		LoadFont("Common Normal")..{
			Name="PromptText",
			Text="",
			InitCommand=function(self)
				self:maxwidth(560):zoom(0.95):diffuse(Color.White):y(18):visible(false)
			end
		}
	},
}

return af