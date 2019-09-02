local text_width = 420

local active_index = 0
local choice_actors = {}
local af

local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then return false end

	if event.type == "InputEventType_FirstPress" then
		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			-- old active choice loses focus
			choice_actors[active_index]:diffuse(1,1,1,1):linear(0.1):zoom(0.5)
			-- update active_index
			active_index = (active_index + (event.GameButton=="MenuRight" and 1 or -1))%3
			-- new active choice gains focus
			choice_actors[active_index]:diffuse(PlayerColor(PLAYER_2)):linear(0.1):zoom(1.1)
			--play sound
			af:queuecommand("DirectionButton")

		elseif event.GameButton == "Back" or (event.GameButton == "Start" and active_index == 2) then
			-- send the player back to the previous screen
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectGame"):StartTransitioningScreen("SM_GoToNextScreen")

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
		self:xy(_screen.cx-text_width/2, 25):_wrapwidthpixels(text_width):align(0,0):diffusealpha(0)
	end,
	OnCommand=function(self) self:linear(0.15):diffusealpha(1) end
}

t[#t+1] = LoadFont("Common Normal")..{
	Text=ScreenString("Paragraph2"),
	InitCommand=function(self)
		self:xy(_screen.cx-text_width/2, 315):_wrapwidthpixels(text_width):align(0,0):diffusealpha(0)
	end,
	OnCommand=function(self) self:linear(0.15):diffusealpha(1) end
}

local choices_af = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	OnCommand=function(self) self:sleep(0.333):linear(0.15):diffusealpha(1) end,
}

choices_af[#choices_af+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx-text_width/2, 250):diffuse( PlayerColor(PLAYER_2) )
		choice_actors[0] = self
	end,

	LoadFont("_wendy small")..{
		Text=ScreenString("Yes"),
		InitCommand=function(self) self:zoom(1.1) end
	},
	LoadFont("Common Normal")..{
		Text=ScreenString("YesInfo"),
		InitCommand=function(self) self:addy(30):zoom(0.825) end,
	}
}


choices_af[#choices_af+1] = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx, 250):zoom(0.5)
		choice_actors[1] = self
	end,

	LoadFont("_wendy small")..{
		Text=ScreenString("No"),
		InitCommand=function(self) end
	},
	LoadFont("Common Normal")..{
		Text=ScreenString("NoInfo"),
		InitCommand=function(self) self:addy(30):zoom(0.825)  end,
	}
}

choices_af[#choices_af+1] = LoadFont("_wendy small")..{
	Text=THEME:GetString("ScreenTextEntry", "Cancel"),
	InitCommand=function(self)
		self:xy(_screen.cx+text_width/2, 250):zoom(0.5)
		choice_actors[2] = self
	end
}

t[#t+1] = choices_af

-- sound effect
t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{
	DirectionButtonCommand=function(self) self:play() end
}

return t