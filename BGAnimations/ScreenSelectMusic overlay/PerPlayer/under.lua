local t = Def.ActorFrame{}

for player in ivalues({PLAYER_1, PLAYER_2}) do
	-- AuthorCredit, Description, and ChartName associated with the current stepchart
	t[#t+1] = LoadActor("./StepArtist.lua", player)

	-- number of steps, jumps, holds, etc., and high scores associated with the current stepchart
	t[#t+1] = LoadActor("./PaneDisplay.lua", player)
end

return t