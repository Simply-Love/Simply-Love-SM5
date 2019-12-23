local args = ...

local t = Def.ActorFrame{}

for player in ivalues({PLAYER_1, PLAYER_2}) do
	-- bouncing cursor inside the grid of difficulty blocks
	t[#t+1] = LoadActor("./Cursor.lua", player)
	t[#t+1] = LoadActor("./SongSelect.lua", {player=player, args=args}) 
end

return t