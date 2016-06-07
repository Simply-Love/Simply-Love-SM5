if SL.Global.GameMode == "Casual" then
	return LoadActor(THEME:GetPathB("","_shared background normal"))
else
	return Def.ActorFrame{

		Def.Quad{
			InitCommand=function(self)
				if ThemePrefs.Get("RainbowMode") then
					self:Center():FullScreen():diffuse(Color.White)
				else
					self:visible(false)
				end
			end
		},

		LoadActor(THEME:GetPathB("","_shared background normal")),

		Def.ActorFrameTexture{
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
	}
end