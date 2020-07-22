if GAMESTATE:IsCourseMode() then
return Def.ActorFrame { }
end

local t = Def.ActorFrame{
	ChangeStepsMessageCommand=function(self, params)
		self:playcommand("StepsHaveChanged", {Direction=params.Direction, Player=params.Player})
	end,

	-- The background and static player info (like name, and profile picture)
	LoadActor("./Profile.lua"),
	-- All the text labels for the player's info
	LoadActor("./ProfileTextLabels.lua"),
	-- All the variable player profile info
	LoadActor("./ProfileStats.lua"),
}

return t