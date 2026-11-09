local style = GetVisualStyle()
local background = style.background
local rainbowMode = VisualStyleSupportsRainbow() and ThemePrefs.Get("RainbowMode")
local af = Def.ActorFrame{ Name="CurrentBackground" }

af[#af+1] = Def.Quad{
	InitCommand=function(self)
		local backdrop = VisualStyleUsesDarkText() and Color.White or Color.Black
		if background.color and not HolidayCheer() and not rainbowMode then
			backdrop = color(background.color)
		end
		self:FullScreen():Center():diffuse(backdrop)
	end,
}

if HolidayCheer() then
	af[#af+1] = LoadActor("./Snow.lua")
elseif background.type == "image" then
	af[#af+1] = LoadActor("./Image.lua", background, style.root)
elseif background.type == "actor" then
	af[#af+1] = LoadActor(style.root .. background.file)
else
	local file = background.file and (style.root .. background.file) or VisualStyleAsset("SharedBackground.png")
	af[#af+1] = LoadActor(rainbowMode and "./RainbowMode.lua" or "./Normal.lua", file)
end

return af
