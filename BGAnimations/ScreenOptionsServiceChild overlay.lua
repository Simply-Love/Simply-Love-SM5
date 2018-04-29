local af = Def.ActorFrame{}
local bg_width = _screen.w*0.425
local bg_height = _screen.h-130
local padding = 10
local recommended_bmt

af.OnCommand=function(self)
	local ScreenName = SCREENMAN:GetTopScreen():GetName()
	if ScreenName == "ScreenMapControllers"
	or ScreenName == "ScreenTestInput" then
		self:visible(false)
		return
	end

	self:xy(_screen.w*WideScale(0.765,0.75), _screen.cy - 15)
end

af.OptionRowChangedMessageCommand=function(self, params)
	local OptionRowName = params.Title:GetParent():GetParent():GetName()
	self:playcommand("Update", {Name=OptionRowName} )
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
	UpdateCommand=function(self, params)
		self:settext( THEME:GetString("OptionExplanations", params.Name) )
	end
}

af[#af+1] = Def.ActorFrame{
	Name="Recommended",
	UpdateCommand=function(self, params)
		self:visible( THEME:HasString("RecommendedOptionExplanations", params.Name) )
	end,

	Def.BitmapText{
		Font="_miso",
		InitCommand=function(self)
			recommended_bmt = self

			self:xy(- bg_width/2 + padding, bg_height/2 - padding)
				:valign(1) -- bottom aligned
				:halign(0) -- left aligned
				:wrapwidthpixels(_screen.w*0.4)
		end,
		UpdateCommand=function(self, params)
			if THEME:HasString("RecommendedOptionExplanations", params.Name) then
				self:settext( THEME:GetString("RecommendedOptionExplanations", "Recommended") .. ": " .. THEME:GetString("RecommendedOptionExplanations", params.Name) )
			else
				self:settext("")
			end
		end,
	},

	Def.Quad{
		InitCommand=function(self) self:zoomto(bg_width-10, 1):y(-padding) end,
		UpdateCommand=function(self, params)
			self:y( bg_height/2 - padding*2 - recommended_bmt:GetHeight() )
		end
	},
}

return af