local NumPanes = ...
local players = GAMESTATE:GetHumanPlayers()

local af = Def.ActorFrame{}
af.Name="Panes"

local offset = {
	[PLAYER_1] = _screen.cx-155,
	[PLAYER_2] = _screen.cx+155
}

-- -----------------------------------------------------------------------
-- Note: Some of these Pane actors may be nil. This is not a bug, but
--       a feature for any panes we want to be conditional.  -teejusb

if #players == 2 or SL.Global.GameMode=="Casual" then
	for player in ivalues(players) do
		-- add Panes for this player to the ActorFrame using a simple, numerical for-loop
		for i=1, NumPanes do
			local pn   = ToEnumShortString(player)
			local pane = LoadActor("./Pane"..i, {player, player})

			if pane then
				af[#af+1] = Def.ActorFrame{
					Name="Pane"..i.."_Side"..pn,
					InitCommand=function(self) self:x(offset[player]) end,
					pane
				}
			end
		end
	end

elseif #players == 1 then
	-- When only one player is joined (single, double, solo, etc.), we end up loading each
	-- Pane twice, effectively doing the same work twice.
	--
	-- This approach (loading two of each Pane, even in single) was easier for me to write
	-- InputHandling for.  An approach I considered was loading one of each pane and then
	-- moving the panes around (between left and right sides of ScreenEval) via InputHandling.
	-- That was less computional work (not loading everything twice), but it was more work
	-- for my milquetoast mind. (-quietly)
	--
	-- Some of the Panes (QR code, timing histogram) contain expensive computation that can
	-- delay ScreenEvaluation's load time, *especially* when performed twice.  If only one
	-- player is joined, it's wasteful to do these identical calculations twice.
	--
	-- So, use ComputedData as a table local to this file (it won't persist past ScreenEvaluation)
	-- and pass it into Pane sub-files as a "reference" to achieve pointer-like behavior within
	-- the scoping contexts that exist within this file within ScreenEvaluation.  In this way, we can
	-- check if some expensive calculations have already been run, and refer to the ComputedData
	-- table to get the results.
	local ComputedData = {}

	local mpn = GAMESTATE:GetMasterPlayerNumber()

	for i=1, NumPanes do
		local left_pane  = LoadActor("./Pane"..i, {mpn, PLAYER_1, ComputedData})
		local right_pane = LoadActor("./Pane"..i, {mpn, PLAYER_2, ComputedData})

		-- These need to be wrapped in an extra AF to offset left and right.
		-- Panes can be nil, however, so don't add extra AFs with nil children
		if left_pane and right_pane then
			af[#af+1] = Def.ActorFrame{
				Name="Pane"..i.."_SideP1",
				InitCommand=function(self) self:x(offset.PlayerNumber_P1) end,
				left_pane
			}
			af[#af+1] = Def.ActorFrame{
				Name="Pane"..i.."_SideP2",
				InitCommand=function(self) self:x(offset.PlayerNumber_P2) end,
				right_pane
			}
		end
	end
end

return af