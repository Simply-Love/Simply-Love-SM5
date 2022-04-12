local player = ...
local pn = ToEnumShortString(player)

local year = Year()
local month = MonthOfYear()+1
local day = DayOfMonth()

local IsEventActive = function()
	-- The file is only written to while the event is active.
	-- These are just placeholder dates.
	local startTimestamp = 20220323
	local endTimestamp = 20220626

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


local DataForSong = function(player)
	local counts = GetExJudgmentCounts(player)
	local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Holds", "Rolls", "Mines" }
	local values = {}
	
	for key in ivalues(keys) do
		values[#values+1] = counts[key] or ""
	end
	
	local pn = ToEnumShortString(player)
	local hash = SL[pn].Streams.Hash
	local date = ("%04d-%02d-%02d"):format(year, month, day)
	local usedCmod = tostring(
		GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod() ~= nil
	)

	local line = ("%s,%s,%s,%s"):format(hash, table.concat(values, ","), usedCmod, date)
	return Encode(line).."\n"
end

local t = Def.ActorFrame {
	OnCommand=function(self)
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
			local data = DataForSong(player)

			-- Saving to memory cards won't work here as the USB won't be mounted.
			-- Save the data in a temporary table so that it can later be saved within
			-- Simply Love's SaveProfileCustom.
			if PROFILEMAN:ProfileWasLoadedFromMemoryCard(player) then
				SL[pn].ITLData[#SL[pn].ITLData + 1] = data
			-- For other profiles, we can just save after every song.
			else
				WriteItlFile(dir, data)
			end
		end
	end
}

return t