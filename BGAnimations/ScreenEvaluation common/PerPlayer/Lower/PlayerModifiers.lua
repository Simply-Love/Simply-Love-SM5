if SL.Global.GameMode == "Casual" then return end

local player = ...

local font_zoom = 0.7
local width = THEME:GetMetric("GraphDisplay", "BodyWidth")

local optionslist = GetPlayerOptionsString(player)

return Def.ActorFrame{
	OnCommand=function(self) self:y(_screen.cy+200.5) end,

	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#1E282F")):zoomto(width, 26)
			if #GAMESTATE:GetHumanPlayers()==1 then
				-- not quite an even 0.25 because we need to accomodate the extra 10px
				-- that would normally be between the left and right panes
				self:addx(width*0.2541)
			end
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.75)
			end
		end
	},

	LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
		Text=optionslist,
		InitCommand=function(self) self:zoom(font_zoom):xy(-140,-5):align(0,0):vertspacing(-6):_wrapwidthpixels((width-10) / font_zoom) end
	}
}