-- use the current game (dance, pump, etc.) to load the apporopriate logo
-- SL currently has logo assets for: dance, pump, techno
--   use the techno logo asset for less common games (para, kb7, etc.)
local game = GAMESTATE:GetCurrentGame():GetName()
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

-- -----------------------------------------------------------------------
local af = Def.ActorFrame{}

-- SIMPLY [something]
af[#af+1] = Def.Sprite{
	Name="Simply Text",
	InitCommand=function(self)
		self:playcommand("LoadImage")
	end,
	OffCommand=function(self) self:linear(0.5):shadowlength(0) end,
	VisualStyleSelectedMessageCommand=function(self)
		self:playcommand("LoadImage")
	end,
	LoadImageCommand=function(self)
		if ThemePrefs.Get("VisualStyle") == "SRPG5" then
			self:Load(THEME:GetPathG("", "_VisualStyles/SRPG5/"..SL.SRPG5.GetLogo()))
			self:zoom(0.7):vertalign(top)
			self:y(-110):shadowlength(0)
		else
			local style = ThemePrefs.Get("VisualStyle")
			local image = THEME:GetPathG("", "_VisualStyles/"..style.."/TitleMenu (doubleres).png")
			local imageAlt = "/Themes/"..THEME:GetCurThemeName().."/Graphics/_VisualStyles/"..style.."/TitleMenuAlt (doubleres).png"
			if FILEMAN:DoesFileExist(imageAlt) and math.random(1,100) <= 10 then
				self:Load(imageAlt)
			else
				self:Load(image)
			end
			self:zoom(0.7):vertalign(top)
			self:y(-102):shadowlength(0.75)
		end
	end,
}

-- decorative arrows
af[#af+1] = LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
	InitCommand=function(self)
		self:y(-16)
		self:visible(ThemePrefs.Get("VisualStyle") ~= "SRPG5")

		-- get a reference to the SIMPLY [something] graphic
		-- it's rasterized text in the Wendy font like "SIMPLY LOVE" or "SIMPLY THONK" or etc.
		local simply = self:GetParent():GetChild("Simply Text")

		-- zoom the logo's width to match the width of the text graphic
		-- zoomtowidth() performs a "horizontal" zoom (on the x-axis) to meet a provided pixel quantity
		--    and leaves the y-axis zoom as-is, potentially skewing/squishing the appearance of the asset
		self:zoomtowidth( simply:GetZoomedWidth() )

		-- so, get the horizontal zoom factor of these decorative arrows
		-- and apply it to the y-axis as well to maintain proportions
		self:zoomy( self:GetZoomX() )
	end,
	VisualStyleSelectedMessageCommand=function(self)
		self:visible(ThemePrefs.Get("VisualStyle") ~= "SRPG5")
	end,
}

return af
