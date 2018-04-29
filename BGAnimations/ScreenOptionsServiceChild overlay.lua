local af = Def.ActorFrame{}
local bg_width = _screen.w*0.425
local bg_height = _screen.h-130
local padding = 10

af.OnCommand=function(self)
	local ScreenName = SCREENMAN:GetTopScreen():GetName()
	if ScreenName == "ScreenMapControllers"
	or ScreenName == "ScreenTestInput" then
		self:visible(false)
		return
	end

	self:xy(_screen.w*WideScale(0.765,0.75), _screen.cy - 15)
end

af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:zoomto(bg_width, bg_height)
			:diffuse(color("#666666"))
			:diffusealpha( BrighterOptionRows() and 0.95 or 0.75)
	end,
}

af[#af+1] = Def.BitmapText{
	Font="_miso",
	InitCommand=function(self)
		self:xy(- bg_width/2 + padding, -bg_height/2 + padding)
			:valign(0)
			:halign(0)
			:wrapwidthpixels(_screen.w*0.4)
	end,
	OptionRowChangedMessageCommand=function(self, params)
		local OptionRow = params.Title:GetParent():GetParent()
		self:settext( THEME:GetString("OptionExplanations", OptionRow:GetName()) )
	end
}

return af