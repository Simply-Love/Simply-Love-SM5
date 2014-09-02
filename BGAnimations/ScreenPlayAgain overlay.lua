local choice_wheel = setmetatable({disable_wrapping = false}, sick_wheel_mt)
local choices = { THEME:GetString("OptionTitles", "Yes"), THEME:GetString("OptionTitles", "No") }

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()
		local overlay = topscreen:GetChild("Overlay")

		if event.GameButton == "MenuRight" then
			choice_wheel:scroll_by_amount(1)
			overlay:GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			choice_wheel:scroll_by_amount(-1)
			overlay:GetChild("change_sound"):play()

		elseif event.GameButton == "Start" then
			if not GAMESTATE:IsPlayerEnabled(event.PlayerNumber) then
				if not GAMESTATE:JoinInput(event.PlayerNumber) then
					return false
				end
			end

			overlay:GetChild("start_sound"):play()
			local choice = choice_wheel:get_actor_item_at_focus_pos().choice
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

				-- set the style from the previously used one
				GAMESTATE:SetCurrentStyle(SL.Global.Gamestate.Style)

				SL.Global.Stages.Remaining = PREFSMAN:GetPreference("SongsPerPlay")
				SL.Global.ContinuesRemaining = SL.Global.ContinuesRemaining - 1


				SL.Global.ScreenAfter.PlayAgain = "ScreenSelectMusic"
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

-- the metatable for an item in the sort_wheel
local wheel_item_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name
			local index = tonumber((name:gsub("item","")))
			self.index = index
			local choice = choices[index]
			self.choice = choice

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
					if choice == "No" then
						self.container:zoom(0.75)
					end
				end
			}

			af[#af+1] = LoadFont("_wendy small")..{
				Text=choices[index],
				OnCommand=function(self)
					local scaled = scale(index,1,2,-1,1)
					self:x(scaled * 100)
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
				self.container:zoom(0.75)
				self.container:diffuse(color("#888888"))
				self.container:glow(color("1,1,1,0"))
			end

		end,

		set = function(self, info)
			self.info= info
			if not info then return end
		end
	}
}


local t = Def.ActorFrame{
	InitCommand=function(self)
		choice_wheel:set_info_set({""}, 2)
		self:queuecommand("Capture")
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,

	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=cmd(FullScreen; diffuse,Color.Black; diffusealpha,0.6)
	},

	LoadFont("_wendy small")..{
		Text="Continue?",
		InitCommand=cmd(xy, _screen.cx, _screen.cy-30),
	},

	choice_wheel:create_actors( "sort_wheel", #choices, wheel_item_mt, _screen.cx, _screen.cy+50 ),

}

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }


return t