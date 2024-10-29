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
