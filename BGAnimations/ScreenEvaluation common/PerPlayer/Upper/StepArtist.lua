local player = ...
local pn = ToEnumShortString(player)
local info
local w, h

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

return Def.ActorFrame{
	Def.Quad{
		Name="InfoBG",
		InitCommand=function(self)
			self:vertalign("VertAlign_Bottom")
			if player == PLAYER_1 then
				self:x( self:GetX() * -1 )
				self:horizalign(left)
			else
				self:horizalign(right)
			end
			self:zoomto(10,10)
			self:xy(-110,_screen.cy-56)

			self:diffuse( Color.Black )
			if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
				self:diffuse( Color.White )
			end
			self:diffusealpha(0.7)
		end
	},
	LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
		InitCommand=function(self) self:vertalign("VertAlign_Bottom"):zoom(0.7):xy(108,_screen.cy-42) end,
		OnCommand=function(self)
			local textColor = Color.White
			local shadowLength = 0
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

			local finalzoom = 0.7
			if type(info)=="table" and #info > 0 then
				-- self:playcommand("Marquee")
				local finalText = ""
				for i=1,#info do
					finalText = finalText .. info[i] .. "\n"
				end
				if #info > 2 then
					finalzoom=0.6
					self:vertalign("VertAlign_Bottom"):y(_screen.cy-43):zoom(finalzoom)
				end
				self:settext(finalText)
			elseif type(info)=="string" then
				self:settext(info)
			end
			
			w = self:GetWidth()
			h = self:GetHeight()
			
			while w*finalzoom > 120 and finalzoom > 0.45 do
				finalzoom = finalzoom - 0.05
				self:zoom(finalzoom):addy(-1)
				self:GetParent():GetChild("InfoBG")
			end
			self:GetParent():GetChild("InfoBG"):SetWidth(w+20):SetHeight(h-19):zoom(finalzoom)
			if player == PLAYER_1 then
				self:GetParent():GetChild("InfoBG"):faderight(0.1)
			else
				self:GetParent():GetChild("InfoBG"):fadeleft(0.1)
				self:GetParent():GetChild("InfoBG"):x( self:GetParent():GetChild("InfoBG"):GetX() * -1 )
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	}
}
