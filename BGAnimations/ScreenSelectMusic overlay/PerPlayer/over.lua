local t = Def.ActorFrame{}

-- always add StepArtist and PaneDisplay actors for both players, even if only one is joined right now
-- if the other player suddenly latejoins, we can't dynamically add more actors to the screen
-- we can only unhide hidden actors that were there all along
for player in ivalues( PlayerNumber ) do
	-- bouncing cursor inside the grid of difficulty blocks
	t[#t+1] = LoadActor("./Cursor.lua", player)
end

return t