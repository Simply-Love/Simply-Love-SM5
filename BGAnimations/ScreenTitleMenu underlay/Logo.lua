-- use the current game (dance, pump, etc.) to load the apporopriate logo
local game = GAMESTATE:GetCurrentGame():GetName()
local path = ("/%s/Graphics/_logos/%s"):format( THEME:GetCurrentThemeDirectory(), game)

-- Fall back on using the dance logo asset if one isn't found for the current game.
-- We can't use FILEMAN:DoesFileExist() here because it needs an already-resolved path,
-- but "path" (above) might resolve to either a png or a directory.
--
-- So, use ActorUtil.ResolvePath() to attempt to resolve the path.
-- If it doesn't resolve to a valid StepMania path, it will return nil,
-- and we can use that mean that neither a png nor a directory was found for this game.
local resolved_path = ActorUtil.ResolvePath(path, 1, true)
if resolved_path == nil then
	game = "dance"
	resolved_path = ("/%s/Graphics/_logos/dance.png"):format( THEME:GetCurrentThemeDirectory() )
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
		if ThemePrefs.Get("VisualStyle") == "SRPG8" then
			self:Load(THEME:GetPathG("", "_VisualStyles/SRPG8/"..SL.SRPG8.GetLogo()))
			self:zoom(0.225):vertalign(top)
			self:x(-15):y(-130):shadowlength(0)
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


if ThemePrefs.Get("VisualStyle") ~= "SRPG8" then
	-- decorative arrows for current game (dance, pump, techno, etc.)
	af[#af+1] = LoadActor(resolved_path)..{
		InitCommand=function(self)
			self:y(-16)

			-- use ActorUtil to resolve the path and find out if it's a png or a directory
			-- if it's a png, scale it
			-- if it's a directory, assume the default.lua returns an AF and handles its own scaling
			if ActorUtil.GetFileType(resolved_path) == "FileType_Bitmap" then
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
			end
		end,
		VisualStyleSelectedMessageCommand=function(self)
			-- In case we auto-switch to SRPG8, then it's possible this actor may have been added to the screen.
			-- If so, we want to hide the logo as it interferes with the SRPG8 logo.
			if ThemePrefs.Get("VisualStyle") == "SRPG8" then
				self:visible(false)
			end
		end
	}
end

return af
