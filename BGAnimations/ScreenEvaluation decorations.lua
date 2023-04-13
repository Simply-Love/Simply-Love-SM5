-- Load ScreenWithMenuElements decorations.lua, which handles
-- SL's normal header and footer, and then append an extra AF and BitmapText
-- for displaying the date and time at the center-bottom of screens that
-- inherit from ScreenEvaluation.  This includes ScreenEvaluationStage,
-- ScreenEvaluationNonstop, and ScreenEvaluationSummary.

-----------------------------------------------------------------------
-- first, load the normal decorations used for ScreenWithMenuElements
local decorations = LoadActor(THEME:GetPathB("ScreenWithMenuElements", "decorations.lua"))

-----------------------------------------------------------------------
-- next, define a BitmapText that displays the date and time, and add it to
-- a local ActorFrame so that it can be assigned a custom update function
-- that refreshes the date and time if the player stays on this screen for a while

local DateFormat = "%04d/%02d/%02d %02d:%02d"
local timestamp_bmt = nil

local Update = function(af)
	if timestamp_bmt then
		timestamp_bmt:playcommand("Refresh")
	end
end

local af = Def.ActorFrame{}
af.Name="DateTimeAF"
af.InitCommand=function(self)
	self:SetUpdateFunction(Update)
end

-- add a BitmapText to this ActorFrame
af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " numbers")..{
	Name="DateTime",
	InitCommand=function(self)
		timestamp_bmt = self

		self:x(_screen.cx):horizalign(center)
		self:zoom(0.18)
	end,
	OnCommand=function(self)
		-- y offset for ScreenEvaluationStage or ScreenEvaluationNonstop
		-- or anything else that inherits from ScreenEvaluation
		self:y(_screen.h - 17)

		-- use a slightly diffrent y offset for ScreenEvaluationSummary
		local screen = SCREENMAN:GetTopScreen()
		if screen then
			if screen:GetName() == 'ScreenEvaluationSummary' then
				self:y(_screen.h - 20)
			end
		end

		local textColor = Color.White
		if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
			textColor = Color.Black
		end

		self:diffuse(textColor)
		self:playcommand("Refresh")
	end,
	RefreshCommand=function(self)
		self:settext(DateFormat:format(Year(), MonthOfYear()+1, DayOfMonth(), Hour(), Minute()))
	end
}

-----------------------------------------------------------------------
-- finally, add the DateTimeAF to the decorations ActorFrame
decorations[#decorations+1] = af

-- return the decorations ActorFrame so that evaluation screens get
-- a header, a footer, and a datetime
return decorations
