local choice_wheel = setmetatable({}, sick_wheel_mt)
local choices = { THEME:GetString("OptionTitles", "Yes"), THEME:GetString("OptionTitles", "No") }

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()
		local underlay = topscreen:GetChild("Underlay")

		if event.GameButton == "MenuRight" then
			choice_wheel:scroll_by_amount(1)
			underlay:GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			choice_wheel:scroll_by_amount(-1)
			underlay:GetChild("change_sound"):play()

		elseif event.GameButton == "Start" then
			if not GAMESTATE:IsPlayerEnabled(event.PlayerNumber) then
				if not GAMESTATE:JoinInput(event.PlayerNumber) then
					return false
				end
			end

			underlay:GetChild("start_sound"):play()
			local choice = choice_wheel:get_actor_item_at_focus_pos().info
			if choice == "Yes" then

				local Players =  GAMESTATE:GetHumanPlayers()

				for pn in ivalues(Players) do
					for i=1, PREFSMAN:GetPreference("SongsPerPlay") do
						GAMESTATE:AddStageToPlayer(pn)
					end
				end

				local coins = PREFSMAN:GetPreference("CoinsPerCredit")
				local premium = PREFSMAN:GetPreference("Premium")

				if premium == "Premium_DoubleFor1Credit" then
					if SL.Global.Gamestate.Style == "versus" then
						coins = coins * 2
					end

				elseif premium == "Premium_Off" then
					if SL.Global.Gamestate.Style == "versus" or SL.Global.Gamestate.Style == "double" then
						coins = coins * 2
					end
				end

				GAMESTATE:InsertCoin(-coins)

				SL.Global.Stages.Remaining = PREFSMAN:GetPreference("SongsPerPlay")
				SL.Global.ContinuesRemaining = SL.Global.ContinuesRemaining - 1

				SL.Global.ScreenAfter.PlayAgain = (SL.Global.GameMode == "Casual" and "ScreenSelectMusicCasual") or "ScreenSelectMusic"
			else
				SL.Global.ScreenAfter.PlayAgain = "ScreenEvaluationSummary"
			end

			topscreen:RemoveInputCallback(input)
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")

		elseif event.GameButton == "Back" then
			topscreen:RemoveInputCallback(input)
			topscreen:Cancel()
		end
	end

	return false
end

-- the metatable for an item in the wheel
local wheel_item_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{

				InitCommand=function(subself)
					self.container = subself
				end
			}

			af[#af+1] = LoadFont("_wendy small")..{
				InitCommand=function(subself)
					self.text= subself
					subself:diffusealpha(0)
				end,
				OnCommand=function(subself)
					if subself:GetText() == THEME:GetString("OptionTitles", "No") then
						subself:x(100)
					else
						subself:x(-100)
					end
					subself:linear(0.15)
					subself:diffusealpha(1)

				end
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()

			if has_focus then
				self.container:accelerate(0.15)
				self.container:zoom(1)
				self.container:diffuse( GetCurrentColor() )
				self.container:glow(color("1,1,1,0.5"))
			else
				self.container:glow(color("1,1,1,0"))
				self.container:accelerate(0.15)
				self.container:zoom(0.8)
				self.container:diffuse(color("#888888"))
				self.container:glow(color("1,1,1,0"))
			end

		end,

		set = function(self, info)
			self.info= info
			if not info then return end
			self.text:settext(THEME:GetString("OptionTitles", info))
		end
	}
}

local t = Def.ActorFrame{
	InitCommand=function(self)
		--reset this now, otherwise it might still be set to SSM from a previous continue
		--and we don't want that if a timeout occurs
		SL.Global.ScreenAfter.PlayAgain = "ScreenEvaluationSummary"

		choice_wheel:set_info_set(choices, 1)
		self:queuecommand("Capture")
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,

	-- I'm not sure why the built-in MenuTimer doesn't force a transition to the nextscreen
	-- when it runs out of time, but... it isn't.  So recursively listen for time remaining here
	-- and force a screen transition when time runs out.
	OnCommand=function(self)
		if PREFSMAN:GetPreference("MenuTimer") then
			self:queuecommand("Listen")
		end
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()
		if seconds <= 0 then
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")
		else
			self:sleep(0.5)
			self:queuecommand("Listen")
		end
	end,

	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=cmd(FullScreen; diffuse,Color.Black; diffusealpha,0.6)
	},

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenPlayAgain", "Continue"),
		InitCommand=cmd(xy, _screen.cx, _screen.cy-30),
	},

	choice_wheel:create_actors( "sort_wheel", #choices, wheel_item_mt, _screen.cx, _screen.cy+50 ),

}

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }

return t