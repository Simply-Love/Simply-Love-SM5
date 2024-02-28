local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local options = GAMESTATE:GetPlayerState(player):GetPlayerOptionsArray("ModsLevel_Preferred")

if SL.Global.GameMode == "Casual" or GAMESTATE:IsCourseMode() then return end

-- start with an empty string...
local optionslist = ""

-- if the player used an XMod of 1x, it won't be in PlayerOptions list
-- so check here, and add it in manually if necessary
if SL[pn].ActiveModifiers.SpeedModType == "X" and SL[pn].ActiveModifiers.SpeedMod == 1 then
	optionslist = "1x, "
end

--  ...and append options to that string as needed
for i,option in ipairs(options) do

	-- these don't need to show up in the mods list
	if option ~= "FailAtEnd" and option ~= "FailImmediateContinue" and option ~= "FailImmediate" then
		-- 100% Mini will be in the options as just "Mini" so use the value from the SL table instead
		if option:match("Mini") then
			option = SL[pn].ActiveModifiers.Mini .. " Mini"
		end

		if option:match("Cover") then
			option = THEME:GetString("OptionNames", "Cover")
		end

		if i < #options then
			optionslist = optionslist..option..", "
		else
			optionslist = optionslist..option
		end
	end
end

-- Display TimingWindowScale as a modifier if it's set to anything other than 1
local TimingWindowScale = PREFSMAN:GetPreference("TimingWindowScale")
if TimingWindowScale ~= 1 then
	optionslist = optionslist .. ", " .. (ScreenString("TimingWindowScale")):format(TimingWindowScale*100)
end

local af = Def.ActorFrame{
  InitCommand = function(self)
      self:xy(GetNotefieldX(player), SCREEN_HEIGHT/4*1.3)
  end,
  OnCommand=function(self)
    self:sleep(5):decelerate(0.5):diffusealpha(0)
  end
}

af[#af+1] = LoadFont("Common Normal")..{
  Text=optionslist,
  InitCommand=function(self)
    self:y(15)
    self:zoom(0.8)
    self:wrapwidthpixels(125)
    self:shadowcolor(Color.Black)
    self:shadowlength(1)
  end,
}

return af