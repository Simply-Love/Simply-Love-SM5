-- tables of rgba values
local dark  = {0,0,0,0.9}
local light = {0.65,0.65,0.65,1}

return Def.ActorFrame{
	Name="Header",

	Def.Quad{
		InitCommand=function(self)
			self:zoomto(_screen.w, 32):vertalign(top):x(_screen.cx)
			if ThemePrefs.Get("VisualStyle") == "SRPG6" then
				self:diffuse(GetCurrentColor(true))
			elseif DarkUI() then
				self:diffuse(dark)
			elseif ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0)
			else
				self:diffuse(light)
			end
		end,
		ScreenChangedMessageCommand=function(self)
			local topscreen = SCREENMAN:GetTopScreen():GetName()
			if SL.Global.GameMode == "Casual" and (topscreen == "ScreenEvaluationStage" or topscreen == "ScreenEvaluationSummary") then
				self:diffuse(dark)
			end
			if ThemePrefs.Get("VisualStyle") == "SRPG6" then
				self:diffuse(GetCurrentColor(true))
			end
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				if topscreen == "ScreenSelectMusic" and not ThemePrefs.Get("RainbowMode") then
					self:diffuse(0, 0, 0, 0.5)
				else
					self:diffusealpha(0)
				end
			end
			self:visible(topscreen ~= "ScreenCRTTestPatterns")
		end,
		ColorSelectedMessageCommand=function(self)
			if ThemePrefs.Get("VisualStyle") == "SRPG6" then
				self:diffuse(GetCurrentColor(true))
			end
		end,
		VisualStyleSelectedMessageCommand=function(self)
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0)
			end
		end,
	},

	LoadFont("Common Header")..{
		Name="HeaderText",
		Text=ScreenString("HeaderText"),
		InitCommand=function(self) self:diffusealpha(0):horizalign(left):xy(10, 15):zoom( SL_WideScale(0.5,0.6) ) end,
		OnCommand=function(self) self:sleep(0.1):decelerate(0.33):diffusealpha(1) end,
		OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end
	}
}
