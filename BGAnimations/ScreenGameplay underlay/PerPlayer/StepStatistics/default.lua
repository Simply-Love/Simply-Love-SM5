local player = ...
local pn = ToEnumShortString(player)
local ar = GetScreenAspectRatio()

-- if the conditions aren't right, don't bother
if SL[pn].ActiveModifiers.DataVisualizations ~= "Step Statistics"
or SL.Global.GameMode == "Casual"
or (ar < 21/9 -- less wide than ultrawide
and GAMESTATE:GetCurrentStyle():GetName() ~= "single"
and (PREFSMAN:GetPreference("Center1Player") and not IsUsingWideScreen()))
then
	return
end

-- -----------------------------------------------------------------------

local header_height   = 80
local notefield_width = GetNotefieldWidth()
local sidepane_width  = _screen.w/2
local sidepane_pos_x  = _screen.w * (player==PLAYER_1 and 0.75 or 0.25)

if ar < 21/9 then
	if PREFSMAN:GetPreference("Center1Player") and IsUsingWideScreen()  then
		sidepane_width = (_screen.w - GetNotefieldWidth()) / 2

		if player==PLAYER_1 then
			sidepane_pos_x = _screen.cx + notefield_width + (sidepane_width-notefield_width)/2
		else
			sidepane_pos_x = _screen.cx - notefield_width - (sidepane_width-notefield_width)/2
		end
	end

-- ultrawide or wider
else
	if #GAMESTATE:GetHumanPlayers() > 1 then
		sidepane_width = _screen.w/5
		if player==PLAYER_1 then
			sidepane_pos_x = sidepane_width/2
		else
			sidepane_pos_x = _screen.w - (sidepane_width/2)
		end
	end
end


-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}
af.Name="StepStatsPane"..pn
af.InitCommand=function(self)
	self:x(sidepane_pos_x):y(_screen.cy + header_height)
end

af[#af+1] = LoadActor("./DarkBackground.lua", {player, header_height, sidepane_width})

-- banner, judgment labels, and judgment numbers will be collectively shrunk
-- if Center1Player is enabled to accommodate the smaller space
af[#af+1] = Def.ActorFrame{
	InitCommand=function(self)
		local zoomfactor = {
			twentyone_nine = 0.725,
			sixteen_ten  = 0.825,
			sixteen_nine = 0.925
		}

		if ar < 21/9 then
			if (PREFSMAN:GetPreference("Center1Player") and IsUsingWideScreen()) then
				local zoom = scale(GetScreenAspectRatio(), 16/10, 16/9, zoomfactor.sixteen_ten, zoomfactor.sixteen_nine)
				self:zoom( zoom )
			end

		else
			if #GAMESTATE:GetHumanPlayers() > 1 then
				self:zoom(zoomfactor.twentyone_nine):addy(-55)
			end
		end
	end,

	LoadActor("./Banner.lua", player),
	LoadActor("./JudgmentLabels.lua", player),
	LoadActor("./JudgmentNumbers.lua", player),
}

af[#af+1] = LoadActor("./DensityGraph.lua", {player, sidepane_width})

return af