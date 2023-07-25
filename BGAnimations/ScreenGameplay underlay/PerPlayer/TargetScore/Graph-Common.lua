local player, pss, isTwoPlayers, pos_data, target_score, personal_best, use_smaller_graph = unpack(...)
local pn = ToEnumShortString(player)

-- ---------------------------------------------------------------
local bothWantBars =   isTwoPlayers
                   and (SL.P1.ActiveModifiers.DataVisualizations == "Target Score Graph")
                   and (SL.P2.ActiveModifiers.DataVisualizations == "Target Score Graph")

-- ---------------------------------------------------------------
-- some helper functions local to this file

-- Ported from PSS.cpp, can be removed if that gets exported to Lua
local GetCurMaxPercentDancePoints = function()
	local possible = pss:GetPossibleDancePoints()
	if possible == 0 then
		return 0
	end
	local currentMax = pss:GetCurrentPossibleDancePoints()
	if currentMax == possible then
		return 1
	end
	return currentMax / possible
end

-- ---------------------------------------------------------------
-- Converts a percentage to an exponential scale, returning the corresponding Y point in the graph
local percentToYCoordinate = function(scorePercent)
	return -(pos_data.graph.h*math.pow(100,scorePercent)/100)
end

-- ---------------------------------------------------------------
-- used to determine when the player earns enough score to cross into the next grade tier
local currentGrade = nil
local previousGrade = nil

local af = Def.ActorFrame{

	InitCommand=function(self)
		-- this makes for a more convenient coordinate system
		-- (what does this^ mean?  -quietly)
		self:align(0,0)

		self:xy(pos_data.graph.x, pos_data.graph.y)
	end,
	OnCommand=function(self)
		currentGrade  = pss:GetGrade()
		previousGrade = currentGrade
	end,
	-- any time we receive a judgment
	JudgmentMessageCommand=function(self,params)
		currentGrade = pss:GetGrade()

		-- this broadcasts a message to tell other actors that we have changed grade
		if (currentGrade ~= previousGrade) then
			if currentGrade ~= "Grade_Failed" then
				self:queuecommand("GradeChanged")
			end
			previousGrade = currentGrade
		end
		self:queuecommand("Update")
	end,
}

if SL[pn].ActiveModifiers.DataVisualizations == "Target Score Graph" then
	local args = { player, pss, isTwoPlayers, bothWantBars, pos_data, target_score, personal_best, percentToYCoordinate, GetCurMaxPercentDancePoints}

	if use_smaller_graph then
		-- condensed graph for versus and when the notefield is centered
		af[#af+1] = LoadActor("./Graph-Small.lua", args)

	else
		-- full-width graph
		af[#af+1] = LoadActor("./Graph-FullWidth.lua", args)
	end
end

return af