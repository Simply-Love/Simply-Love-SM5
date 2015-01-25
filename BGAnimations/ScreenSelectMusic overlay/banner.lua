local t = Def.ActorFrame{
	OnCommand=function(self)
		if IsUsingWideScreen() then
			self:zoom(0.7655)
			self:xy(_screen.cx - 173, 112)
		else
			self:zoom(0.74)
			self:xy(_screen.cx - 163, 112)
		end
	end,

	LoadActor("colored_banners/banner"..SimplyLoveColor()..".png")..{
		Name="FallbackBanner",
		OnCommand=cmd(rotationy,180; setsize,418,164; diffuseshift; effectoffset,3; effectperiod, 6; effectcolor1, 1,1,1,0; effectcolor2, 1,1,1,1),
		HideCommand=cmd(visible,false),
		ShowCommand=cmd(visible,true)
	},

	LoadActor("colored_banners/banner"..SimplyLoveColor()..".png")..{
		Name="FallbackBanner",
		OnCommand=cmd(diffuseshift; effectperiod, 6; effectcolor1, 1,1,1,0; effectcolor2, 1,1,1,1; setsize, 418,164),
		HideCommand=cmd(visible,false),
		ShowCommand=cmd(visible,true)
	},

	Def.ActorProxy{
		Name="BannerProxy",
		BeginCommand=function(self)
			local banner = SCREENMAN:GetTopScreen():GetChild('Banner')
			self:SetTarget(banner)
		end
	}
}

return t