local player = ...
local text_table = GetStepsCredit(player)
local marquee_index = 0

return LoadFont("_miso")..{
	InitCommand=cmd(zoom, 0.7; xy, 115,_screen.cy-80 ),
	OnCommand=function(self)
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

		-- sleep 2 seconds before queueing the next Marquee command to do this again
		self:sleep(2):queuecommand("Marquee")
	end,
	OffCommand=function(self) self:stoptweening() end
}