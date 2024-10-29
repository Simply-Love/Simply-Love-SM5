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
			active_index = (active_index + (event.GameButton=="MenuRight" and 1 or -1)) % 2
			-- new active choice gains focus
			choice_actors[active_index]:diffuse(PlayerColor(PLAYER_2)):finishtweening():linear(0.1):zoom(_zoom.active)
			--play sound
			af:queuecommand("DirectionButton")

		elseif event.GameButton == "Start" then
			-- if the player wants to change to the SRPG8 style.
			if active_index == 0 then
				SL.SRPG8:ActivateVisualStyle()
			-- Set the event so that this screen doesn't show up again.
			else
				ThemePrefs.Set("LastActiveEvent", "SRPG8")
			end

			local top_screen = SCREENMAN:GetTopScreen()
			top_screen:SetNextScreenName("ScreenTitleMenu"):StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
end

local t = Def.ActorFrame{ OnCommand=function(self) af=self; SCREENMAN:GetTopScreen():AddInputCallback(InputHandler) end }

t[#t+1] = LoadFont("Common Normal")..{
	Text=ScreenString("Paragraph1"),
	InitCommand=function(self)
		self:xy(_screen.cx, 90):_wrapwidthpixels(text_width):diffusealpha(0):zoom(WideScale(2.15,2))
	end,
	OnCommand=function(self) self:linear(0.15):diffusealpha(1) end
}

t[#t+1] = LoadFont("Common Normal")..{
	Text=ScreenString("Paragraph2"),
	InitCommand=function(self)
		self:xy(_screen.cx, 350):_wrapwidthpixels(text_width):diffusealpha(0):zoom(WideScale(1.15,1))
	end,
	OnCommand=function(self) self:linear(0.15):diffusealpha(1) end
}

local choices_af = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0):y(225) end,
	OnCommand=function(self) self:sleep(0.333):linear(0.15):diffusealpha(1) end,
}

choices_af[#choices_af+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:x(_screen.cx-80):diffuse( PlayerColor(PLAYER_2) ):zoom(_zoom.active)
		choice_actors[0] = self
	end,

	LoadFont("Common Bold")..{
		Text=THEME:GetString("ScreenPromptToResetPreferencesToStock","Yes"),
		InitCommand=function(self) self:zoom(1.1) end
	},
	LoadFont("Common Normal")..{
		Text=ScreenString("YesInfo"),
		InitCommand=function(self) self:y(32) end,
	}
}


choices_af[#choices_af+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:x(_screen.cx+80):zoom(_zoom.inactive)
		choice_actors[1] = self
	end,

	LoadFont("Common Bold")..{
		Text=THEME:GetString("ScreenPromptToResetPreferencesToStock","No"),
		InitCommand=function(self) self:zoom(1.1) end
	},
	LoadFont("Common Normal")..{
		Text=ScreenString("NoInfo"),
		InitCommand=function(self) self:y(32)  end,
	}
}

t[#t+1] = choices_af

-- sound effect
t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{
	IsAction=true,
	DirectionButtonCommand=function(self) self:play() end
}

return t