return Def.ActorFrame{
	LoadActor("./Current.lua"),
	VisualStyleSelectedMessageCommand=function(self)
		self:queuecommand("ReloadBackground")
	end,
	ReloadBackgroundCommand=function(self)
		THEME:ReloadMetrics()
		SL.Global.ActiveColorIndex = ThemePrefs.Get("RainbowMode") and 3 or ThemePrefs.Get("SimplyLoveColor")
		self:RemoveChild("CurrentBackground")
		self:AddChildFromPath(THEME:GetPathB("", "_shared background/Current.lua"))
		self:GetChild("CurrentBackground"):playcommand("Begin")
		self:GetChild("CurrentBackground"):playcommand("On")
	end,
}
