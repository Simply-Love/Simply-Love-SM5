-- the best way to spread holiday cheer is singing loud for all to hear
if HolidayCheer() then
	return LoadActor( THEME:GetPathB("", "_shared background/Snow.lua") )
end

local af = Def.ActorFrame{
	-- a simple Quad to serve as the backdrop
	Def.Quad{
		InitCommand=function(self)
			self:FullScreen():Center():diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
		end,
		VisualStyleSelectedMessageCommand=function(self)
			self:linear(1):diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
		end,
	},

	-- container for the style-specific elements
	Def.ActorFrame{
		InitCommand=function(self)
			self.ApplyVisualStyle= function(self)
				local style = ThemePrefs.Get("VisualStyle")
				if ThemePrefs.Get("RainbowMode") and style ~= "SRPG9" then
					self:AddChildFromPath(THEME:GetPathB("", "_shared background/RainbowMode.lua"))
				end

				if style == "SRPG9" then
					self:AddChildFromPath(THEME:GetPathB("", "_shared background/Static.lua"))
				elseif style == "Technique" then
					self:AddChildFromPath(THEME:GetPathB("", "_shared background/Technique.lua"))
				elseif not ThemePrefs.Get("RainbowMode") then
					self:AddChildFromPath(THEME:GetPathB("", "_shared background/Normal.lua"))
				end

			end
			self:ApplyVisualStyle()
		end,

		-- If the player chooses a different VisualStyle during runtime, MESSAGEMAN will broadcast
		-- "VisualStyleSelected"; see also: ./BGAnimations/ScreenOptionsService overlay.lua
		VisualStyleSelectedMessageCommand=function(self)
			THEME:ReloadMetrics() -- is this needed here?  -quietly
			SL.Global.ActiveColorIndex = ThemePrefs.Get("RainbowMode") and 3 or ThemePrefs.Get("SimplyLoveColor")
			self:RemoveAllChildren()
			self:ApplyVisualStyle()
			self:queuecommand("On")
		end,
	},
}

return af
