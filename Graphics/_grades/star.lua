local pss = ...
local t = Def.ActorFrame{}

-- flag (all fantastics except 1 ex): stars
t[#t+1] = LoadActor("./assets/star.png")..{
	OnCommand=function(self)
	end,
}

return t
