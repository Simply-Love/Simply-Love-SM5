local t = Def.ActorFrame{}

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
	t[#t+1] = LoadActor("./SubtractiveScoring.lua", player)
end

return t