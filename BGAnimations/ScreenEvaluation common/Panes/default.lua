local NumPanes = ...
local players = GAMESTATE:GetHumanPlayers()

local af = Def.ActorFrame{}
af.Name="Panes"

local offset = {
	[PLAYER_1] = _screen.cx-155,
	[PLAYER_2] = _screen.cx+155
}

-- add available Panes to the ActorFrame via a loop
-- Note(teejusb): Some of these actors may be nil. This is not a bug, but
-- a feature for any panes we want to be conditional.

if #players == 2 or SL.Global.GameMode=="Casual" then
	for player in ivalues(players) do
		for i=1, NumPanes do
			local pn = ToEnumShortString(player)
			local player_pane = LoadActor("./Pane"..i, {player, player})

			if player_pane then
				af[#af+1] = Def.ActorFrame{
					Name="Pane"..i.."_".."Side"..pn,
					InitCommand=function(self) self:x(offset[player]) end,
					player_pane
				}
			end
		end
	end

elseif #players == 1 then
	local mpn = GAMESTATE:GetMasterPlayerNumber()

	for i=1, NumPanes do
		-- left
		local left_pane  = LoadActor("./Pane"..i, {mpn, PLAYER_1})
		local right_pane = LoadActor("./Pane"..i, {mpn, PLAYER_2})

		-- these need to be wrapped in an extra AF to offset left and right
		-- panes can be nil, however, so don't add extra AFs with nil children
		if left_pane and right_pane then
			af[#af+1] = Def.ActorFrame{
				Name="Pane"..i.."_".."SideP1",
				InitCommand=function(self) self:x(offset.PlayerNumber_P1) end,
				left_pane
			}
			af[#af+1] = Def.ActorFrame{
				Name="Pane"..i.."_".."SideP2",
				InitCommand=function(self) self:x(offset.PlayerNumber_P2) end,
				right_pane
			}
		end
	end
end

return af