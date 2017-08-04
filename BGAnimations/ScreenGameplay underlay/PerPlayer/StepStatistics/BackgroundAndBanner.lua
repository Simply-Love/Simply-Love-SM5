local player = ...

local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:diffuse(Color.Black):diffusealpha(0.95)
			:zoomto(_screen.w/2,_screen.h)
	end
}

af[#af+1] = Def.Banner{
	InitCommand=function(self)
		self:LoadFromSong( GAMESTATE:GetCurrentSong() )
			:setsize(418,164)
			:zoom(0.4)
			:xy(-70, -200)
	end
}

return af