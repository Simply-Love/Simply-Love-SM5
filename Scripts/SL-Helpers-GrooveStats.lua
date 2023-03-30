GrooveStatsURL = function()
	-- For test GrooveStats responses, create a file called GrooveStats_UAT.txt
	-- in your theme's Other directory. To toggle between live and UAT, delete/rename this file.
	-- Requires gsapi-mock and adding 127.0.0.1 to HttpAllowHosts in Preferences.ini
	local url_prefix
	local dir = THEME:GetCurrentThemeDirectory() .. "Other/"
	local uat = dir .. "GrooveStats_UAT.txt"
	if not FILEMAN:DoesFileExist(uat) then 
		url_prefix = "https://api.groovestats.com/" 
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
--         endpoint="new-session.php?chartHashVersion="..SL.GrooveStats.ChartHashVersion,
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
				connectTimeout=timeout/2,
				transferTimeout=timeout/2,
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

					self:GetChild("Spinner"):visible(false)
				end,
			}
			-- Keep track of when we started making the request
			self.request_time = GetTimeSinceStart()
			-- Start looping for the spinner.
			self:queuecommand("GrooveStatsRequestLoop")
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
			LoadFont("Common Normal")..{
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
	if not player then return "" end

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
			elseif k == "IsPadPlayer" then
				-- Must be explicitly set to 1.
				if v == 1 then
					SL[pn].IsPadPlayer = true
				else
					SL[pn].IsPadPlayer = false
				end
			end
		end
	end
end

-- -----------------------------------------------------------------------
-- The common conditions required to use the GrooveStats services.
-- Currently the conditions are:
--  - GrooveStats is enabled in the operator menu.
--  - We were successfully able to make a GrooveStats conenction previously.
--  - We must be in the "dance" game mode (not "pump", etc)
--  - We must be in either ITG or FA+ mode.
--  - At least one Api Key must be available (this condition may be relaxed in the future)
--  - We must not be in course mode (ZANKOKU: moving this specific check to autosubmitscore instead, since otherwise it blocks scorebox when playing course mode).
IsServiceAllowed = function(condition)
	return (condition and
		ThemePrefs.Get("EnableGrooveStats") and
		SL.GrooveStats.IsConnected and
		GAMESTATE:GetCurrentGame():GetName()=="dance" and
		(SL.Global.GameMode == "ITG" or SL.Global.GameMode == "FA+") and
		(SL.P1.ApiKey ~= "" or SL.P2.ApiKey ~= "") -- and
		-- not GAMESTATE:IsCourseMode())
		)
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
	local pn = ToEnumShortString(player)
	local valid = {}

	-- ------------------------------------------
	-- First, check for modes not supported by GrooveStats.

	-- GrooveStats only supports dance for now (not pump, techno, etc.)
	valid[1] = GAMESTATE:GetCurrentGame():GetName() == "dance"

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
	valid[4] = (SL.Global.GameMode == "ITG" or SL.Global.GameMode == "FA+")

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

	-- Originally verify the ComboToRegainLife metrics.
	valid[7] = (PREFSMAN:GetPreference("RegenComboAfterMiss") == 5 and PREFSMAN:GetPreference("MaxRegenComboAfterMiss") == 10)

	local FloatEquals = function(a, b)
		return math.abs(a-b) < 0.0001
	end

	valid[7] = valid[7] and FloatEquals(THEME:GetMetric("LifeMeterBar", "InitialValue"), 0.5)
	valid[7] = valid[7] and PREFSMAN:GetPreference("HarshHotLifePenalty")

	-- And then verify the windows themselves.
	local TWA = PREFSMAN:GetPreference("TimingWindowAdd")
	if SL.Global.GameMode == "ITG" then
		for i, window in ipairs(TimingWindows) do
			-- Only check if the Timing Window is actually "enabled".
			if i > 5 or SL[pn].ActiveModifiers.TimingWindows[i] then
				valid[7] = valid[7] and FloatEquals(PREFSMAN:GetPreference("TimingWindowSeconds"..window) + TWA, ExpectedWindows[i])
			end
		end

		for i, window in ipairs(LifeWindows) do
			valid[7] = valid[7] and FloatEquals(THEME:GetMetric("LifeMeterBar", "LifePercentChange"..window), ExpectedLife[i])

			valid[7] = valid[7] and THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeight"..window) == ExpectedScoreWeight[i]
		end
	elseif SL.Global.GameMode == "FA+" then
		for i, window in ipairs(TimingWindows) do
			-- This handles the "offset" for the FA+ window, while also retaining the correct indices for Holds/Mines/Rolls
			-- i idx
			-- 1  * - FA+ (idx doesn't matter as we explicitly handle the i == 1 case)
			-- 2  1 - Fantastic
			-- 3  2 - Excellent
			-- 4  3 - Greats
			-- 5  4 - Decents
			-- 6  6 - Holds (notice how we skipped idx == 5, which would've been the Way Off window)
			-- 7  7 - Mines
			-- 8  8 - Rolls
			-- Only check if the Timing Window is actually "enabled".
			if i > 5 or SL[pn].ActiveModifiers.TimingWindows[i] then
				local idx = (i < 6 and i-1 or i)
				if i == 1 then
					-- For the FA+ fantastic, the first window can be anything as long as it's <= the actual fantastic window
					-- We could use FloatEquals here, but that's a 0.0001 margin of error for the equality case which I think 
					-- will be generally irrelevant.
					valid[7] = valid[7] and (PREFSMAN:GetPreference("TimingWindowSeconds"..window) + TWA <= ExpectedWindows[1])
				else
					valid[7] = valid[7] and FloatEquals(PREFSMAN:GetPreference("TimingWindowSeconds"..window) + TWA, ExpectedWindows[idx])
				end
			end
		end

		for i, window in ipairs(LifeWindows) do
			local idx = (i < 6 and i-1 or i)
			if i == 1 then
				valid[7] = valid[7] and FloatEquals(THEME:GetMetric("LifeMeterBar", "LifePercentChange"..window), ExpectedLife[1])
				valid[7] = valid[7] and THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeight"..window) == ExpectedScoreWeight[1]
			else
				valid[7] = valid[7] and FloatEquals(THEME:GetMetric("LifeMeterBar", "LifePercentChange"..window), ExpectedLife[idx])
				valid[7] = valid[7] and THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeight"..window) == ExpectedScoreWeight[idx]
			end
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

	-- only FailTypes "Immediate" and "ImmediateContinue" are valid for GrooveStats
	valid[11] = (po:FailSetting() == "FailType_Immediate" or po:FailSetting() == "FailType_ImmediateContinue")

	-- AutoPlay/AutoplayCPU is not allowed
	valid[12] = IsHumanPlayer(player)

	-- ------------------------------------------
	-- return the entire table so that we can let the player know which settings,
	-- if any, prevented their score from being valid for GrooveStats

	local allChecksValid = true
	for _, passed_check in ipairs(valid) do
		if not passed_check then allChecksValid = false break end
	end

	return valid, allChecksValid
end

-- -----------------------------------------------------------------------

CreateCommentString = function(player)
	local pn = ToEnumShortString(player)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

	local suffixes = {"w", "e", "g", "d", "wo"}

	local comment = (SL.Global.GameMode == "FA+" or SL[pn].ActiveModifiers.ShowFaPlusWindow) and "FA+" or ""
	
	-- Show EX score for FA+ play
	if SL.Global.GameMode == "FA+" or (SL.Global.GameMode == "ITG" and SL[pn].ActiveModifiers.ShowFaPlusWindow) then
		comment = comment .. ", " .. ("%.2f"):format(CalculateExScore(player)) .. "EX"
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
		local types = { 'W1', 'W2', 'W3', 'W4', 'W5' }
		
		for i=1,6 do
			local window = types[i]
			local number = counts[window] or 0
			local suffix = i == 6 and "m" or suffixes[i]
			
			if i == 1 then
				number = counts["W115"]
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
	elseif SL.Global.GameMode == "FA+" then
		if not SL[pn].ActiveModifiers.TimingWindows[4] and not SL[pn].ActiveModifiers.TimingWindows[5] then
			timingWindowOption = "No Gre/Dec/WO"
		elseif not SL[pn].ActiveModifiers.TimingWindows[5] then
			timingWindowOption = "No Dec/WO"
		elseif not SL[pn].ActiveModifiers.TimingWindows[1] and not SL[pn].ActiveModifiers.TimingWindows[2] then
			-- Weird flex but okay
			timingWindowOption = "No Fan/WO"
		else
			-- Way Offs are always removed in FA+ mode.
			timingWindowOption = "No WO"
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

ParseGroovestatsDate = function(date)
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
					if not FILEMAN:Unzip("/Downloads/"..downloadfile, "/Songs/"..packName.."/") then
						downloadInfo.ErrorMessage = "Failed to Unzip!"
					else
						if SL.GrooveStats.UnlocksCache[url] == nil then
							SL.GrooveStats.UnlocksCache[url] = {}
						end
						SL.GrooveStats.UnlocksCache[url][packName] = true

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
