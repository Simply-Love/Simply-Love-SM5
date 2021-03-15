local t = Def.ActorFrame{}

-- always add DensityGraph, StepArtist, and Cursor actors for both players, even if only one is joined right now
-- if the other player suddenly latejoins, we can't dynamically add more actors to the screen
-- we can only unhide hidden actors that were there all along
for player in ivalues( PlayerNumber ) do
	-- Currently the Density Graph doesn't work for Courses.
	-- Disable the functionality.
	if not GAMESTATE:IsCourseMode() then
		t[#t+1] = LoadActor("./DensityGraph.lua", player)
	end
	-- AuthorCredit, Description, and ChartName associated with the current stepchart
	t[#t+1] = LoadActor("./StepArtist.lua", player)
end

for player in ivalues( PlayerNumber ) do
	-- bouncing cursor inside the grid of difficulty blocks. These should be on top of both of the density graphs.
	t[#t+1] = LoadActor("./Cursor.lua", player)
end

return t