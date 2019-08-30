local bg = LoadActor(THEME:GetPathB("","_shared background"))


-- don't bother adding support for animated faux screenshot textures to ScreenEval
-- in Casual mode because Casual mode doesn't allow screenshots at all.
if SL.Global.GameMode ~= "Casual"
-- SupportsRenderToTexture() is defined in ./Scripts/SL-Helpers.lua; read more details there.
and SupportsRenderToTexture()
then

	-- ActorFrameTextures are neat because they can take their dynamic contents
	-- (like Sprites, BitmapTexts, NoteSkins, etc., anything really) and create a
	-- visual "snapshot" of those contents as they exist at a particular moment in time.
	--
	-- It's kind of like a photograph of real life, or a screenshot of a game.
	-- In computer graphics programming, a photograph/snapshot like this is a "texture".
	--
	-- In SM5, we can put various actors (like Sprites, BitmapTexts, NoteSkins, etc.) into
	-- an ActorFrameTexture like we would an ActorFrame, and we can use its special methods like
	-- Draw() to create a texture at a point in time, and GetTexture() to pass the resulting
	-- texture off to a Sprite.

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

		-- There's only one actor inside this ActorFrameTexture – it's an ActorProxy of the entire screen.
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