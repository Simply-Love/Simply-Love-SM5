local t = Def.ActorFrame{
	OnCommand=function(self)	
		if IsUsingWideScreen() then
			self:zoom(0.775)
			self:xy(_screen.cx - 173, 112)
		else
			self:zoom(0.74)
			self:xy(_screen.cx - 163, 112)
		end
	end,

	LoadActor("colored_banners/banner"..SimplyLoveColor()..".png")..{
		Name="FallbackBanner",
		OnCommand=function(self)
			self:rotationy(180)
			self:setsize(418,164)
		end,
		HideCommand=cmd(visible,false),
		ShowCommand=cmd(visible,true)
	},
	
	LoadActor("colored_banners/banner"..SimplyLoveColor()..".png")..{
		Name="FallbackBanner",
		OnCommand=function(self)
			self:diffuseshift()
			self:effectperiod(6)
			self:effectcolor1(1,1,1,0)
			self:effectcolor2(1,1,1,1)
			self:setsize(418,164)
		end,
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