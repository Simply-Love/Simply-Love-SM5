local player = ...
local pn = ToEnumShortString(player)
local info

-- in CourseMode, GetStepsCredit() will return a table of info that
-- has as many entries as there are stepcharts in the course
-- (i.e. potentially a lot) so just show course Scripter or Description
if GAMESTATE:IsCourseMode() then
	local course = GAMESTATE:GetCurrentCourse()
	local scripter = course:GetScripter()
	local descript = course:GetDescription()
	-- prefer scripter, use description if scripter is empty
	info = (scripter ~= "" and scripter) or (descript ~= "" and descript) or ""

else
	info = GetStepsCredit(player)
end

local marquee_index = 0

return LoadFont("Common Normal")..{
	InitCommand=function(self) self:zoom(0.7):xy(115,_screen.cy-80) end,
	OnCommand=function(self)
		local textColor = Color.White
		local shadowLength = 1
		if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
			textColor = Color.Black
		end
		self:diffuse(textColor)
		self:shadowlength(shadowLength)

		if player == PLAYER_1 then
			self:x( self:GetX() * -1 )
			self:horizalign(left)
		else
			self:horizalign(right)
		end

		if type(info)=="table" and #info > 0 then
			self:playcommand("Marquee")
		elseif type(info)=="string" then
			self:settext(info)
		end
	end,
	MarqueeCommand=function(self)
		-- increment the marquee_index, and keep it in bounds
		marquee_index = (marquee_index % #info) + 1
		-- retrieve the text we want to display
		local text = info[marquee_index]

		-- set this BitmapText actor to display that text
		self:settext( text )
		DiffuseEmojis(self, text)

		-- sleep 2 seconds before queueing the next Marquee command to do this again
		if #info > 1 then
			self:sleep(2):queuecommand("Marquee")
		end
	end,
	OffCommand=function(self) self:stoptweening() end
}
