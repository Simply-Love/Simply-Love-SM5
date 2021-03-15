local t = Def.ActorFrame{}

-- always add the PaneDisplay actors for both player, even if only one is joined right now
-- if the other player suddenly latejoins, we can't dynamically add more actors to the screen
-- we can only unhide hidden actors that were there all along
for player in ivalues( PlayerNumber ) do
	-- number of steps, jumps, holds, etc., and high scores associated with the current stepchart
	t[#t+1] = LoadActor("./PaneDisplay.lua", player)
end

return t