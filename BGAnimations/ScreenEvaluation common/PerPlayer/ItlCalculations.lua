-- Everything related to ITL 2023
-- TODO: Put the common functions in Scripts dir
-- TODO: make a hash->path function

local player = ...
local pn = ToEnumShortString(player)

-- Initial checks to see if we are dealing with an ITL song

local year = Year()
local month = MonthOfYear()+1
local day = DayOfMonth()

local isITLFolder=function(self)
	local song = GAMESTATE:GetCurrentSong()
	local group = song:GetGroupName()
	local itlsong = string.find(string.upper(group), "ITL ONLINE 2022")
	return itlsong
end

if not isITLFolder() then return end

local IsEventActive = function()
	-- The file is only written to while the event is active.
	-- These are just placeholder dates.
	local startTimestamp = 20230101
	local endTimestamp = 20240101

	local today = year * 10000 + month * 100 + day

	return startTimestamp <= today and today <= endTimestamp
end

if not IsEventActive() then return end

local style = GAMESTATE:GetCurrentStyle()
local game = GAMESTATE:GetCurrentGame()

if (SL.Global.GameMode == "Casual" or
		GAMESTATE:IsCourseMode() or
		not IsEventActive() or
		game:GetName() ~= "dance" or
		(style:GetName() ~= "single" and style:GetName() ~= "versus")) then
	return
end

-- Read/write/calculate functions
-- Pass type hierarchy 
local clearTypes = { "Pass", "FC", "FEC", "Quad", "Quint" }


-- Calculating max points for a song. This is only necessary in case something gets Boomshakalakka'd
-- TODO: parse steps into this function because it might not always be the current song
local itlCalculateMaxPoints = function()
	-- Just get this from the song description
	local song = GAMESTATE:GetCurrentSong()
	local steps = GAMESTATE:GetCurrentSteps(player)
	local name = steps:GetChartName()

	local maxPoints = name:gsub(" pts","")
	maxPoints = tonumber(maxPoints)
	
	return maxPoints
end

-- This will calculate the points based on the ex score * curve 
local itlCalculatePoints = function(steps, exScore)
	return true
end

-- Write Score info from file
-- TODO: So far it only works at the evaluation screen. 
-- Modify this script to be able to write from the songwheel on an API response too
local itlWrite = function() --steps,player,score, judgments)
	
	-- Hash
	local songHash = SL[pn].Streams.Hash
	
	-- song path
	song = GAMESTATE:GetCurrentSong()
	local songPath = song:GetSongDir()

	-- current points
	-- itlCalculatePoints(steps, exScore)
	local curPoints = 402

	-- max points
	local maxPoints = itlCalculateMaxPoints()

	-- Get clear type by calculating from judgments
	local judgments = GetExJudgmentCounts(player)

	-- If there are any disabled judgments, replace them with 0
	judgments["W0"] = judgments["W0"] and judgments["W0"] or 0
	judgments["W1"] = judgments["W1"] and judgments["W1"] or 0
	judgments["W2"] = judgments["W2"] and judgments["W2"] or 0
	judgments["W3"] = judgments["W3"] and judgments["W3"] or 0
	judgments["W4"] = judgments["W4"] and judgments["W4"] or 0
	judgments["W5"] = judgments["W5"] and judgments["W5"] or 0
	
	local clearType = 1 -- Start off with pass

	local judgmentCalc = 0
	-- Full combo
	judgmentCalc = judgmentCalc + judgments["Miss"] 
		+ judgments["W5"] -- Way Off
		+ judgments["W4"] -- Decent
		+ (judgments["totalRolls"] - judgments["Rolls"])
		+ (judgments["totalHolds"] - judgments["Holds"])
	
	if judgmentCalc == 0 then clearType = 2 end 

	judgmentCalc = judgmentCalc + judgments["W3"] -- Great
	if judgmentCalc == 0 then clearType = 3 end 

	judgmentCalc = judgmentCalc + judgments["W2"] -- Excellent
	if judgmentCalc == 0 then clearType = 4 end 

	judgmentCalc = judgmentCalc + judgments["W1"] -- White Fantastic
	if judgmentCalc == 0 then clearType = 5 end 

	SM(clearType)
	local ITLinfo = {path=songPath,points=curPoints,max=maxPoints,clearType=clearType}

	-- Open file
	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])

	local path = dir.. "itl2023Songwheel.itl"
	local f = RageFileUtil:CreateRageFile()
	local currentScores
	if not FILEMAN:DoesFileExist(path) then
		-- Create empty file and write score on there
		if f:Open(path, 2) then
			itlData = {}
			itlData.pathMap = {}
			itlData.scoreMap = {}
			itlData.pathMap[songPath] = songHash
			itlData.scoreMap[songHash] = ITLinfo
			f:Write(JsonEncode(itlData))
		end		
	else
		if f:Open(path, 1) then
			existing = f:Read()
			currentScores = JsonDecode(existing)
			-- Compare info
			oldScore = currentScores.scoreMap[songHash]
			f:Close()
			if oldScore then
				-- if improved scores, update existing
				local updated = false
				if curPoints > oldScore["points"] then 
					oldScore["points"] = curPoints 
					updated = true 
				end
				if clearType > oldScore["clearType"] then 
					oldScore["clearType"] = clearType 
					updated = true 
				end
				if updated and f:Open(path, 2) then
					f:Write(JsonEncode(currentScores))
				end
			else
				if f:Open(path, 2) then
					-- if new score, write all info file
					currentScores.pathMap[songPath] = songHash
					currentScores.scoreMap[songHash] = ITLinfo
					f:Write(JsonEncode(currentScores))
				end
			end
		end
	end
	
	f:Close()
	f:destroy()

	return true
end

-----------

local t = Def.ActorFrame {
	OnCommand=function(self)
		SM(itlWrite())
	end
}

return t