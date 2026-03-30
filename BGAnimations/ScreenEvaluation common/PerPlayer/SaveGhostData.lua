local player = ...
local pn = ToEnumShortString(player)

if SL.Global.GameMode == "Casual" then return end

-- We only want to count it if the user didn't fail
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player) 
if stats:GetFailed() then return end

local itg = SL[ToEnumShortString(player)].CurrentSongJudgments.ITG
local ex = SL[ToEnumShortString(player)].CurrentSongJudgments.EX

-- Takes the Ghost Data loaded in memory and writes it to the local profile.
WriteGhostData = function(player, songHash)
	local pn = ToEnumShortString(player)

	-- set initial array of dance points to write
	local array = {}
	array["itg"] = itg
	array["ex"] = ex

	currITG = itg[#itg]
	currEX = ex[#ex]

	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	
	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	-- We require an explicit profile to be loaded.
	if not dir or #dir == 0 then return end

	-- Individual file per song so we don't load entire play history in memory
	local path = dir .. "GhostData/" .. songHash .. ".json"

	-- set flag to update
	local updateitg = true
	local updateex = true

	-- Read current record
	local f = RageFileUtil:CreateRageFile()
	if FILEMAN:DoesFileExist(path) then
		if f:Open(path, 1) then		
			local old = f:Read()
			old = JsonDecode(old)
			oldITG = old["itg"][#old["itg"]]
			oldEX = old["ex"][#old["ex"]]			
			if oldITG >= currITG then 
				array["itg"] = old["itg"] 
				updateitg = false
			end
			if oldEX >= currEX then 
				array["ex"] = old["ex"]
				updateex = false 
			end
			f:Close()
		end
		f:destroy()
	end
	
	local f = RageFileUtil:CreateRageFile()
	if updateitg or updateex then
		if f:Open(path, 2) then		
			f:Write(JsonEncode(array))
			f:Close()		
		end
		f:destroy()
	end
end

return Def.Actor{
	OnCommand=function(self)
		-- get song hash
		local hash = SL[pn].Streams.Hash
		WriteGhostData(player,hash)
	end
}
