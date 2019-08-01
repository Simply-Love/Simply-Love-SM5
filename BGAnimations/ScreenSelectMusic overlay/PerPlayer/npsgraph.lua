local t = Def.ActorFrame{InitCommand=function(self) self:draworder(1) end}

for player in ivalues({PLAYER_1, PLAYER_2}) do
        -- npsgraph when up is pressed (so people with no back button can use it)
	t[#t+1] = LoadActor("./DensityGraph.lua", player)
end

return t

