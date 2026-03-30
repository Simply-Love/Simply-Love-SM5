local patterns = {
	{name=Screen.String("SMPTEColorBars"), file="smpte-color-bars.gif"},
	{name=Screen.String("Convergence"), file="convergence.gif"},
	{name=Screen.String("Gamma"), file="gamma.jpg"},
	{name=Screen.String("AspectRatio"), file="aspect-ratio.jpg"},
}

local idx = 1

local function InputHandler(event)
	if event.type == "InputEventType_FirstPress" then
		if event.GameButton == "Back" or event.GameButton == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		elseif event.GameButton == "MenuLeft" then
			idx = (idx-2) % #patterns + 1
			SCREENMAN:GetTopScreen():queuecommand("IndexChanged")
		elseif event.GameButton == "MenuRight" then
			idx = (idx % #patterns) + 1
			SCREENMAN:GetTopScreen():queuecommand("IndexChanged")
		end
	end
end

return Def.ActorFrame{
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
		self:queuecommand("IndexChanged")
	end,

	Def.Sprite {
		InitCommand=function(self)
			self:FullScreen()
		end,
		IndexChangedCommand=function(self)
			self:Load(THEME:GetPathB("ScreenCRTTestPatterns", "underlay/patterns/"..patterns[idx].file))
			self:FullScreen()
		end,
	},

	Def.ActorFrame{
		InitCommand=function(self)
			self:diffusealpha(0)
		end,
		IndexChangedCommand=function(self)
			self:finishtweening()
			self:linear(0.15):diffusealpha(1)
			self:sleep(2):linear(0.15):diffusealpha(0)
		end,

		Def.Quad{
			InitCommand=function(self)
				self:xy(_screen.cx, _screen.cy)
				self:zoomto(_screen.w, 100)
				self:diffuse(Color.Black):diffusealpha(0.8)
			end
		},

		LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
			InitCommand=function(self)
				self:diffuse(Color.White)
				self:xy(_screen.cx, _screen.cy - 15)
			end,
			IndexChangedCommand=function(self)
				self:settext(patterns[idx].name)
			end,
		},


		LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
			Text=Screen.String("Usage"),
			InitCommand=function(self)
				self:diffuse(Color.White)
				self:xy(_screen.cx, _screen.cy + 25)
			end,
		},
	},
}
