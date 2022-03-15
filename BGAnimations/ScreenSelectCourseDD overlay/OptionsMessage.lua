return Def.ActorFrame {
	InitCommand=function(self)
		self:visible(false)
		self:draworder(108)
	end,
	ShowOptionsJawnMessageCommand=function(self)
		self:visible(true)
		self
			:diffusealpha(0)
			:linear(0.25)
			:diffusealpha(1)
			:sleep(1.75)
			:queuecommand('GoToGameplay')
	end,
	GoToGameplayCommand=function(self)
		SCREENMAN:SetNewScreen("ScreenGameplay")
	end,
	HideOptionsJawnMessageCommand=function(self)
		self:stoptweening()
		self:visible(false)
	end,
	Def.Quad {
		InitCommand=function(self)
			self:diffuse(0, 0, 0, 1)
			self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
			self:setsize(SCREEN_WIDTH, SCREEN_HEIGHT)
			self:draworder(108)
		end,
	},
	Def.BitmapText {
		Font="Wendy/_wendy small",
		Text=THEME:GetString("ScreenSelectMusicDD", "Press Start for Options"),
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
			self:zoom(0.8)
			self:draworder(108)
		end
	}
}