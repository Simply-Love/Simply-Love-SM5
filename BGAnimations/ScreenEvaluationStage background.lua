local bg = LoadActor(THEME:GetPathB("","_shared background normal"))

if SL.Global.GameMode ~= "Casual" then
	bg[#bg+1] = Def.ActorFrameTexture{
		Name="Screenshot_AFT",
		InitCommand=function(self)
			self:SetHeight( PREFSMAN:GetPreference("DisplayHeight") )
				:SetWidth( PREFSMAN:GetPreference("DisplayHeight") * PREFSMAN:GetPreference("DisplayAspectRatio")  )
				:Create()
				:visible(false)
		end,
		RenderCommand=function(self)
			self:visible(true):Draw():visible(false)
			SL.Global.ScreenshotTexture = self:GetTexture()
			SCREENMAN:GetTopScreen():GetChild("Overlay"):queuecommand("AnimateScreenshot")
		end,

		Def.ActorProxy{
			Name="Overlay_Screenshot",
			OnCommand=function(self)
				self:SetTarget( SCREENMAN:GetTopScreen() )
			end,
			ScreenshotCurrentScreenMessageCommand=function(self)
				self:GetParent():queuecommand("Render")
			end
		}
	}
end

return bg