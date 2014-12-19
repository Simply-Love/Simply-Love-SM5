local wheel = setmetatable({disable_wrapping = true}, sick_wheel_mt)

-- Ugh, so many calculations on this screen depend on the number of wheel
-- items, or number of colors, but use constants instead of checking the
-- values they depend on.  I'm not even going to try to sort it out.  I hope
-- you don't do things this way in any future theme.  -Kyz

local function CalculateSleepBeforeAppear( s,index )
	local constantWait = 0.05
	local center_index = wheel:get_actor_item_at_focus_pos().index

	for i=1,9 do
		if index == (center_index + (i - 5)) % 12 + 1 then
			s:sleep(constantWait*i)
			break
		end
	end
end

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()
		local overlay = topscreen:GetChild("Overlay")

		if event.GameButton == "MenuRight" then
			wheel:scroll_by_amount(1)
			overlay:GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			wheel:scroll_by_amount(-1)
			overlay:GetChild("change_sound"):play()

		elseif event.GameButton == "Start" then
			if not GAMESTATE:IsPlayerEnabled(event.PlayerNumber) then
				if not GAMESTATE:JoinInput(event.PlayerNumber) then
					return false
				end
			end
			
			overlay:GetChild("start_sound"):play()
			SetSimplyLoveColor(wheel:get_actor_item_at_focus_pos().index)
			SL_CustomPrefs:save()
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
			local index = tonumber((name:gsub("item","")))
			self.index=index

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
				end
			}

			af[#af+1] = LoadActor(THEME:GetPathG("", "heart.png"))..{
				InitCommand=cmd(diffusealpha,0),
				OnCommand=function(self)
					self:sleep(0.2)
					CalculateSleepBeforeAppear(self, index)
					self:linear(0.2)
					self:diffusealpha(1)
				end,
				OffCommand=function(self)
					CalculateSleepBeforeAppear(self, index)
					self:linear(0.2)
					self:diffusealpha(0)
				end
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			self.container:linear(0.2)

			local n = 80
			local offset = item_index - num_items/2

			local x = n*offset
			if x > 6*n then
				x = x-12*n
			elseif x < -6*n then
				x = x+12*n
			end
			local s = scale(math.abs(x),0,4*n,3,-1)
			local z = clamp(s,1,3)
			z = scale(z,1,3,1,1.5)
			s = clamp(s,0,3)

			self.container:x(x)
			self.container:zoom(z/6)
			self.container:diffuse(GetHexColor(self.index))

			if IsUsingWideScreen() then
				self.container:diffusealpha(clamp(5-math.abs(offset), 0, 1))
				self.container:zoom(math.pow(math.abs(math.cos(offset*math.pi)*math.cos(math.pow(math.abs(offset),.5)*math.pi/6)/2),1.75))
				self.container:rotationz(offset*15)
				self.container:y(10*math.pow(offset,2)-40)
			else
				self.container:diffusealpha(clamp(3-math.abs(offset), 0, 1))
			end
			self.container:z(-1 * math.abs(x/n))

		end,

		set = function(self, info)
			self.info= info
			if not info then return end
		end
	}
}

local t = Def.ActorFrame{
	InitCommand=function(self)
		-- I don't know where I went wrong when explaining sick_wheel, but this is
		-- so much the wrong way to do things.  You're supposed to pass an info
		-- set that contains info useful to your elements, not garbage. -Kyz
		wheel:set_info_set({""}, 1)
		wheel:scroll_by_amount((SimplyLoveColor() - 6) % 12 )
		self:queuecommand("Capture")
		self:GetChild("colorwheel"):SetDrawByZPosition(true)
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	wheel:create_actors( "colorwheel", 12, wheel_item_mt, _screen.cx, _screen.cy )
}

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }


return t