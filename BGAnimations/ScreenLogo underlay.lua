local t = Def.ActorFrame{}
local game = GAMESTATE:GetCurrentGame():GetName()
if game == "popn" or game == "beat" or game == "kb7" or game == "para" then
	game = "techno"
end

t[#t+1] = LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
	InitCommand=cmd(x, _screen.cx; y, _screen.cy; diffusealpha, 0),
	OnCommand=cmd(linear,0.5; diffusealpha, 1)
}

t[#t+1] = LoadActor(THEME:GetPathB("ScreenTitleMenu","underlay/SimplyLove.png"))..{
	InitCommand=cmd(x, _screen.cx; y, _screen.cy; diffusealpha, 0; zoom, 0.333),
	OnCommand=cmd(linear,0.5; diffusealpha, 1)
}

t[#t+1] = LoadFont("_wendy small")..{
	Text=THEME:GetString("ScreenLogo", "EnterCreditsToPlay"),
	InitCommand=cmd(xy,_screen.cx,SCREEN_BOTTOM-100; visible,false; zoom,0.525),
	OnCommand=function(self)
		if GAMESTATE:GetCoinMode() == "CoinMode_Pay" then
			self:visible(true)
			self:diffuseshift()
			self:effectperiod(1)
			self:effectcolor1(1,1,1,0)
			self:effectcolor2(1,1,1,1)
		end
	end,
	OffCommand=cmd(visible,false)
}

return t