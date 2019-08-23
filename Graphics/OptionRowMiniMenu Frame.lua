-- this is the background of a row that is used heavily throughout
-- Edit Mode's many MiniMenus, for example...
--
-- Enter for ScreenMiniMenuAreaMenu
--   ESC for ScreenMiniMenuMainMenu
--    F1 for ScreenMiniMenuEditHelp
--    F4 for ScreenMiniMenuTimingDataInformation
--     B for ScreenMiniMenuBackgroundChange
--     A for ScreenMiniMenuAlterMenu
--
-- these are ALL MiniMenus that use this Quad as the background for their rows

return Def.Quad {
	Name="RowBackgroundQuad",
	InitCommand=function(self)
		self:x(_screen.cx - WideScale(30,40))
		self:setsize(WideScale(543,720), 30)
	end
}