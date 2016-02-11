local wheel = setmetatable({}, sick_wheel_mt)

-- a simple flag to determine if the color was actively selected by a player;
-- we don't want the FinishCommand to double-trigger via the timer running out
-- AND a player pressing start
local ColorSelected = false

local NumHeartsToDraw = IsUsingWideScreen() and 11 or 7

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()
		local underlay = topscreen:GetChild("Underlay")

		if event.GameButton == "MenuRight" then
			wheel:scroll_by_amount(1)
			underlay:GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			wheel:scroll_by_amount(-1)
			underlay:GetChild("change_sound"):play()

		elseif event.GameButton == "Start" then
			if not GAMESTATE:IsPlayerEnabled(event.PlayerNumber) and PREFSMAN:GetPreference("Premium") == "Premium_2PlayersFor1Credit" then
				GAMESTATE:JoinPlayer(event.PlayerNumber)
			end

			ColorSelected = true
			underlay:playcommand("Finish")

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
				Name=name,
				InitCommand=function(subself)
					self.container = subself
				end
			}

			af[#af+1] = LoadActor(THEME:GetPathG("", "heart.png"))..{
				InitCommand=function(subself)
					self.heart = subself
					subself:diffusealpha(0)
					subself:zoom(0.25)
				end,
				OnCommand=function(subself)
					subself:sleep(0.2)
					subself:sleep(0.04 * self.index)
					subself:linear(0.2)
					subself:diffusealpha(1)
				end,
				OffCommand=function(subself)
					subself:sleep(0.04 * self.index)
					subself:linear(0.2)
					subself:diffusealpha(0)
				end
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			self.container:linear(0.2)
			self.index=item_index

			local X_SpaceBetweenHearts = IsUsingWideScreen() and (_screen.w / (num_items-1)) or (_screen.w / (num_items))
			local OffsetFromCenter = (item_index - math.floor(num_items/2))-1
			local x = X_SpaceBetweenHearts * OffsetFromCenter
			local z = -1 * math.abs(OffsetFromCenter)
			local zoom = IsUsingWideScreen() and (z + math.floor(num_items/2))/4 or (z + math.floor(num_items/2) + 1)/4

			if item_index <= 1 or item_index >= num_items then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end

			self.container:x(x)
			self.container:z( z )
			self.heart:diffuse( color(self.color) )

			if IsUsingWideScreen() then
				local y = (12 * math.pow(OffsetFromCenter,2)) - 20
				self.container:rotationz( OffsetFromCenter * 15 )
				self.container:zoom( zoom )
				self.container:y( y )

			else
				self.container:y( -20 )
				self.container:zoom( zoom )
			end

		end,

		set = function(self, color)
			if not color then return end
			self.color = color
		end
	}
}

local t = Def.ActorFrame{
	InitCommand=function(self)
		wheel:set_info_set(SL.Colors, SL.Global.ActiveColorIndex)
		self:queuecommand("Capture")
		self:GetChild("ColorWheel"):SetDrawByZPosition(true)
	end,
	OnCommand=function(self)
		if PREFSMAN:GetPreference("MenuTimer") then
			self:queuecommand("Listen")
		end
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()
		if seconds <= 0 and not ColorSelected then
			ColorSelected = true
			self:playcommand("Finish")
		else
			self:sleep(0.25)
			self:queuecommand("Listen")
		end
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	FinishCommand=function(self)
		self:GetChild("start_sound"):play()

		SL.Global.ActiveColorIndex = FindInTable( wheel:get_info_at_focus_pos(), SL.Colors )
		MESSAGEMAN:Broadcast("ColorSelected")

		SCREENMAN:GetTopScreen():RemoveInputCallback(input)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
	wheel:create_actors( "ColorWheel", NumHeartsToDraw, wheel_item_mt, _screen.cx, _screen.cy )
}

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }

return t