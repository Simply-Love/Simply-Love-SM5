local t = Def.ActorFrame{
	OnCommand=function(self)
		if IsUsingWideScreen() then
			self:zoom(0.7655)
			self:xy(_screen.cx - 170, 112)
		else
			self:zoom(0.74)
			self:xy(_screen.cx - 165, 112)
		end
	end,

	LoadActor("colored_banners/banner"..SL.Global.ActiveColorIndex.." (doubleres).png" )..{
		Name="FallbackBanner",
		OnCommand=cmd(rotationy,180; setsize,418,164; diffuseshift; effectoffset,3; effectperiod, 6; effectcolor1, 1,1,1,0; effectcolor2, 1,1,1,1)
	},

	LoadActor("colored_banners/banner"..SL.Global.ActiveColorIndex.." (doubleres).png" )..{
		Name="FallbackBanner",
		OnCommand=cmd(diffuseshift; effectperiod, 6; effectcolor1, 1,1,1,0; effectcolor2, 1,1,1,1; setsize, 418,164)
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