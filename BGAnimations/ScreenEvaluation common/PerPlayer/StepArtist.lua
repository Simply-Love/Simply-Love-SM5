local player = ...
local text_table = GetStepsCredit(player)
local marquee_index = 0

return LoadFont("Common Normal")..{
	InitCommand=function(self) self:zoom(0.7):xy(115,_screen.cy-80) end,
	OnCommand=function(self)
		-- darken the text for RainbowMode to make it more legible
		if ThemePrefs.Get("RainbowMode") then self:diffuse(Color.Black) end

		if player == PLAYER_1 then
			self:x( self:GetX() * -1 )
			self:horizalign(left)
		else
			self:horizalign(right)
		end

		if #text_table > 0 then self:playcommand("Marquee") end
	end,
	MarqueeCommand=function(self)
		-- increment the marquee_index, and keep it in bounds
		marquee_index = (marquee_index % #text_table) + 1
		-- retrieve the text we want to display
		local text = text_table[marquee_index]

		-- set this BitmapText actor to display that text
		self:settext( text )
		DiffuseEmojis(self, text)

		-- sleep 2 seconds before queueing the next Marquee command to do this again
		if #text_table > 1 then
			self:sleep(2):queuecommand("Marquee")
		end
	end,
	OffCommand=function(self) self:stoptweening() end
}