local player = ...
local pn = ToEnumShortString(player)

local year = Year()
local month = MonthOfYear()+1
local day = DayOfMonth()

local IsEventActive = function()
	-- The file is only written to while the event is active.
	-- These are just placeholder dates.
	local startTimestamp = 20220331
	local endTimestamp = 20220330

	local today = year * 10000 + month * 100 + day

	return startTimestamp <= today and today <= endTimestamp
end

local style = GAMESTATE:GetCurrentStyle()
local game = GAMESTATE:GetCurrentGame()

if (SL.Global.GameMode == "Casual" or
		GAMESTATE:IsCourseMode() or
		not IsEventActive() or
		game:GetName() ~= "dance" or
		(style:GetName() ~= "single" and style:GetName() ~= "versus")) then
	return
end


-- Used to encode the lines of the file.
local Encode = function(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((data:gsub('.', function(x) 
		local r , b = '', x:byte()
		for i = 8, 1, -1 do
			r = r..(b % 2^i - b % 2^(i-1) > 0 and '1' or '0')
		end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c = 0
		for i = 1,6 do
			c = c + (x:sub(i,i) == '1' and 2^(6 - i) or 0)
		end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data % 3 + 1])
end


local DataForSong = function(pn, stats)
	-- TODO(teejusb): Have a helper function to get the appropriate judgment counts
	-- so we don't have to duplicate this logic.
	local TNS = { "W1", "W2", "W3", "W4", "W5", "Miss" }
	local RadarCategory = { "Holds", "Rolls", "Mines" }

	local counts = {}
	
	if SL.Global.GameMode == "FA+" then
		for window in ivalues(TNS) do
			-- Get the count.
			local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
			-- For the last window (Decent) in FA+ mode...
			if window == "W5" then
				-- If it's disabled, write an empty string.
				if not SL.Global.ActiveModifiers.TimingWindows[5] then
					counts[#counts+1] = ""
				-- Otherwise write the count.
				else
					counts[#counts+1] = tostring(number)
				end
				-- For the non-existent way off window, write the empty string.
				counts[#counts+1] = ""
			-- All other windows just gets the counts themselves.
			else
				counts[#counts+1] = tostring(number)
			end
		end
	elseif SL.Global.GameMode == "ITG" then
		for window in ivalues(TNS) do
			-- Get the count.
			local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
			-- We need to get the W0 count in ITG mode.
			if window == "W1" then
				local faPlus = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].W0_count
				-- Subtract white count from blue count
				number = number - faPlus
				-- Write the two numbers.
				counts[#counts+1] = tostring(faPlus)
				counts[#counts+1] = tostring(number)
			-- If a decent or way off window is disabled, write an empty string.
			elseif ((window == "W4" and not SL.Global.ActiveModifiers.TimingWindows[4]) or
					(window == "W5" and not SL.Global.ActiveModifiers.TimingWindows[5])) then
				counts[#counts+1] = ""
			-- All other cases, write the value itself.
			else
				counts[#counts+1] = tostring(number)
			end
		end
	end

	for RCType in ivalues(RadarCategory) do
		local number = stats:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..RCType )

		if RCType == "Mines" then
			number = possible - number
		end
		counts[#counts+1] = tostring(number)
	end

	local hash = SL[pn].Streams.Hash
	local date = ("%04d-%02d-%02d"):format(year, month, day)
	local usedCmod = tostring(
		GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod() ~= nil
	)

	local line = ("%s,%s,%s,%s"):format(hash, table.concat(counts, ","), usedCmod, date)
	return Encode(line).."\n"
end

local t = Def.ActorFrame {
	OnCommand=function(self)
		local pn = ToEnumShortString(player)

		local profile_slot = {
			[PLAYER_1] = "ProfileSlot_Player1",
			[PLAYER_2] = "ProfileSlot_Player2"
		}
		
		local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
		local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		
		-- Do the same validation as GrooveStats.
		-- This checks important things like timing windows, addition/removal of arrows, etc.
		local _, valid = ValidForGrooveStats(player)

		-- ITL additionally requires the music rate to be 1.00x.
		local so = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")
		local rate = so:MusicRate()

		-- We also require mines to be on.
		local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")
		local mines_enabled = not po:NoMines()

		-- We require an explicit profile to be loaded.
		if (dir and #dir ~= 0 and
				GAMESTATE:IsHumanPlayer(player) and
				valid and
				rate == 1.0 and
				mines_enabled and
				not stats:GetFailed()) then
			local path = dir.. "itl2022.itl"
			local f = RageFileUtil:CreateRageFile()
			-- Load the current contents of the file if it exists.
			local existing = ""
			if FILEMAN:DoesFileExist(path) then
				if f:Open(path, 1) then
					existing = f:Read()
				end
			end
			-- Append the new score to the file.
			if f:Open(path, 2) then
				f:Write(existing..DataForSong(pn, stats))
			end
			f:destroy()
		end
	end
}

return t