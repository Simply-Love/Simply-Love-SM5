-- ----------------------------------------
-- basement stories

-- ----------------------------------------
-- basic/common components for a simple kinetic novel experience

local scenes, directory, audio, asset_width = unpack(...)

-- used to index the scenes tables
local scene_index = 1
-- time in seconds to fade out a scene when finished
local fade_duration = 1.666

-- GetTimeSinceStart(), start_time, and uptime will be used in
-- a custom update function to keep track of elapsed runtime.
-- Relying on actor tweens (e.g. queueing actors to sleep() for a desired time at AF's OnCommand)
-- isn't reliable enough when millisecond accuracy is need to have visuals sync with
-- a long-running audio file.

-- set start_time to nil here at file load
-- we can use this nil as a flag so that we don't start tracking uptime too soon,
-- before the audio has loaded and started playing
local start_time = nil
local uptime = 0

local give_up_time = 0.5
local held_duration, old_time = 0, 0
local input = { start=false, back=false }

-- ----------------------------------------
-- update function

-- two params:
--    reference to main ActorFrame
--    delta time in ms since last update call (not used here)
local update = function(af, dt)

	-- handle input indicating the player wishes to leave early
	if input.start or input.back then
		if old_time == 0 then
			old_time = GetTimeSinceStart()
			held_duration = 0
		else
			held_duration = GetTimeSinceStart() - old_time
		end

		if held_duration > give_up_time then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end

	if start_time ~= nil then
		uptime = GetTimeSinceStart() - start_time

		-- if there is a next scene to show
		if  scenes[scene_index]
		-- and kinetic novel uptime has reached the point where it's time to show it
		and uptime > scenes[scene_index][1]
		-- and it hasn't already been queued to be shown
		and not scenes[scene_index][2]
		then
			-- queue the appropriate Show or FadeOut for the current scene
			af:GetChild("Scene"..(math.ceil(scene_index/2))):queuecommand( scene_index % 2 == 1 and "Show" or "FadeOut" )

			-- set the flag that this Show or FadeOut has been queued
			-- so that it will not be queued again in the next update() call
			scenes[scene_index][2] = true

			-- and increment the scene index
			scene_index = scene_index + 1
		end

		-- done
		if scene_index > #scenes then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
end

-- ----------------------------------------
-- Actors

local af =  Def.ActorFrame{}

af.InitCommand=function(self)
	self:SetUpdateFunction( update )
end

af.InputEventCommand=function(self, event)

	if event.type ~= "InputEventType_Release" then
		if (event.button=="Start") then input.start = true end
		if (event.button=="Back")  then input.back  = true end

	else

		if (event.button=="Start") then
			held_duration, old_time = 0, 0
			input.start = false
		end
		if (event.button=="Back") then
			held_duration, old_time = 0, 0
			input.back = false
		end
	end
end



af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:FullScreen():Center():diffuse(0,0,0,1)
	end
}

-- audio
af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/"..directory.."/"..audio),
	OnCommand=function(self)
		self:play()
		start_time = GetTimeSinceStart()
	end
}

-- scenes
for i=1, #scenes/2 do

	local path = THEME:GetPathB("ScreenHereInTheDarkness", "overlay/"..directory.."/assets/"..i.."/default.lua")

	af[#af+1] = LoadActor(path)..{
		Name=("Scene%i"):format(i),
		InitCommand=function(self)
			self:Center()
			self:zoom(_screen.w/asset_width)
			self:visible(false)
		end,
		ShowCommand=function(self)
			self:visible(true):sleep( scenes[i+1][1] - scenes[i][1] - fade_duration )
		end,

		FadeOutCommand=function(self)
			self:smooth(fade_duration):diffusealpha(0):queuecommand("Hibernate")
		end,
		HibernateCommand=function(self) self:hibernate(math.huge) end
	}
end

return af