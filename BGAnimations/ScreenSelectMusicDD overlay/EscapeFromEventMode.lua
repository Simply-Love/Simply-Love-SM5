local text_width = 420
local active_index = 0
local choice_actors, sfx = {}, {}
local af

local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then return false end

	if event.type == "InputEventType_FirstPress" then
		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			af:queuecommand("ChangeChoice")

		-- cancel out of this prompt overlay and return to selecting a song
		elseif event.GameButton == "Back" or event.GameButton == "Select" or (event.GameButton == "Start" and active_index == 0) then
			af:queuecommand("Cancel")

		-- back out of ScreenSelectMusic and head to either EvaluationSummary (if stages were played) or TitleMenu
		elseif event.GameButton == "Start" and active_index == 1 then
			af:queuecommand("YourFinished")
		end
	end
end


local af = Def.ActorFrame{
	InitCommand=function(self) af = self:visible(false) end,

	-- the SM5 engine has broadcast that the player input a Metrics-based button code
	CodeMessageCommand=function(self, params)
		if params.Name == "EscapeFromEventMode" then
			EscapeFromEventMode = true
			self:queuecommand("Show")
		end
	end,

	-- show the overlay
	ShowCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
			SOUND:StopMusic()
			-- ensure that the first choice (no) will be active when the prompt overlay first appears
			active_index = 0
			-- make "no" the active_choice
			choice_actors[0]:stoptweening():diffuse(PlayerColor(PLAYER_2)):zoom(1.1)
			-- ensure that "yes" is not the active_choice
			choice_actors[1]:stoptweening():diffuse(1,1,1,1):zoom(0.5)
			
			-- activate our Lua InputHandler
			topscreen:AddInputCallback(InputHandler)

			-- disable the engine's input handling
			InputMenuHasFocus = true
			-- make this overlay visible
			self:visible(true)
		end
	end,

	ChangeChoiceCommand=function(self)
		-- old active_choice loses focus
		choice_actors[active_index]:diffuse(1,1,1,1):stoptweening():linear(0.1):zoom(0.5)
		-- update active_index
		active_index = (active_index + 1)%2
		-- new active_choice gains focus
		choice_actors[active_index]:diffuse(PlayerColor(PLAYER_2)):stoptweening():linear(0.1):zoom(1.1)
		--play sound effect
		sfx.change:play()
	end,
	CancelCommand=function(self)
		if GAMESTATE:IsCourseMode() then
			play_sample_music()
		end
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
			-- play the start sound effect
			sfx.start:play()
			-- deactivate the Lua InputHandler
			topscreen:RemoveInputCallback(InputHandler)
			-- return input handling to input.lua so players can continune choosing a song
			EscapeFromEventMode = false
			-- hide this overlay
			self:visible(false)
		end
	end,
	-- my finished?
	YourFinishedCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
			-- play the start sound effect
			sfx.start:play()
			-- return input handling to the input.lua before leaving ScreenSelectMusic
			EscapeFromEventMode = false
			-- determine what the previous screen would be (because next screen is normally PlayerOptions or Gameplay)
			-- make that the next screen, and transition to it
			topscreen:SetNextScreenName( topscreen:GetPrevScreenName() ):StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
}

-- sound effects
af[#af+1] = Def.Sound{ File=THEME:GetPathS("ScreenSelectMaster", "change"), InitCommand=function(self) sfx.change = self end }
af[#af+1] = Def.Sound{ File=THEME:GetPathS("Common", "Start"), InitCommand=function(self) sfx.start = self end }

-- darkened background
af[#af+1] = Def.Quad{ InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.925) end }

-- "Do you want to exit this game?" prompt
af[#af+1] = Def.BitmapText{
	Font="Common Normal",
	Text=ScreenString("PromptBeforeExiting"),
	InitCommand=function(self) self:zoom(1.3):xy(_screen.cx-((self:GetWidth()/2)*self:GetZoom()), _screen.cy-70):_wrapwidthpixels(text_width):align(0,0) end
}

-- -------------------------------
-- choices

local choices_af = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	OnCommand=function(self) self:sleep(0.333):linear(0.15):diffusealpha(1) end,
}

local no = Def.ActorFrame{
	InitCommand=function(self)
		choice_actors[0] = self
		self:x(THEME:GetMetric("ScreenPrompt","Answer1Of2X"))
		self:y(250):diffuse( PlayerColor(PLAYER_2) )
	end,

	LoadFont("Common Bold")..{
		Text=THEME:GetString("ScreenPromptToResetPreferencesToStock","No"),
		InitCommand=function(self) self:zoom(1.1) end
	},
	LoadFont("Common Normal")..{
		Text=ScreenString("NoInfo"),
		InitCommand=function(self) self:addy(30):zoom(0.825) end,
	}
}

local yes = Def.ActorFrame{
	InitCommand=function(self)
		choice_actors[1] = self
		self:x(THEME:GetMetric("ScreenPrompt","Answer2Of2X"))
		self:y(250)
	end,

	LoadFont("Common Bold")..{
		Text=THEME:GetString("ScreenPromptToResetPreferencesToStock","Yes"),
		InitCommand=function(self) self:zoom(1.1) end
	},
	LoadFont("Common Normal")..{
		Text=ScreenString("YesInfo"),
		InitCommand=function(self) self:addy(30):zoom(0.825) end,
	}
}
-- -------------------------------

table.insert(choices_af, yes)
table.insert(choices_af,  no)
table.insert(af, choices_af)

return af