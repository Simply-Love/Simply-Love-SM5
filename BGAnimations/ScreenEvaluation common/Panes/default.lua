local NumPanes = ...
local pane_definitions = {}
for i=1, NumPanes do
	local path = THEME:GetPathB("ScreenEvaluation", "common/Panes/Pane"..i.."/default.lua")
	pane_definitions[#pane_definitions+1] = {
		Name="Pane"..i,
		Load=function(args) return LoadActor(path, args) end
	}
end

-- Modules can change this ordered list before any panes are loaded.
-- How does this work you ask? well, you would first have a Module that is
-- listening for the "EvaluationPanes" message. When this message is broadcast
-- the module can use params.Panes to modify the list of panes before they are loaded.
-- That way a Module could both inject new panes and modify existing ones before they are loaded.
MESSAGEMAN:Broadcast("EvaluationPanes", {Panes=pane_definitions})

local names = {}
for pane in ivalues(pane_definitions) do
	-- We use this to somewhat validate custom panes to ensure
	-- they at least meet ze bare minimums -crashcringle
	assert(type(pane.Name)=="string" and not names[pane.Name], "Evaluation panes need unique names.")
	assert(type(pane.Load)=="function", "Evaluation panes need a Load function.")
	names[pane.Name] = true
end

local players = GAMESTATE:GetHumanPlayers()
local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
local af = Def.ActorFrame{
	InitCommand=function(self)
		self.pane_names = {}
		for pane in ivalues(pane_definitions) do
			self.pane_names[#self.pane_names+1] = pane.Name
		end
	end
}
af.Name="Panes"

local offset = {
	[PLAYER_1] = _screen.cx-155,
	[PLAYER_2] = _screen.cx+155
}

-- -----------------------------------------------------------------------
-- Note: Some of these Pane actors may be nil. This is not a bug, but
--       a feature for any panes we want to be conditional.  -teejusb

if #players == 2 or SL.Global.GameMode=="Casual" and not (style == "TwoPlayersSharedSides") then
	for player in ivalues(players) do
		-- add Panes for this player in the configured order
		for definition in ivalues(pane_definitions) do
			local pn   = ToEnumShortString(player)
			local pane = definition.Load({player, player})

			if pane then
				pane.Name = ""
				af[#af+1] = Def.ActorFrame{
					Name=definition.Name.."_Side"..pn,
					InitCommand=function(self) self:x(offset[player]) end,
					pane
				}
			end
		end
	end

elseif #players == 1 or style == "TwoPlayersSharedSides" then
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

	for definition in ivalues(pane_definitions) do
		
		local left_pane  = definition.Load({mpn, PLAYER_1, ComputedData})
		local right_pane = definition.Load({mpn, PLAYER_2, ComputedData})

		-- These need to be wrapped in an extra AF to offset left and right.
		-- Panes can be nil, however, so don't add extra AFs with nil children
		if left_pane and right_pane then
			left_pane.Name = ""
			right_pane.Name = ""
			af[#af+1] = Def.ActorFrame{
				Name=definition.Name.."_SideP1",
				InitCommand=function(self) self:x(offset.PlayerNumber_P1) end,
				left_pane
			}
			af[#af+1] = Def.ActorFrame{
				Name=definition.Name.."_SideP2",
				InitCommand=function(self) self:x(offset.PlayerNumber_P2) end,
				right_pane
			}
		end
	end
end

return af
