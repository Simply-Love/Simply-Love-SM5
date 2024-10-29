local index = Var("GameCommand"):GetIndex()
local has_focus = false

local t = Def.ActorFrame{}

-- this renders the text of a single choice in the scroller
t[#t+1] = LoadFont("Common Bold")..{
	Name="Choice"..index,
	Text=THEME:GetString( 'ScreenTitleMenu', Var("GameCommand"):GetText() ),

	InitCommand=function(self) self:shadowlength(0.5) end,
	OnCommand=function(self) self:diffusealpha(0):sleep(index*0.075):linear(0.2):diffusealpha(1) end,
	OffCommand=function(self)
		-- if the first TitleMenu choice (Gameplay) was chosen by the player
		-- broadcast using MESSAGEMAN
		if index==0 and has_focus then
			-- actors can hook into this like
			-- TitleMenuToGameplayMessageCommand=function(self) end
			MESSAGEMAN:Broadcast("TitleMenuToGameplay")
		end

		self:sleep(index*0.075):linear(0.18):diffusealpha(0)
	end,
	VisualStyleSelectedMessageCommand=function(self)
		self:playcommand("UpdateColor")
	end,
	UpdateColorCommand=function(self)
		if has_focus then
			local textColor = PlayerColor(PLAYER_2)
			if ThemePrefs.Get("VisualStyle") == "SRPG8" then
				textColor = GetCurrentColor(true)
			end
			self:diffuse(textColor)
		else
			local textColor = color("#888888")
			if ThemePrefs.Get("RainbowMode") then
				textColor = Color.White
			end
			if ThemePrefs.Get("VisualStyle") == "SRPG8" then
				textColor = color(SL.SRPG8.TextColor)
			end
			self:diffuse(textColor)
		end
	end,

	GainFocusCommand=function(self)
		has_focus = true
		self:stoptweening():zoom(0.5)
		self:accelerate(0.1):glow(1,1,1,0.5)
		self:decelerate(0.05):glow(1,1,1,0)
		self:playcommand("UpdateColor")
	end,
	LoseFocusCommand=function(self)
		has_focus = false
		self:stoptweening():zoom(0.4)
		self:accelerate(0.1):glow(1,1,1,0)
		self:playcommand("UpdateColor")
	end
}

return t
