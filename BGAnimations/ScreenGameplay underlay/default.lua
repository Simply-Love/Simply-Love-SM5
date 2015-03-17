local Players = GAMESTATE:GetHumanPlayers()

-- FailType is not directly a Preference, not a GamePref, not ThemePref, etc.
-- FailType is stored as one of the DefaultModifiers in Prefernces.ini
--
-- It's also worth noting that if fail is set to "Immediate"
-- no corresponding value will appear in DefaultModifiers and the engine assumes FailType_Immediate
--
-- We'll need to attempt to parse it out from the other default modifiers.
local DefaultMods = PREFSMAN:GetPreference("DefaultModifiers")
local FailString

for modifier in string.gmatch(DefaultMods, "%w+") do
	if modifier:find("Fail") then
		FailString = modifier
	end
end

local t = Def.ActorFrame{}

-- Don't bother loading Danger if FailOff is set as a DefaultModifier
if not (FailString and FailString == "FailOff") then
	
	-- Load Danger for any available players
	for pn in ivalues(Players) do
		t[#t+1] = LoadActor("Danger.lua", pn)
	end
end

-- semi-transparent quad at the top of ScreenGameplay
t[#t+1] = Def.Quad{
	InitCommand=cmd(diffuse,color("0,0,0,0.85"); zoomto, _screen.w, _screen.h/5;),
	OnCommand=cmd(xy, _screen.w/2, _screen.h/12 - 10 )
}

-- Screen Filter
for pn in ivalues(Players) do
	t[#t+1] = LoadActor("Filter.lua", pn)
end

return t