GrooveStatsURL = function()
	-- For test GrooveStats responses, create a file called GrooveStats_UAT.txt
	-- in your theme's Other directory. To toggle between live and UAT, delete/rename this file.
	-- Requires gsapi-mock and adding 127.0.0.1 to HttpAllowHosts in Preferences.ini
	local url_prefix
	local dir = THEME:GetCurrentThemeDirectory() .. "Other/"
	local uat = dir .. "GrooveStats_UAT.txt"
	local boogie = ThemePrefs.Get("EnableBoogieStats")
	if not FILEMAN:DoesFileExist(uat) then 
		if boogie and string.find(PREFSMAN:GetPreference("HttpAllowHosts"), "boogiestats.andr.host") then url_prefix = "https://boogiestats.andr.host/" 
		else url_prefix = "https://apiservice.groovestats.com/api/" end
	else
		url_prefix = "http://127.0.0.1:5000/"
	end
	return url_prefix
end

-- -----------------------------------------------------------------------
-- Returns an actor that can write a request, wait for its response, and then
-- perform some action. This actor will only wait for one response at a time.
-- If we make a new request while we are already waiting on a response, we
-- will cancel the current request and make a new one.
--
-- Args:
--     x: The x position of the loading spinner.
--     y: The y position of the loading spinner.
--
-- Usage:
-- af[#af+1] = RequestResponseActor(100, 0)
--
-- Which can then be triggered from within the OnCommand of the parent ActorFrame:
--
-- af.OnCommand=function(self)
--     self:playcommand("MakeGrooveStatsRequest", {
--         endpoint="?action=newSession&chartHashVersion="..SL.GrooveStats.ChartHashVersion,
--         method="GET",
--         timeout=10,
--         callback=NewSessionRequestProcessor,
--         args=self:GetParent()
--     })
-- end
--
-- (Alternatively, the OnCommand can be concatenated to the returned actor itself.)

-- The params table passed to the playcommand can have the following keys.
-- All these fields are optional because there are some defaults in place.
--
-- endpoint: string, the endpoint at api.groovestats.com to send the request to.
-- method: string, the type of request to make.
--	       Valid values are GET, POST, PUT, PATCH, and DELETE.
-- body: string, the body for the request.
-- headers: table, a table containing key value pairs for the headers of the request.
-- timeout: number, the amount of time to wait for the request to complete in seconds.
-- callback: function, callback to process the response. It can take up to two
--       parameters:
--           res: The JSON response which has been converted back to a lua table
--           args: The provided args passed as is.
-- args: any, arguments that will be made accesible to the callback function. This
--       can of any type as long as the callback knows what to do with it.
RequestResponseActor = function(x, y)
	local url_prefix = GrooveStatsURL()

	return Def.ActorFrame{
		InitCommand=function(self)
			self.request_time = -1
			self.timeout = -1
			self.request_handler = nil
			self.leaving_screen = false
			self:xy(x, y)
		end,
		CancelCommand=function(self)
			self.leaving_screen = true
			-- Cancel the request if we pressed back on the screen.
			if self.request_handler then
				self.request_handler:Cancel()
				self.request_handler = nil
			end
		end,
		OffCommand=function(self)
			self.leaving_screen = true
			-- Cancel the request if this actor will be destructed soon.
			if self.request_handler then
				self.request_handler:Cancel()
				self.request_handler = nil
			end
		end,
		MakeGrooveStatsRequestCommand=function(self, params)
			self:stoptweening()
			if not params then
				Warn("No params specified for MakeGrooveStatsRequestCommand.")
				return
			end

			-- Cancel any existing requests if we're waiting on one at the moment.
			if self.request_handler then
				self.request_handler:Cancel()
				self.request_handler = nil
			end
			self:GetChild("Spinner"):visible(true)

			local timeout = params.timeout or 60
			local endpoint = params.endpoint or ""
			local method = params.method
			local body = params.body
			local headers = params.headers

			self.timeout = timeout

			-- Attempt to make the request
			self.request_handler = NETWORK:HttpRequest{
				url=url_prefix..endpoint,
				method=method,
				body=body,
				headers=headers,
				connectTimeout=timeout,
				transferTimeout=timeout,
				onResponse=function(response)
					self.request_handler = nil
					-- If we get a permanent error, make sure we "disconnect" from
					-- GrooveStats until we recheck on ScreenTitleMenu.
					if response.statusCode then
						local body = nil
						local code = response.statusCode
						if code == 200 then
							body = JsonDecode(response.body)
						end
						if (code >= 400 and code < 499 and code ~= 429) or (code == 200 and body and body.error and #body.error) then
							SL.GrooveStats.IsConnected = false
						end
					end

					if self.leaving_screen then
						return
					end
					
					if params.callback then
						if not response.error or ToEnumShortString(response.error) ~= "Cancelled" then
							params.callback(response, params.args)
						end
					end

					MESSAGEMAN:Broadcast("GrooveStatsRequestFinished", {id=request_actor_id})
				end,
			}
			-- Keep track of when we started making the request
			self.request_time = GetTimeSinceStart()
			-- Start looping for the spinner.
			self:queuecommand("GrooveStatsRequestLoop")
		end,
		GrooveStatsRequestFinishedMessageCommand=function(self, params)
			if params and params.id == request_actor_id then
				self:GetChild("Spinner"):visible(false)
			end
		end,
		GrooveStatsRequestLoopCommand=function(self)
			local now = GetTimeSinceStart()
			local remaining_time = self.timeout - (now - self.request_time)
			self:playcommand("UpdateSpinner", {
				timeout=self.timeout,
				remaining_time=remaining_time
			})
			-- Only loop if the request is still ongoing.
			-- The callback always resets the request_handler once its finished.
			if self.request_handler then
				self:sleep(0.5):queuecommand("GrooveStatsRequestLoop")
			end
		end,

		Def.ActorFrame{
			Name="Spinner",
			InitCommand=function(self)
				self:visible(false)
			end,
			Def.Sprite{
				Texture=THEME:GetPathG("", "LoadingSpinner 10x3.png"),
				Frames=Sprite.LinearFrames(30,1),
				InitCommand=function(self)
					self:zoom(0.15)
					self:diffuse(GetHexColor(SL.Global.ActiveColorIndex, true))
				end,
				VisualStyleSelectedMessageCommand=function(self)
					self:diffuse(GetHexColor(SL.Global.ActiveColorIndex, true))
				end
			},
			LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
				InitCommand=function(self)
					self:zoom(0.9)
					-- Leaderboard should be white since it's on a black background.
					self:diffuse(DarkUI() and name ~= "Leaderboard" and Color.Black or Color.White)
				end,
				UpdateSpinnerCommand=function(self, params)
					-- Only display the countdown after we've waiting for some amount of time.
					if params.timeout - params.remaining_time > 2 then
						self:visible(true)
					else
						self:visible(false)
					end
					if params.remaining_time > 1 then
						self:settext(math.floor(params.remaining_time))
					end
				end
			}
		},
	}
end

-- -----------------------------------------------------------------------
-- Sets the API key for a player if it's found in their profile.

ParseGrooveStatsIni = function(player)
	if not player then return end

	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	
	if not profile_slot[player] then return "" end

	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	local pn = ToEnumShortString(player)
	-- We require an explicit profile to be loaded.
	if not dir or #dir == 0 then return "" end

	local path = dir .. "GrooveStats.ini"

	if not FILEMAN:DoesFileExist(path) then
		-- The file doesn't exist. We will create it for this profile, and then just return.
		IniFile.WriteFile(path, {
			["GrooveStats"]={
				["ApiKey"]="",
				["Username"]="",
				["IsPadPlayer"]=0,
			}
		})
	else
		local contents = IniFile.ReadFile(path)
		for k,v in pairs(contents["GrooveStats"]) do
			if k == "ApiKey" then
				if #v ~= 64 then
					-- Print the error only if the ApiKey is non-empty.
					if #v ~= 0 then
						SM(ToEnumShortString(player).." has invalid ApiKey length!")
					end
					SL[pn].ApiKey = ""
				else
					SL[pn].ApiKey = v
				end
			elseif k == "Username" then
				SL[pn].GrooveStatsUsername = v
			elseif k == "IsPadPlayer" then
				-- Must be explicitly set to 1.
				if v == 1 then
					SL[pn].IsPadPlayer = true
				else
					SL[pn].IsPadPlayer = false
				end
			end
		end

		-- Always write the file back to disk to ensure it's up to date with
		-- any new fields that may have been added.
		IniFile.WriteFile(path, {
			["GrooveStats"]={
				["ApiKey"]=SL[pn].ApiKey,
				["Username"]=SL[pn].GrooveStatsUsername,
				["IsPadPlayer"]=SL[pn].IsPadPlayer and "1" or "0",
			}
		})
	end
end

-- -----------------------------------------------------------------------
WriteGrooveStatsIni = function(player)
	if not player then return end

	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	
	if not profile_slot[player] then return "" end

	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	local pn = ToEnumShortString(player)
	-- We require an explicit profile to be loaded.
	if not dir or #dir == 0 then return "" end

	local path = dir .. "GrooveStats.ini"

	IniFile.WriteFile(path, {
		["GrooveStats"]={
			["ApiKey"]=SL[pn].ApiKey,
			["Username"]=SL[pn].GrooveStatsUsername,
			["IsPadPlayer"]=SL[pn].IsPadPlayer and "1" or "0",
		}
	})
end

-- -----------------------------------------------------------------------
-- The common conditions required to use the GrooveStats services.
-- Currently the conditions are:
--  - GrooveStats is enabled in the operator menu.
--  - We were successfully able to make a GrooveStats conenction previously.
--  - We must be in the "dance" or "pump" game mode (not "techno", etc)
--  - We must be in ITG.
--  - At least one Api Key must be available (this condition may be relaxed in the future)
--  - We must not be in course mode (ZANKOKU: moving this specific check to autosubmitscore instead, since otherwise it blocks scorebox when playing course mode).
IsServiceAllowed = function(condition)
	return (condition and
		ThemePrefs.Get("EnableGrooveStats") and
		SL.GrooveStats.IsConnected and
		(GAMESTATE:GetCurrentGame():GetName() == "dance" or GAMESTATE:GetCurrentGame():GetName() == "pump") and
		SL.Global.GameMode == "ITG" and
		(SL.P1.ApiKey ~= "" or SL.P2.ApiKey ~= ""))
end

-- -----------------------------------------------------------------------
-- ValidForGrooveStats.lua contains various checks requested by Archi
-- to determine whether the score should be permitted on GrooveStats
-- and returns a table of booleans, one per check, and also a bool
-- indicating whether all the checks were satisfied or not.
--
-- Obviously, this is trivial to circumvent and not meant to keep
-- malicious users out of GrooveStats. It is intended to prevent
-- well-intentioned-but-unaware players from accidentally submitting
-- invalid scores to GrooveStats.
ValidForGrooveStats = function(player)
	local valid = {}

	-- ------------------------------------------
	-- First, check for modes not supported by GrooveStats.

	local cur_game = GAMESTATE:GetCurrentGame():GetName()

	-- GrooveStats only supports dance and pump for now (not techno, etc.)
	valid[1] = (cur_game == "dance" or cur_game == "pump")

	-- GrooveStats does not support dance-solo (i.e. 6-panel dance like DDR Solo 4th Mix)
	-- https://en.wikipedia.org/wiki/Dance_Dance_Revolution_Solo
	valid[2] = GAMESTATE:GetCurrentStyle():GetName() ~= "solo"

	-- GrooveStats actually does rank Marathons from ITG1, ITG2, and ITG Home
	-- but there isn't QR support at this time.
	valid[3] = not GAMESTATE:IsCourseMode()

	-- GrooveStats was made with ITG settings in mind.
	-- FA+ is okay because it just halves ITG's TimingWindowW1 but keeps everything else the same.
	-- Casual (and Experimental, Demonic, etc.) uses different settings
	-- that are incompatible with GrooveStats ranking.
	valid[4] = SL.Global.GameMode == "ITG"

	-- ------------------------------------------
	-- Next, check global Preferences that would invalidate the score.

	-- TimingWindowScale and LifeDifficultyScale are a little confusing. Players can change these under
	-- Advanced Options in the operator menu on scales from [1 to Justice] and [1 to 7], respectively.
	--
	-- The OptionRow for TimingWindowScale offers [1, 2, 3, 4, 5, 6, 7, 8, Justice] as options
	-- and these map to [1.5, 1.33, 1.16, 1, 0.84, 0.66, 0.5, 0.33, 0.2] in Preferences.ini for internal use.
	--
	-- The OptionRow for LifeDifficultyScale offers [1, 2, 3, 4, 5, 6, 7] as options
	-- and these map to [1.6, 1.4, 1.2, 1, 0.8, 0.6, 0.4] in Preferences.ini for internal use.
	--
	-- I don't know the history here, but I suspect these preferences are holdovers from SM3.9 when
	-- themes were just visual skins and core mechanics like TimingWindows and Life scaling could only
	-- be handled by the SM engine.  Whatever the case, they're still exposed as options in the
	-- operator menu and players still play around with them, so we need to handle that here.
	--
	-- 4 (1, internally) is considered standard for ITG.
	-- GrooveStats expects players to have both these set to 4 (1, internally).
	-- We also allow people to use harder values as well.
	--
	-- People can probably use some combination of LifeDifficultyScale,
	-- TimingWindowScale, and TimingWindowAdd to probably match up with ITG's windows, but that's a
	-- bit cumbersome to handle so just requre TimingWindowScale and LifeDifficultyScale these to be set
	-- to 4.
	valid[5] = PREFSMAN:GetPreference("TimingWindowScale") <= 1
	valid[6] = PREFSMAN:GetPreference("LifeDifficultyScale") <= 1

	-- Validate all other metrics.
	local ExpectedTWA = 0.0015
	local ExpectedWindows = {
		0.021500 + ExpectedTWA,  -- Fantastics
		0.043000 + ExpectedTWA,  -- Excellents
		0.102000 + ExpectedTWA,  -- Greats
		0.135000 + ExpectedTWA,  -- Decents
		0.180000 + ExpectedTWA,  -- Way Offs
		0.320000 + ExpectedTWA,  -- Holds
		0.070000 + ExpectedTWA,  -- Mines
		0.350000 + ExpectedTWA,  -- Rolls
	}
	local TimingWindows = { "W1", "W2", "W3", "W4", "W5", "Hold", "Mine", "Roll" }
	local ExpectedLife = {
		 0.008,  -- Fantastics
		 0.008,  -- Excellents
		 0.004,  -- Greats
		 0.000,  -- Decents
		-0.050,  -- Way Offs
		-0.100,  -- Miss
		-0.080,  -- Let Go
		 0.008,  -- Held
		-0.050,  -- Hit Mine
	}
	local ExpectedScoreWeight = {
		 5,  -- Fantastics
		 4,  -- Excellents
		 2,  -- Greats
		 0,  -- Decents
		-6,  -- Way Offs
		-12,  -- Miss
		 0,  -- Let Go
		 5,  -- Held
		-6,  -- Hit Mine
	}
	local LifeWindows = { "W1", "W2", "W3", "W4", "W5", "Miss", "LetGo", "Held", "HitMine" }

	local Check = function(condition, errorString, badSettings)
		if not condition then
			badSettings[#badSettings + 1] = errorString
		end

		return condition
	end

	local badSettings = {}

	-- Originally verify the ComboToRegainLife metrics.
	valid[7] = Check(
		PREFSMAN:GetPreference("RegenComboAfterMiss") == 5 and PREFSMAN:GetPreference("MaxRegenComboAfterMiss") == 10,
		"- ComboToRegainLife Pref", badSettings
	)

	local FloatEquals = function(a, b)
		return math.abs(a-b) < 0.0001
	end

	local FloatLE = function(a, b)
		return a < b + 0.0001
	end

	valid[7] = Check(FloatEquals(THEME:GetMetric("LifeMeterBar", "InitialValue"), 0.5), "- Lifebar Initial Value", badSettings) and valid[7]
	valid[7] = Check(PREFSMAN:GetPreference("HarshHotLifePenalty"), "- HarshHotLifePenalty", badSettings) and valid[7]

	-- And then verify the windows themselves.
	local TWA = PREFSMAN:GetPreference("TimingWindowAdd")
	local pn = ToEnumShortString(player)
	if SL.Global.GameMode == "ITG" then
		for i, window in ipairs(TimingWindows) do
			-- Only check if the Timing Window is actually "enabled".
			if i > 5 or SL[pn].ActiveModifiers.TimingWindows[i] then
				valid[7] = Check(FloatEquals(PREFSMAN:GetPreference("TimingWindowSeconds"..window) + TWA, ExpectedWindows[i]), "- TimingWindow"..window, badSettings) and valid[7]
			end
		end

		for i, window in ipairs(LifeWindows) do
			-- We can support *harder* lifebars (i.e. <= the expected weights).
			valid[7] = Check(FloatLE(THEME:GetMetric("LifeMeterBar", "LifePercentChange"..window), ExpectedLife[i]), "- LifePercentChange"..window, badSettings) and valid[7]
		
			valid[7] = Check(THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeight"..window) == ExpectedScoreWeight[i], "- PercentScoreWeight"..window, badSettings) and valid[7]
		end
	end

	-- Validate Rate Mod
	local rate = SL.Global.ActiveModifiers.MusicRate * 100
	valid[8] = 100 <= rate and rate <= 300


	-- ------------------------------------------
	-- Finally, check player-specific modifiers used during this song that would invalidate the score.

	-- get playeroptions so we can check mods the player used
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")


	-- score is invalid if notes were removed
	valid[9] = not (
		po:Little()  or po:NoHolds() or po:NoStretch()
		or po:NoHands() or po:NoJumps() or po:NoFakes()
		or po:NoLifts() or po:NoQuads() or po:NoRolls()
	)

	-- score is invalid if notes were added
	valid[10] = not (
		po:Wide() or po:Skippy() or po:Quick()
		or po:Echo() or po:BMRize() or po:Stomp()
		or po:Big()
	)

	-- we can't use po:FailSetting() here because effective fail type can be overridden by preferences
	-- use GAMESTATE:GetPlayerFailType() since ScreenGameplay uses the same function internally
	local failType = GAMESTATE:GetPlayerFailType(player);
	-- only FailTypes "Immediate" and "ImmediateContinue" are valid for GrooveStats
	valid[11] = (failType == "FailType_Immediate" or failType == "FailType_ImmediateContinue")

	-- AutoPlay/AutoplayCPU is not allowed
	valid[12] = IsHumanPlayer(player)

	local minTNSToScoreNores = ToEnumShortString(PREFSMAN:GetPreference("MinTNSToScoreNotes"))

	if SL.Global.GameMode == "ITG" then
		-- The cut off for rehits is only allowed to be set to Greats (W3) or worse.
		-- Anything else is not allowed for GrooveStats submission.
		-- "invalid" options (like HitMine or something), resolve to TNS_None.
		valid[13] = minTNSToScoreNores ~= "W1" and minTNSToScoreNores ~= "W2"
	else
		-- Other game modes are not supported.
		valid[13] = false
	end

	-- ------------------------------------------
	-- return the entire table so that we can let the player know which settings,
	-- if any, prevented their score from being valid for GrooveStats

	local allChecksValid = true
	for _, passed_check in ipairs(valid) do
		if not passed_check then allChecksValid = false break end
	end

	-- Construct a string listing all invalid prefs for logging/display purposes.
	local badSettingsStr = table.concat(badSettings, "\n")

	return valid, allChecksValid, badSettingsStr
end

-- -----------------------------------------------------------------------

CreateCommentString = function(player)
	local pn = ToEnumShortString(player)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

	local suffixes = {"w", "e", "g", "d", "wo"}

	local comment = (SL.Global.GameMode == "FA+" or SL[pn].ActiveModifiers.ShowFaPlusWindow) and "FA+" or ""
	
	-- Show EX score for FA+ play
	if SL.Global.GameMode == "FA+" or (SL.Global.GameMode == "ITG" and SL[pn].ActiveModifiers.ShowFaPlusWindow) then
		comment = comment .. ", " .. ("%.2f"):format(CalculateExScore(player, GetExJudgmentCounts(player))) .. "EX"
	end

	local rate = SL.Global.ActiveModifiers.MusicRate
	if rate ~= 1 then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment..("%gx Rate"):format(rate)
	end

	-- Get EX judgment counts if playing with FA+ windows enabled in ITG mode
	if SL.Global.GameMode == "ITG" then
		local counts = GetExJudgmentCounts(player)
		local types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }
		
		for i=1,6 do
			local window = types[i]
			local number = counts[window] or 0
			local suffix = i == 6 and "m" or suffixes[i]
			
			if i == 1 then
				number = counts["W1"]
			end
			
			if number ~= 0 then
				if #comment ~= 0 then
					comment = comment .. ", "
				end
				comment = comment..number..suffix
			end
		end
	else
		-- Ignore the top window in all cases.
		for i=2, 6 do
			local idx = SL.Global.GameMode == "FA+" and i-1 or i
			local suffix = i == 6 and "m" or suffixes[idx]
			local tns = i == 6 and "TapNoteScore_Miss" or "TapNoteScore_W"..i
			
			local number = pss:GetTapNoteScores(tns)

			-- If the windows are disabled, then the number will be 0.
			if number ~= 0 then
				if #comment ~= 0 then
					comment = comment .. ", "
				end
				comment = comment..number..suffix
			end
		end
	end

	local timingWindowOption = ""

	if SL.Global.GameMode == "ITG" then
		if not SL[pn].ActiveModifiers.TimingWindows[4] and not SL[pn].ActiveModifiers.TimingWindows[5] then
			timingWindowOption = "No Dec/WO"
		elseif not SL[pn].ActiveModifiers.TimingWindows[5] then
			timingWindowOption = "No WO"
		elseif not SL[pn].ActiveModifiers.TimingWindows[1] and not SL[pn].ActiveModifiers.TimingWindows[2] then
			timingWindowOption = "No Fan/Exc"
		end
	end

	if #timingWindowOption ~= 0 then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment..timingWindowOption
	end

	local pn = ToEnumShortString(player)
	-- If a player CModded, then add that as well.
	local cmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod()
	if cmod ~= nil then
		if #comment ~= 0 then
			comment = comment .. ", "
		end
		comment = comment.."C"..tostring(cmod)
	end

	return comment
end

-- -----------------------------------------------------------------------

ParseGrooveStatsDate = function(date)
	if not date or #date == 0 then return "" end

	-- Dates are formatted like:
	-- YYYY-MM-DD HH:MM:SS
	local year, month, day, hour, min, sec = date:match("([%d]+)-([%d]+)-([%d]+) ([%d]+):([%d]+):([%d]+)")
	local monthMap = {
		["01"] = "Jan",
		["02"] = "Feb",
		["03"] = "Mar",
		["04"] = "Apr",
		["05"] = "May",
		["06"] = "Jun",
		["07"] = "Jul",
		["08"] = "Aug",
		["09"] = "Sep",
		["10"] = "Oct",
		["11"] = "Nov",
		["12"] = "Dec",
	}

	return monthMap[month].." "..tonumber(day)..", "..year
end

-- -----------------------------------------------------------------------
LoadUnlocksCache = function()
	local cache_file = "/Songs/unlocks-cache.json"
	if FILEMAN:DoesFileExist(cache_file) then
		local f = RageFileUtil:CreateRageFile()
		local cache = {}
		if f:Open(cache_file, 1) then
			local data = JsonDecode(f:Read())
			if data ~= nil then
				cache = data
			end
		end
		f:destroy()
		return cache
	end
	return {}
end

-- -----------------------------------------------------------------------
WriteUnlocksCache = function()
	local cache_file = "/Songs/unlocks-cache.json"
	local f = RageFileUtil:CreateRageFile()
	if f:Open(cache_file, 2) then
		f:Write(JsonEncode(SL.GrooveStats.UnlocksCache))
	end
	f:destroy()
end

-- -----------------------------------------------------------------------
-- Downloads an Event unlock and unzips it. If a download with the same URL and
-- destination pack name exists, the download attempt is skipped.
-- 
-- Args are:
--   url: string, the file to download from the web.
--   unlockName: string, an identifier for the download.
--               Used to display on ScreenDownloads
--   packName: string, The pack name to unlock the contents of the unlock to.
DownloadEventUnlock = function(url, unlockName, packName)
	-- Forward slash is not allowed in both Linux or Windows.
	-- All others are not allowed in Windows.
	local invalidChars = {
			["/"]="",
			["<"]="",
			[">"]="",
			[":"]="",
			["\""]="",
			["\\"]="",
			["|"]="",
			["?"]="",
			["*"]=""
	}
	packName = string.gsub(packName, ".", invalidChars)

	-- Reserved file names for Windows.
	local invalidFilenames = {
			["CON"]=true,
			["PRN"]=true,
			["AUX"]=true,
			["NUL"]=true,
			["COM1"]=true,
			["COM2"]=true,
			["COM3"]=true,
			["COM4"]=true,
			["COM5"]=true,
			["COM6"]=true,
			["COM7"]=true,
			["COM8"]=true,
			["COM9"]=true,
			["LPT1"]=true,
			["LPT2"]=true,
			["LPT3"]=true,
			["LPT4"]=true,
			["LPT5"]=true,
			["LPT6"]=true,
			["LPT7"]=true,
			["LPT8"]=true,
			["LPT9"]=true
	}
	-- If the packName is invalid, just append a space to it so it's not.
	if invalidFilenames[packName] then
		packName = " "..packName.." "
	end

	-- Check the download cache to see if we have already downloaded this unlock
	-- successfully to the intended location.
	-- Unlocks are placed in the cache whenever unlocks are bot successfully
	-- downloaded and zipped.
	if SL.GrooveStats.UnlocksCache[url] and SL.GrooveStats.UnlocksCache[url][packName] then
		return
	end

	-- Then check that the same download isn't already active in the Downloads
	-- table.
	for _, downloadInfo in pairs(SL.Downloads) do
		if downloadInfo.Url == url and downloadInfo.Destination == packName then
			return
		end
	end

	local uuid = CRYPTMAN:GenerateRandomUUID()
	local downloadfile = uuid..".zip"

	SL.Downloads[uuid] = {
		Name=unlockName,
		Url=url,
		Destination=packName,
		CurrentBytes=0,
		TotalBytes=0,
		Complete=false
	}

	-- Create the request separately. If the host is blocked it's possible that
	-- the SL.Downloads[uuid] table is assigned.
	SL.Downloads[uuid].Request = NETWORK:HttpRequest{
		url=url,
		downloadFile=downloadfile,
		onProgress=function(currentBytes, totalBytes)
			local downloadInfo = SL.Downloads[uuid]
			if downloadInfo == nil then return end

			downloadInfo.CurrentBytes = currentBytes
			downloadInfo.TotalBytes = totalBytes
		end,
		onResponse=function(response)
			local downloadInfo = SL.Downloads[uuid]
			if downloadInfo == nil then return end
			
			downloadInfo.Complete = true
			if response.error ~= nil then
				downloadInfo.ErrorMessage = response.errorMessage
				return
			end

			if response.statusCode == 200 then
				if response.headers["Content-Type"] == "application/zip" then
					-- Downloads are usually of the form:
					--    /Downloads/<name>.zip/<song_folders/
					local destinationPack = "/Songs/"..packName.."/"
					if not FILEMAN:Unzip("/Downloads/"..downloadfile, destinationPack) then
						downloadInfo.ErrorMessage = "Failed to Unzip!"
					else
						if SL.GrooveStats.UnlocksCache[url] == nil then
							SL.GrooveStats.UnlocksCache[url] = {}
						end
						SL.GrooveStats.UnlocksCache[url][packName] = true
						
						SL.NewDownloadsCompleted = true
						MESSAGEMAN:Broadcast("NewDownloadsCompleted")

						-- If Pack.ini doesn't exist (new unlock for this player), create it.
						local group = string.lower(packName)
						local year = 2026
						if string.find(group, "itl online "..year.." unlocks") then
							local packIniPath = destinationPack.."Pack.ini"
							if not FILEMAN:DoesFileExist(packIniPath) then
								IniFile.WriteFile(packIniPath, {
									["Group"]={
										["Version"]=1,
										["DisplayTitle"]=packName,
										["TranslitTitle"]=packName,
										["SortTitle"]=packName,
										["Series"]="ITL Online",
										["Year"]=year,
										["Banner"]="",
										["SyncOffset"]="NULL",
									}
								})
							end
						end

						WriteUnlocksCache()
					end
				else
					downloadInfo.ErrorMessage = "Download is not a Zip!"
					Warn("Attempted to download from \""..url.."\" which is not a zip!")
				end
			else
				downloadInfo.ErrorMessage = "Network Error "..response.statusCode
			end
		end,
	}
end

-- -----------------------------------------------------------------------
-- Iterates over the RequestCache and removes those entries that are older
-- than a certain amount of time.
RemoveStaleCachedRequests = function()
	local timeout = 1 * 60  -- One minute
	for requestCacheKey, data in pairs(SL.GrooveStats.RequestCache) do
		if GetTimeSinceStart() - data.Timestamp >= timeout then
			SL.GrooveStats.RequestCache[requestCacheKey] = nil
		end
	end
end

-- -----------------------------------------------------------------------
-- Functions to facilitate saving and loading player options stored in
-- GrooveStats.

-- Returns the list of keys in the SL table that are allowlisted to save to
-- GrooveStats.
-- NOTE: These are validated server-side.
CreateGrooveStatsPlayerOptionKeys = function()
	local CreateKey = function(optionType, strVals)
		local revMap = nil

		if optionType == "string" then
			if not strVals then
				-- If the option type is string, we need to provide a list of valid
				-- values.
				Trace("String option type created for key: "..key.." but no valid values provided.")
				return nil
			else
				revMap = {}
				-- If we have a list of valid values, create a reverse map.
				for k, v in pairs(strVals) do
					revMap[v] = k
				end
			end
		end

		return {
			["Type"]=optionType,
			["Map"]=strVals,
			["RevMap"]=revMap,
		}
	end

	-- We don't want to allow random string blobs to be saved to GrooveStats to
	-- prevent abuse, thus for string keys we return a table with an
	-- enumerated list of values that are allowed to be saved.
	--
	-- We try to use the same keys as those defined in the SL table for ease
	-- of implementation.
	--
	-- NOTE(teejusb): Yes I recognize that this limits which options can be saved
	-- to/restored from GrooveStats, especially in the case of custom themes, but
	-- this is necessary to prevent people from dumping arbitrary data to the
	-- server.
	return {
		["SpeedModType"] = CreateKey("string", {
			[1]="X",
			[2]="C",
			[3]="M"
		}),
		["SpeedMod"] = CreateKey("number"),
		["JudgmentGraphic"] = CreateKey("string", {
				[1]="Wendy Chroma 2x7 (doubleres).png",
				[2]="Bebas 2x7 (doubleres).png",
				[3]="Chromatic 2x7 (doubleres).png",
				[4]="Code 2x7 (doubleres).png",
				[5]="Comic Sans 2x7 (doubleres).png",
				[6]="Emoticon 2x7 (doubleres).png",
				[7]="Focus 2x7 (doubleres).png",
				[8]="Grammar 2x7 (doubleres).png",
				[9]="GrooveNights 2x7.png",
				[10]="ITG2 2x7 (doubleres).png",
				[11]="Love 2x7 (doubleres).png",
				[12]="Love Chroma 2x7 (doubleres).png",
				[13]="Miso 2x7 (doubleres).png",
				[14]="Papyrus 2x7 (doubleres).png",
				[15]="Rainbowmatic 2x7 (doubleres).png",
				[16]="Roboto 2x7 (doubleres).png",
				[17]="Shift 2x7 (doubleres).png",
				[18]="Tactics 2x7 (doubleres).png",
				[19]="Wendy 2x7 (doubleres).png",
				-- Digital Dance
				[100]="Chalk 2x7 (doubleres).png",
				[101]="Digital 2x7 (doubleres).png",
				[102]="Ice 2x7.png",
				[103]="ITG2 HD 2x7 (doubleres).png",
				[104]="Optimus Dark 2x7 (doubleres).png",
				[105]="Powerpuff HD 2x7 (doubleres).png",
				[106]="Reptilian 2x7 (doubleres).png",
				[107]="TRON 2x7 (doubleres).png",
		}),
		["ComboFont"] = CreateKey("string", {
			[1]="Arial Rounded",
			[2]="Asap",
			[3]="Bebas Neue",
			[4]="Source Code",
			[5]="Wendy",
			[6]="Wendy (Cursed)",
			[7]="Work",
		}),
		["HoldJudgment"] = CreateKey("string", {
			[1]="ITG2 1x2 (doubleres).png",
			[2]="Love 1x2 (doubleres).png",
			[3]="mute 1x2 (doubleres).png",
			[4]="None 1x2.png",
			-- Digital Dance
			[100]="Ice 1x2.png",
		}),
		["NoteSkin"] = CreateKey("string", {
			[1]="cel",
			[2]="cyber",
			[3]="ddr-note",
			[4]="ddr-rainbow",
			[5]="ddr-vivid",
			[6]="default",
			[7]="enchantment",
			[8]="lambda",
			[9]="metal",
		}),
		["BackgroundFilter"] = CreateKey("number"),
		["HideTargets"] = CreateKey("boolean"),
		["HideSongBG"] = CreateKey("boolean"),
		["HideCombo"] = CreateKey("boolean"),
		["HideLifebar"] = CreateKey("boolean"),
		["HideScore"] = CreateKey("boolean"),
		["HideDanger"] = CreateKey("boolean"),
		["HideComboExplosions"] = CreateKey("boolean"),
		["ColumnFlashOnMiss"] = CreateKey("boolean"),
		["SubtractiveScoring"] = CreateKey("boolean"),
		["MeasureCounter"] = CreateKey("string", {
			[1]="None",
			[2]="8th",
			[3]="16th",
			[4]="24th",
			[5]="32nd",
		}),
		["MeasureCounterLeft"] = CreateKey("boolean"),
		["MeasureCounterUp"] = CreateKey("boolean"),
		["HideLookahead"] = CreateKey("number"),
		["MeasureLines"] = CreateKey("string", {
			[1]="Off",
			[2]="Measure",
			[3]="Quarter",
			[4]="Eighth",
		}),
		["DataVisualizations"] = CreateKey("string", {
			[1]="None",
			[2]="Target Score Graph",
			[3]="Step Statistics",
		}),
		["TargetScore"] = CreateKey("number"),
		["ActionOnMissedTarget"] = CreateKey("string", {
			[1]="Nothing",
			[2]="Fail",
			[3]="Restart",
		}),
		["LifeMeterType"] = CreateKey("string", {
			[1]="Standard",
			[2]="Surround",
			[3]="Vertical",
			-- Digital Dance
			[100]="Top",
		}),
		["NPSGraphAtTop"] = CreateKey("boolean"),
		["JudgmentTilt"] = CreateKey("boolean"),
		["TiltMultiplier"] = CreateKey("number"),
		["ColumnCues"] = CreateKey("boolean"),
		["DisplayScorebox"] = CreateKey("boolean"),
		["ErrorBar"] = CreateKey("string", {
			[1]="None",
			[2]="Colorful",
			[3]="Monochrome",
			[4]="Text",
		}),
		["ErrorBarUp"] = CreateKey("boolean"),
		["ErrorBarMultiTick"] = CreateKey("boolean"),
		["ErrorBarTrim"] = CreateKey("string", {
			[1]="Off",
			[2]="Great",
			[3]="Excellent",
			-- Zmod option
			[4]="Fantastic",
		}),
		["HideEarlyDecentWayOffJudgments"] = CreateKey("boolean"),
		["HideEarlyDecentWayOffFlash"] = CreateKey("boolean"),
		["ShowFaPlusWindow"] = CreateKey("boolean"),
		["ShowExScore"] = CreateKey("boolean"),
		["ShowFaPlusPane"] = CreateKey("boolean"),
		["NoteFieldOffsetX"] = CreateKey("number"),
		["NoteFieldOffsetY"] = CreateKey("number"),

		---------------------------------------
		-- These are the official player options used by the engine.

		-- Only save a subset of them	since some of them are not that relevant.
		-- Also some things like SpeedMod are handled above.
		["Mini"] = CreateKey("number"),
		-- Usually Flip is all or nothing but ZMod uses percentages of it for the
		-- "Spacing" option
		["Flip"] = CreateKey("number"),
		["VisualDelay"] = CreateKey("number"),
		["Cover"] = CreateKey("boolean"), -- Hide Background
		["NoMines"] = CreateKey("boolean"),
		["Perspective"] = CreateKey("string", {
			[1]="Overhead",
			[2]="Hallway",
			[3]="Distant",
			[4]="Incoming",
			[5]="Space",
		}),

		-- In theory the engine allows saving multiple Turn options,
		-- but we don't want to support that behavior because it's kinda odd.
		["Turn"] = CreateKey("string", {
			[1]="Mirror",
			[2]="Left",
			[3]="Right",
			[4]="Shuffle",
			[5]="SuperShuffle", -- Blender
			[6]="HyperShuffle", -- Random
			[7]="LRMirror", -- LR-Mirror
			[8]="UDMirror", -- UD-Mirror
			[9]="Backwards",
		}),
		-- Similarly for scroll options, we only care about Reverse.
		-- Things like Split/Alternate/Cross/Centered are generally just
		-- "for fun" options.
		["Reverse"] = CreateKey("boolean"),
		["HideLightType"] = CreateKey("string", {
			[1]="NoHideLights",
			[2]="HideAllLights",
			[3]="HideMarqueeLights",
			[4]="HideBassLights",
		})
	}
end

-- Returns the stringified JSON blob for the specified players options.
GetPlayerOptionsJsonForGrooveStats = function(player)
	local options = {}
	local pn = ToEnumShortString(player)

	local MaybeSetOption = function(options, key, value, expectedType)
		local keyData = SL.Global.GrooveStatsPlayerOptionKeys[key]
		if keyData ~= nil then
			if keyData.Type == expectedType then
				if expectedType == "string" and type(value) == "string" then
					-- If the option is a string, we need to map it to the correct value.
					if keyData.RevMap and keyData.RevMap[value] then
						options[key] = keyData.RevMap[value]
					end
				elseif expectedType == "number" and type(value) == "number" then
					-- If the option is a number, we just use the value directly.
					options[key] = value
				elseif expectedType == "boolean" and type(value) == "boolean" then
					-- If the option is a boolean, we just use the value directly.
					options[key] = value and true or false
				end
			else
				Trace("Tried to set option for key: "..key.." but the expectedType is not :"..expectedType)
			end
		else
			Trace("Tried to set option for key: "..key.." but the key does not exist in the GrooveStatsPlayerOptionKeys.")
		end
	end

	-- First let's handle SL specific mods.
	for key, value in pairs(SL[pn].ActiveModifiers) do
		MaybeSetOption(options, key, value, type(value))
	end


	-- Then handle the actual player options.
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptionsArray("ModsLevel_Preferred")

	-- Mini and VisualDelay are special cases that we handle separately.
	-- They're stored as strings in the SL table, but we want to save them as
	-- numbers in the GrooveStats JSON.
	local mini = SL[pn].ActiveModifiers.Mini:gsub("%%", "")/1
	local visualDelay = SL[pn].ActiveModifiers.VisualDelay:gsub("ms","")/1

	-- Similarly, BackgroundFilter has options that directly map to numbers.
	local value = SL[pn].ActiveModifiers.BackgroundFilter
	local backgroundFilter = value and value or 0

	-- HideLookeahead is stored as a boolean in SL, but we want to save it as
	-- a number in GrooveStats.\
	-- We use 3 here since that's actually what SL represents, even though
	-- we'll collapse it down to true/false when loading from GrooveStats.
	local hideLookahead = SL[pn].ActiveModifiers.HideLookahead and 3 or 0

	local hasCover = false
	local hasNoMines = false
	local hasReverse = false

	for i, option in ipairs(po) do
		if option == "Cover" then
			hasCover = true
		elseif option == "NoMines" then
			hasNoMines = true
		elseif option == "Reverse" then
			hasReverse = true
		else
			-- This assumes each key is unique to the mod (which it should be).
			-- It basically goes through and attempts to assign every option to
			-- each of these keys.
			MaybeSetOption(options, "Perspective", option, "string")
			MaybeSetOption(options, "Turn", option, "string")
			MaybeSetOption(options, "HideLightType", option, "string")
		end
	end

	MaybeSetOption(options, "Mini", mini, "number")
	MaybeSetOption(options, "VisualDelay", visualDelay, "number")

	MaybeSetOption(options, "Cover", hasCover, "boolean")
	MaybeSetOption(options, "NoMines", hasNoMines, "boolean")
	MaybeSetOption(options, "Reverse", hasReverse, "boolean")

	return JsonEncode(options)
end

SetPlayerOptionsJsonFromGroovestats = function(player, jsonStr)
	if not jsonStr or #jsonStr == 0 then return end

	local options = JsonDecode(jsonStr)
	if not options then
		Trace("Failed to parse GrooveStats player options JSON: "..jsonStr)
		return
	end

	local pn = ToEnumShortString(player)
	local playerOptionsTable = {}
	local playerOptionsString = ""
	for key, value in pairs(options) do
		-- First let's check if the key is actually part of the SL table
		if SL[pn].ActiveModifiers[key] ~= nil then
			local keyData = SL.Global.GrooveStatsPlayerOptionKeys[key]
			if keyData ~= nil then
				if keyData.Type == "string" and type(value) == "number" then
					-- If the option is a string, we need to map it to the correct value.
					if keyData.Map and keyData.Map[value] then
						SL[pn].ActiveModifiers[key] = keyData.Map[value]
					else
						Trace("Tried to set option for key: "..key.." but the value: "..value.." is not in the map.")
					end
				elseif keyData.Type == "number" and type(value) == "number" then
					-- Some mods are special and need custom handling.
					-- Mini and VisualDelay are special in that we use strings to actually represent them in the SL table.
					-- Background Filter is saved as a number (for Zmod/DD) but SL saves it as a string
					-- HideLookahead is saved as a number (for Zmod) but SL is just binary
					if key == "Mini" then
						SL[pn].ActiveModifiers[key] = value.."%"
					elseif key == "VisualDelay" then
						SL[pn].ActiveModifiers[key] = value.."ms"
					elseif key == "BackgroundFilter" then
						local FilterAlpha = BackgroundFilterValues()
						-- Check if the value exists in the FilterAlpha table.
						for filterName, alpha in pairs(FilterAlpha) do
							if alpha == value then
								SL[pn].ActiveModifiers[key] = filterName
								break
							end
						end
					elseif key == "HideLookahead" then
						SL[pn].ActiveModifiers[key] = (value > 0) and true or false
					else
						-- If the option is a number, we just use the value directly.
						SL[pn].ActiveModifiers[key] = value
					end
				elseif keyData.Type == "boolean" and type(value) == "boolean" then
					SL[pn].ActiveModifiers[key] = value
				end
			end
		end

		-- And then explicitly check for the player options
		if key == "Cover" and value == true then
			playerOptionsTable[#playerOptionsTable + 1] = "Cover"
		elseif key == "NoMines" and value == true then
			playerOptionsTable[#playerOptionsTable + 1] = "NoMines"
		elseif key == "Reverse" and value == true then
			playerOptionsTable[#playerOptionsTable + 1] = "Reverse"
		elseif (key == "Perspective" or key == "Turn" or key == "HideLightType" or key == "NoteSkin") and type(value) == "number" then
			local keyData = SL.Global.GrooveStatsPlayerOptionKeys[key]
			if keyData ~= nil and keyData.Map ~= nil and keyData.Map[value] then
				-- If the option is a string, we need to map it to the correct value.
				playerOptionsTable[#playerOptionsTable + 1] = keyData.Map[value]
			end
		end
	end

	-- Also add in the SpeedMod and Mini options for player options.
	if SL[pn].ActiveModifiers.SpeedModType == "X" then
		playerOptionsTable[#playerOptionsTable + 1] = SL[pn].ActiveModifiers.SpeedMod.."x"
	elseif SL[pn].ActiveModifiers.SpeedModType == "C" then
		playerOptionsTable[#playerOptionsTable + 1] = "C"..SL[pn].ActiveModifiers.SpeedMod
	elseif SL[pn].ActiveModifiers.SpeedModType == "M" then
		playerOptionsTable[#playerOptionsTable + 1] = "m"..SL[pn].ActiveModifiers.SpeedMod
	end

	if SL[pn].ActiveModifiers.Mini == 100 then
		playerOptionsTable[#playerOptionsTable + 1] = "Mini"
	elseif SL[pn].ActiveModifiers.Mini ~= 0 then
		playerOptionsTable[#playerOptionsTable + 1] = SL[pn].ActiveModifiers.Mini.." Mini"
	end

	if SL[pn].ActiveModifiers.VisualDelay ~= "0ms" then
		playerOptionsTable[#playerOptionsTable + 1] = SL[pn].ActiveModifiers.VisualDelay.." VisualDelay"
	end

	-- And then set the player options string.
	if #playerOptionsTable > 0 then
		playerOptionsString = table.concat(playerOptionsTable, ", ")
		GAMESTATE:GetPlayerState(player):SetPlayerOptions("ModsLevel_Preferred", playerOptionsString)
		SL[pn].ActiveModifiers.PlayerOptionsString = playerOptionsString
	end
end