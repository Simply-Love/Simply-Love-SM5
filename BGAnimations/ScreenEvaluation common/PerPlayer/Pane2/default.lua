local player = ...
local game = GAMESTATE:GetCurrentGame():GetName()

if game == "dance" or game == "pump" or game == "techno" then
	return Def.ActorFrame{
		Name="Pane2",
		InitCommand=function(self)
			local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
			if style == "OnePlayerTwoSides" then
				self:x(-_screen.w/8 )
			end

			self:visible(false)
		end,
		HidePaneCommand=function(self) self:visible(false) end,
		ShowPaneCommand=function(self) self:visible(true) end,

		LoadActor("./Percentage.lua", player),
		LoadActor("./JudgmentLabels.lua", player),
		LoadActor("./Arrows.lua", player)
	}
end