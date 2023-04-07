local text_width = 420

local _zoom = {
	active   = WideScale(1.15,1.1),
	inactive = WideScale(0.55,0.5)
}
local active_index = 0
local choice_actors = {}
local af

local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then return false end

	if event.type == "InputEventType_FirstPress" then
		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			-- old active choice loses focus
			choice_actors[active_index]:diffuse(1,1,1,1):finishtweening():linear(0.1):zoom(_zoom.inactive)
			-- update active_index
			active_index = (active_index + (event.GameButton=="MenuRight" and 1 or -1))%3
			-- new active choice gains focus
			choice_actors[active_index]:diffuse(PlayerColor(PLAYER_2)):finishtweening():linear(0.1):zoom(_zoom.active)
			--play sound
			af:queuecommand("DirectionButton")

		elseif event.GameButton == "Back" or (event.GameButton == "Start" and active_index == 2) then
			-- send the player back to the previous screen
			local top_screen = SCREENMAN:GetTopScreen()
			local prev_screen_name = top_screen:GetPrevScreenName()
			top_screen:SetNextScreenName(prev_screen_name):StartTransitioningScreen("SM_GoToNextScreen")

		elseif event.GameButton == "Start" and (active_index == 0 or active_index == 1) then

			-- if the player wants to reset Preferences back to SM5 defaults
			if active_index == 0 then
				ResetPreferencesToStockSM5()
			end

			--either way, change the theme now
			THEME:SetTheme(SL.NextTheme)
		end
	end
end

local t = Def.ActorFrame{ OnCommand=function(self) af=self; SCREENMAN:GetTopScreen():AddInputCallback(InputHandler) end }

t[#t+1] = LoadFont("Common Normal")..{
	Text=ScreenString("Paragraph1"),
	InitCommand=function(self)
		self:xy(_screen.cx-text_width/2, 25):_wrapwidthpixels(text_width):align(0,0):diffusealpha(0):zoom(WideScale(1.15,1))
	end,
	OnCommand=function(self) self:linear(0.15):diffusealpha(1) end
}

t[#t+1] = LoadFont("Common Normal")..{
	Text=ScreenString("Paragraph2"),
	InitCommand=function(self)
		self:xy(_screen.cx-text_width/2, 300):_wrapwidthpixels(text_width):align(0,0):diffusealpha(0):zoom(WideScale(1.15,1))
	end,
	OnCommand=function(self) self:linear(0.15):diffusealpha(1) end
}

local choices_af = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0):y(225) end,
	OnCommand=function(self) self:sleep(0.333):linear(0.15):diffusealpha(1) end,
}

choices_af[#choices_af+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:x(_screen.cx-text_width/WideScale(2.15,2)):diffuse( PlayerColor(PLAYER_2) ):zoom(_zoom.active)
		choice_actors[0] = self
	end,

	LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
		Text=ScreenString("Yes"),
		InitCommand=function(self) self:zoom(1.1) end
	},
	LoadFont("Common Normal")..{
		Text=ScreenString("YesInfo"),
		InitCommand=function(self) self:y(32) end,
	}
}


choices_af[#choices_af+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:x(_screen.cx-WideScale(17.5,15)):zoom(_zoom.inactive)
		choice_actors[1] = self
	end,

	LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
		Text=ScreenString("No"),
		InitCommand=function(self) self:zoom(1.1) end
	},
	LoadFont("Common Normal")..{
		Text=ScreenString("NoInfo"),
		InitCommand=function(self) self:y(32)  end,
	}
}

choices_af[#choices_af+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:x(_screen.cx+text_width/WideScale(2.35,2)):zoom(_zoom.inactive)
		choice_actors[2] = self
	end,

	LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
		Text=THEME:GetString("ScreenTextEntry", "Cancel"),
		InitCommand=function(self) self:zoom(1.1) end
	}
}

t[#t+1] = choices_af

-- sound effect
t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{
	DirectionButtonCommand=function(self) self:play() end
}

return t