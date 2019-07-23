local image = ThemePrefs.Get("VisualTheme")
local game = GAMESTATE:GetCurrentGame():GetName()
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy-16):zoom( game=="pump" and 0.2 or 0.205 ):cropright(1)
	end,
	OnCommand=function(self) self:linear(0.33):cropright(0) end
}

t[#t+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/".. image .."/TitleMenu (doubleres).png"))..{
	InitCommand=function(self)
		self:xy(_screen.cx+2, _screen.cy):diffusealpha(0):zoom(0.7)
			:shadowlength(1)
	end,
	OnCommand=function(self) self:linear(0.5):diffusealpha(1) end
}

return t