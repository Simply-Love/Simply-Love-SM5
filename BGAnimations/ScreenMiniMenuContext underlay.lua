-- this is only used for the Screen that manages local profiles so far

local NumRows

local t = Def.ActorFrame {
	InitCommand=cmd(xy,_screen.cx-_screen.w/6,_screen.cy-84; queuecommand, "Capture"),
	CaptureCommand=function(self)
		-- how many rows do we need to accommodate?
		NumRows = #SCREENMAN:GetTopScreen():GetChild("Container"):GetChild("")
		self:queuecommand("Size")
	end,
	
	
	-- white border
	Def.Quad{
		SizeCommand=cmd(zoomto, 204, 32*NumRows)
	},

	LoadFont("_misoreg hires")..{
		InitCommand=cmd(x,-80; y,-60; halign,0; diffuse, Color.Black ),
		BeginCommand=function(self)
			local profile = GAMESTATE:GetEditLocalProfile()
			if profile then
				self:settext(profile:GetDisplayName())
			end
		end
	}
}

return t