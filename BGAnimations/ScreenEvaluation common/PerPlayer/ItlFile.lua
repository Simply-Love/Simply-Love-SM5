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

		-- We require an explicit profile to be loaded.
		if (dir and #dir ~= 0 and
				GAMESTATE:IsHumanPlayer(player) and
				valid and
				rate == 1.0 and
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
				f:Write(existing..DataForSong(player))
			end
			f:destroy()
		end
	end
}

return t