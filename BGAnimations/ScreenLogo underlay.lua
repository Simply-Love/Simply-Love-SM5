return LoadActor( THEME:GetPathB("ScreenTitleMenu", "underlay/SimplySomething.lua"))..{
	InitCommand=function(self) self:Center() end
}