local t = Def.ActorFrame{}

-- Always add these elements for both players, even if only one is joined right now
-- If the other player suddenly latejoins, we can't dynamically add more actors to the screen
-- We can only unhide hidden actors that were there all along
for player in ivalues( PlayerNumber ) do
	-- Density Graph is only loaded when DisplayStyle is set to ITG+
	if ThemePrefs.Get("SelectMusicDisplayStyle") == "ITG+" and GAMESTATE:GetCurrentGame():GetName() == "dance" and not GAMESTATE:IsCourseMode() then
		t[#t+1] = LoadActor("./DensityGraph.lua", player)
		-- AuthorCredit, Description, and ChartName associated with the current stepchart
		t[#t+1] = LoadActor("./StepArtist.lua", player)
	else
		-- AuthorCredit, Description, and ChartName associated with the current stepchart
		t[#t+1] = LoadActor("./StepArtist-Classic.lua", player)

	end
end

-- Bouncing cursor inside the grid of difficulty blocks. These should be on top of both of the other elements.
for player in ivalues( PlayerNumber ) do
	-- The cursor appears differently depending on the DisplayStyle
	if ThemePrefs.Get("SelectMusicDisplayStyle") == "ITG+" and GAMESTATE:GetCurrentGame():GetName() == "dance" then
		t[#t+1] = LoadActor("./Cursor.lua", player)
	else
		t[#t+1] = LoadActor("./Cursor-Classic.lua", player)
	end
end

return t