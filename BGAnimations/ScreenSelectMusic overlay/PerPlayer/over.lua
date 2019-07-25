local t = Def.ActorFrame{}

for player in ivalues({PLAYER_1, PLAYER_2}) do
	-- bouncing cursor inside the grid of difficulty blocks
	t[#t+1] = LoadActor("./Cursor.lua", player)
end

return t