local player = ...
local pn = ToEnumShortString(player)

local year = Year()
local month = MonthOfYear()+1
local day = DayOfMonth()

local IsEventActive = function()
	-- The file is only written to while the event is active.
	-- These are just placeholder dates.
	local startTimestamp = 20220615
	local endTimestamp = 20221101

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

local isRpgFolder=function(self)
	local song = GAMESTATE:GetCurrentSong()
	local group = song:GetGroupName()
	local rpgsong = string.find(string.upper(group), "STAMINA RPG 6")
	return rpgsong
end


-- -----------------------------------------------------------------------
WriteRpgFile = function(dir, song, rate)
	local path = dir.. "SRPG6.rpg"
	local f = RageFileUtil:CreateRageFile()
	local existing = ""
	local recordType
	rate = tonumber(string.format("%.0f",rate*100))/100
	--local songrecord
	if FILEMAN:DoesFileExist(path) then
		-- Load the current contents of the file if it exists.
		if f:Open(path, 1) then
			existing = f:Read()
			-- Check if the song record already exists
			-- remove some annoying characters that break lua string function for some reason???
			song = song:gsub("%W","_")

			songposition = string.find(existing,song)
			if songposition == nil then recordType = "new"
			else
				-- find position of next equals sign
				equals = string.find(existing,"=",songposition)
				-- find end of the line
				newline = string.find(existing,"\n",equals)
				-- if end of file, get the last 
				if newline == nil then newline = string.len(existing) end
				
				-- get the old rate and convert to number
				oldrate = string.sub(existing,equals+1,newline)
				oldrate = tonumber(oldrate)

				if rate > oldrate then
					recordType = "beat"
				else
					recordType = "lost"
				end
			end
		end
	end

	rate = string.format("%.2f",rate)
	-- Append all the scores to the file.
	if f:Open(path, 2) then
		if recordType == "new" then 
			f:Write(existing..song .. "=" .. rate .. "\n") 
		end
		if recordType == "beat" then 
			oldstring = song .. "=" .. oldrate
			newstring = song .. "=" .. rate
			local data = string.gsub(existing,oldstring,newstring)
			f:Write(data)
		end
		if recordType == "lost" then 
			f:Write(existing)
		end
	end
	f:Close()
	f:destroy()
end


local t = Def.ActorFrame {
	OnCommand=function(self)
		if isRpgFolder() then 
			local profile_slot = {
				[PLAYER_1] = "ProfileSlot_Player1",
				[PLAYER_2] = "ProfileSlot_Player2"
			}
			local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
			local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

			local song = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
			-- Do the same validation as GrooveStats.
			-- This checks important things like timing windows, addition/removal of arrows, etc.
			local _, valid = ValidForGrooveStats(player)

			-- Get the rate mod
			local so = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")
			local rate = so:MusicRate()

			-- We require an explicit profile to be loaded.
			if (dir and #dir ~= 0 and
				GAMESTATE:IsHumanPlayer(player) and
				valid and
				rate >= 1.0 and
				not stats:GetFailed()) then
			
				WriteRpgFile(dir, song, rate)
			end
		end
	end
}

return t