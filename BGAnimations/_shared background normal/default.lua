-- the best way to spread holiday cheer is singing loud for all to hear
if PREFSMAN:GetPreference("EasterEggs") and MonthOfYear()==11 then
	return LoadActor( THEME:GetPathB("", "_shared background normal/Snow.lua") )
end

local af = Def.ActorFrame{}

-- read the appropriate SharedBackground texture from disk now
-- if the player chooses a different VisualTheme, MESSAGEMAN will broadcast "BackgroundImageChanged"
-- which we can use in Normal.lua and RainbowMode.lua to read the newly-appropriate texture from disk
-- see also: ./BGAnimations/ScreenOptionsService overlay.lua
local file = THEME:GetPathG("", "_VisualStyles/" .. ThemePrefs.Get("VisualTheme") .. "/SharedBackground.png")

-- a simple Quad to serve as the backdrop
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():Center():diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black ) end,
	BackgroundImageChangedMessageCommand=function(self)
		THEME:ReloadMetrics()
		SL.Global.ActiveColorIndex = ThemePrefs.Get("RainbowMode") and 3 or ThemePrefs.Get("SimplyLoveColor")
		self:linear(1):diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
	end
}

af[#af+1] = LoadActor("./Normal.lua", file)
af[#af+1] = LoadActor("./RainbowMode.lua", file)

return af