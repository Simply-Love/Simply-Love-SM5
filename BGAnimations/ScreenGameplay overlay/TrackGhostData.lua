------------------------------------------------------------
-- This file keeps track of realtime ITG and EX dance points for Subtractive Scoring
-- This needs to record regardless of if the user has subtractive scoring enabled or not.
-- If the user passed, it will compare ITG and EX and update ghost data if necessary
------------------------------------------------------------

-- don't bother tracking for Casual gamemode
if SL.Global.GameMode == "Casual" then return end

local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
SL[pn].CurrentSongJudgments = {}
SL[pn].CurrentSongJudgments.ITG = {}
SL[pn].CurrentSongJudgments.EX = {}
local itg = SL[pn].CurrentSongJudgments.ITG
local ex = SL[pn].CurrentSongJudgments.EX


local currentdp_itg = 0
local currentdp_ex = 0
local game = SL.Global.GameMode
local songHash = SL[pn].Streams.Hash

local valid_tns = {
	-- Emulated, not a real TNS.
	W0 = true,

	-- Actual TNS's
	W1 = true,
	W2 = true,
	W3 = true,
	W4 = true,
	W5 = true,
	Miss = true,
	HitMine = true
}

local valid_hns = {
	LetGo = true,
	Held = true
}

local currentScore
local TargetScore
local possible
local ghost

local ghostdata = true

local possible = stats:GetPossibleDancePoints()
local a, b, possibleex

return Def.Actor{
	OnCommand=function(self)
		if mods.TargetScore == "Ghost Data" then	
			a,b,possibleex = CalculateExScore(player)
			local profile_slot = {
				[PLAYER_1] = "ProfileSlot_Player1",
				[PLAYER_2] = "ProfileSlot_Player2"
			}
		
			local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
			-- We require an explicit profile to be loaded.
			if not dir or #dir == 0 then return end
		
			local path = dir .. "GhostData/" .. songHash .. ".json"
		
			local f = RageFileUtil:CreateRageFile()
			if FILEMAN:DoesFileExist(path) then
				if f:Open(path, 1) then			
					ghost = f:Read()
					ghost = JsonDecode(ghost)
		
					-- Get ghost data for the scoring system in use
					if mods.ShowExScore then ghost = ghost["ex"] else ghost = ghost["itg"] end
		
					f:Close()
				end
				f:destroy()
			else
				ghostdata = false
				MESSAGEMAN:Broadcast("NoGhostData",{player=player})
			end
		end
	end,
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if IsAutoplay(player) then return end

		if params.HoldNoteScore then
			local HNS = ToEnumShortString(params.HoldNoteScore)
			-- Only track the HoldNoteScores we care about
			if valid_hns[HNS] then
				if not stats:GetFailed() then
					-- ITG
					currentdp_itg = currentdp_itg + SL["Metrics"][game]["GradeWeight"..HNS]
					-- EX
					currentdp_ex = currentdp_ex + SL["ExWeights"][HNS]
				end
			end
			itg[#itg+1] = currentdp_itg
			ex[#ex+1] = currentdp_ex
		-- HNS also contain TNS. We don't want to double count so add an else if.
		elseif params.TapNoteScore then
			local TNS = ToEnumShortString(params.TapNoteScore)
			if valid_tns[TNS] then
				-- ITG
				currentdp_itg = currentdp_itg + SL["Metrics"][game]["GradeWeight"..TNS]

				-- EX
				if TNS == "W1" then
					-- Check if this W1 is actually in the W0 window
					local is_W0 = IsW0Judgment(params, player)
					if is_W0 then
						if not stats:GetFailed() then
							currentdp_ex = currentdp_ex + SL["ExWeights"]["W0"]
						end
					elseif is_W015 then
						if not stats:GetFailed() then
							currentdp_ex = currentdp_ex + SL["ExWeights"]["W1"]
						end
					else
						if not stats:GetFailed() then
							currentdp_ex = currentdp_ex + SL["ExWeights"][TNS]
						end
					end
				else
					-- Only track the TapNoteScores we care about
					if valid_tns[TNS] then
						if not stats:GetFailed() then
							currentdp_ex = currentdp_ex + SL["ExWeights"][TNS]
						end
					end
				end
			end
			itg[#itg+1] = currentdp_itg
			ex[#ex+1] = currentdp_ex
		end

		-- If the user is doing Ghost Data, also calculate pace against ghost because we're already doing the calculations here
		if mods.TargetScore == "Ghost Data" and ghostdata then
			if mods.ShowExScore then
				currentScore = currentdp_ex
				TargetScore = ghost[#ex]
				possible = possibleex
			else 
				currentScore = currentdp_itg
				TargetScore = ghost[#itg]				
			end
			MESSAGEMAN:Broadcast("GhostDataUpdated",{player=params.Player,current=currentScore,target=TargetScore,possible=possible})
		end		
	end,
}