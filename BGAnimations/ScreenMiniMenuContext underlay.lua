-- this is only used for the Screen that manages local profiles so far

local num_rows
local row_height = 28

return Def.ActorFrame {
	InitCommand=cmd(xy,_screen.cx-WideScale(146, 143), -16; queuecommand, "Capture"),
	CaptureCommand=function(self)
		-- how many rows do we need to accommodate?
		num_rows = #SCREENMAN:GetTopScreen():GetChild("Container"):GetChild("")
		-- If there are more than 10 rows, they collapse via scroller anyway
		-- so don't accommodate the decorative border for more than 10
		num_rows = math.min(10, num_rows)
		self:queuecommand("Size")
	end,

	-- decorative border
	Def.Quad{
		SizeCommand=cmd(zoomto, 240, row_height*num_rows)
	},

	LoadFont("_miso")..{
		InitCommand=cmd(xy,-99, -118; halign,0; diffuse, Color.Black ),
		BeginCommand=function(self)
			local profile = GAMESTATE:GetEditLocalProfile()
			if profile then
				self:settext(profile:GetDisplayName())
			end
		end
	}
}