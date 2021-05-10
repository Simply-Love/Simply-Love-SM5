-- the logo for kb7 is dynamically generated out of a png image
-- with icons from SL's current VisualStyle overlaid
local af = Def.ActorFrame{}

af.InitCommand=function(self)
	-- get a reference to the SIMPLY [something] graphic
	-- it's rasterized text in the Wendy font like "SIMPLY LOVE" or "SIMPLY THONK" or etc.
	local simply = self:GetParent():GetChild("Simply Text")
	local logo   = self:GetChild("Logo"):GetTexture()

	-- ActorFrames don't really have pixel widths; they are abstract containers with a "width" of 1.
	-- zoomtowidth(280) applied to a sprite would scale the sprite to appear with a width of 280px
	-- zoomtowidth(280) applied to an ActorFrame would scale the ActorFrame (and its contents!) to be 280 times as wide
	--
	-- zoom the entire logo AF's width to match the width of the text graphic
	-- we need to divide by the width of the logo graphic to get a scaling factor appropriate for the AF's width of 1
	self:zoomtowidth( simply:GetZoomedWidth() / logo:GetImageWidth() )

	-- now that an appropriate horizontal zoom been applied
	-- apply it to the y-axis as well to maintain proportions
	self:zoomy( self:GetZoomX() )
end


af[#af+1] = LoadActor("./kb7.png")..{ Name="Logo" }

-- -----------------------------------------------------------------------

local style = ThemePrefs.Get("VisualStyle")
local stylepath = THEME:GetPathG("", "_VisualStyles/" .. style .. "/SelectColor.png")

-- the kb7 asset features 7 icons of unequal width and spacing
-- normal width icon is 162px
local icon_width = 162
-- normal gap between icons is 16px
local gap = 16

-- width of middle icon is 256px; divide in half for easy symmetry around the middle
-- width of gap flanking the middle icon on either side is 28px
local middle_width = (256 / 2) + 28

-- zoom
local z = 0.09

-- overlay the SelectColor icon from the current VisualStyle 7 times
af[#af+1] = LoadActor(stylepath)..{ InitCommand=function(self) self:zoom(z):diffuse(color(SL.Colors[12])):x(-(2*gap + 2.5*icon_width + middle_width)) end }
af[#af+1] = LoadActor(stylepath)..{ InitCommand=function(self) self:zoom(z):diffuse(color(SL.Colors[ 2])):x(-(1*gap + 1.5*icon_width + middle_width)) end }
af[#af+1] = LoadActor(stylepath)..{ InitCommand=function(self) self:zoom(z):diffuse(color(SL.Colors[ 4])):x(-(        0.5*icon_width + middle_width)) end }
af[#af+1] = LoadActor(stylepath)..{ InitCommand=function(self) self:zoom(z):diffuse(color(SL.Colors[ 6])) end }
af[#af+1] = LoadActor(stylepath)..{ InitCommand=function(self) self:zoom(z):diffuse(color(SL.Colors[ 7])):x(          0.5*icon_width + middle_width)  end }
af[#af+1] = LoadActor(stylepath)..{ InitCommand=function(self) self:zoom(z):diffuse(color(SL.Colors[ 9])):x(  1*gap + 1.5*icon_width + middle_width)  end }
af[#af+1] = LoadActor(stylepath)..{ InitCommand=function(self) self:zoom(z):diffuse(color(SL.Colors[11])):x(  2*gap + 2.5*icon_width + middle_width)  end }

-- -----------------------------------------------------------------------

return af