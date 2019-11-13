local FiltersOkay = function()
	local minSteps = SL.Global.ActiveFilters["MinSteps"]
	local maxSteps = SL.Global.ActiveFilters["MaxSteps"]
	local minDifficulty = SL.Global.ActiveFilters["MinDifficulty"]
	local maxDifficulty = SL.Global.ActiveFilters["MaxDifficulty"]
	local minJumps = SL.Global.ActiveFilters["MinJumps"]
	local maxJumps = SL.Global.ActiveFilters["MaxJumps"]
	
	if minSteps ~= "Off" and maxSteps ~= "Off" then
		if tonumber(minSteps) > tonumber(maxSteps) then
			SM("WARNING: Min Steps must be less than or equal to Max Steps")
			return false
		end
	end
	if minDifficulty ~= "Off" and maxDifficulty ~= "Off" then
		if tonumber(minDifficulty) > tonumber(maxDifficulty) then
			SM("WARNING: Min Difficulty must be less than or equal to Max Difficulty")
			return false
		end
	end
	if minJumps ~= "Off" and maxJumps ~= "Off" then
		if tonumber(minJumps) > tonumber(maxJumps) then
			SM("WARNING: Min Jumps must be less than or equal to Max Jumps")
			return false
		end
	end
	if SL.Global.ActiveFilters["HidePassed"] and SL.Global.ActiveFilters["HideFailed"] and SL.Global.ActiveFilters["HideUnplayed"] then
		SM("WARNING: You can't hide all songs!")
		return false
	end
	if SL.Global.ActiveFilters["HideTags"] then
		local allTrue = true
		for tag in ivalues(GetGroups("Tag")) do
			if SL.Global.ActiveFilters["HideTags"][tag] == false then allTrue = false end
		end
		if allTrue then 
			SM("WARNING: YOu can't hide all tags!")
			return false
		end
	end
	return true
end

local InputHandler = function(event)
	if not event then return false end
	if event.type == "InputEventType_FirstPress" and event.GameButton == "Back" then
		if FiltersOkay() then SCREENMAN:GetTopScreen():Cancel() return true
		else SCREENMAN:SetNewScreen("ScreenFilterOptions") end
	end
	return false
end

return Def.Actor{
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( InputHandler ) end,

	-- OffCommand() will be called if the player tries to leave the operator menu by choosing an OptionRow
	-- it will not be called if the player presses the "Back" MenuButton (typically Esc on a keyboard),
	-- so we handle that case using a Lua InputCallback function
	OffCommand=function(self)
		if not FiltersOkay() then
			SCREENMAN:SetNewScreen("ScreenFilterOptions")
		end
	end
}