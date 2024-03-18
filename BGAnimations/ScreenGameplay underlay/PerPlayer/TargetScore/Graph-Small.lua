local player, pss, isTwoPlayers, bothWantBars, pos_data,
      target_score, personal_best, percentToYCoordinate, GetCurMaxPercentDancePoints = unpack(...)
local pn = ToEnumShortString(player)

local GetPossibleExScore = function(counts)
	local best_counts = {}
	
	local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" }

	for key in ivalues(keys) do
		local value = counts[key]
		if value ~= nil then
			-- Initialize the keys	
			if best_counts[key] == nil then
				best_counts[key] = 0
			end

			-- Upgrade dropped holds/rolls to held.
			if key == "LetGo" or key == "Held" then
				best_counts["Held"] = best_counts["Held"] + value
			-- We never hit any mines.
			elseif key == "HitMine" then
				best_counts[key] = 0
			-- Upgrade to FA+ window.
			else
				best_counts["W0"] = best_counts["W0"] + value
			end
		end
	end
	
	local possible_ex_score, possible_total = CalculateExScore(player, best_counts)
	return possible_ex_score, possible_total
end

return Def.ActorFrame {

	-- insert the background actor frame
	LoadActor("./Graph-Background.lua", {player, pss, isTwoPlayers, bothWantBars, pos_data.graph, percentToYCoordinate}),

	-- BAR 1: Current Score
	Def.Quad{
		InitCommand=function(self)
			self:valign(1):halign(0)
				:zoomto(pos_data.bar.w, 1)
				:xy( pos_data.bar.spacing + pos_data.bar.offset, 0 )
		end,
		OnCommand=function(self)
			self:diffuse(Color.Blue)
		end,
		-- follow the player's score
		UpdateCommand=function(self)
			if not SL[pn].ActiveModifiers.ShowEXScore then
				local dp = pss:GetPercentDancePoints()
				self:zoomy(-percentToYCoordinate(dp))
			end
		end,
		ExCountsChangedMessageCommand=function(self, params)
			if SL[pn].ActiveModifiers.ShowEXScore then
				local dp = params.actual_points / params.actual_possible
				self:zoomy(-percentToYCoordinate(dp))
			end
		end
	},

	-- BAR 2: Target Score
	Def.Quad{
		InitCommand=function(self)
			self:valign(1):halign(0)
				:zoomto(pos_data.bar.w, 1)
				:xy( pos_data.bar.offset + pos_data.bar.spacing * 2 + pos_data.bar.w, 0 )
		end,
		OnCommand=function(self)
			self:diffuse(Color.Red)
		end,
		UpdateCommand=function(self)
			if not SL[pn].ActiveModifiers.ShowEXScore then
				local targetDP = target_score * GetCurMaxPercentDancePoints()
				self:zoomy(-percentToYCoordinate(targetDP))
			end
		end,
		ExCountsChangedMessageCommand=function(self, params)
			if SL[pn].ActiveModifiers.ShowEXScore then
				local PercentMax, DPCurrMax = GetPossibleExScore(params.ExCounts)
				local targetDP = target_score * GetCurMaxPercentDancePoints(DPCurrMax, params.actual_possible)
				self:zoomy(-percentToYCoordinate(targetDP))
			end
		end
	},

	-- Target Border
	Border(pos_data.bar.w + pos_data.BorderWidth * 2, -percentToYCoordinate(target_score)+3, pos_data.BorderWidth)..{
		InitCommand=function(self)
			self:xy(pos_data.bar.offset + pos_data.bar.spacing * 2 + pos_data.bar.w + pos_data.bar.w/2, percentToYCoordinate(target_score)/2)
		end,
	},
}