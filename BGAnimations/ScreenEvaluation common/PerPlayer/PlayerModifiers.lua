local pn = ...

local PlayerState = GAMESTATE:GetPlayerState(pn)
-- grab the song options from this PlayerState.
local PlayerOptions = PlayerState:GetPlayerOptionsArray(0)
-- start with an empty string...
local optionslist= ""

local TimingWindowScale = round(PREFSMAN:GetPreference("TimingWindowScale") * 100)

--  ...and append options to that string as needed
for k,option in ipairs(PlayerOptions) do

	-- these don't need to show up in the mods list
	if option ~= "FailAtEnd" and option ~= "FailImmediateContinue" and option ~= "FailImmediate" then
		if k < #PlayerOptions then
			optionslist = optionslist..option..", "
		else
			optionslist = optionslist..option
		end
	end
end

-- Display TimingWindowScale as a modifier if it's set to anything other than 1.0
if TimingWindowScale ~= 100 then
	optionslist = optionslist .. ", " .. tostring(TimingWindowScale) .. "% Timing Window"
end

return Def.ActorFrame{
	OnCommand=cmd(y, _screen.cy+200.5),

	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282F"); zoomto, 300, 26)
	},

	LoadFont("_miso")..{
		Text=optionslist,
		InitCommand=cmd(zoom,0.7; xy,-140,-5; horizalign,left; vertalign,top; vertspacing, -6; wrapwidthpixels, 290 / 0.7 )
	}
}