local GIFdir = THEME:GetCurrentThemeDirectory() .. "BGAnimations/ScreenGameplay underlay/PerPlayer/StepStatistics/GIFs/"
local GIFs = findFiles(GIFdir, "lua")
local rand = GIFs[math.random(1,#GIFs)]

while rand == "Randomizer" do
	rand = GIFs[math.random(1,#GIFs)]
end

t = Def.ActorFrame {
	LoadActor(rand)
}

return t