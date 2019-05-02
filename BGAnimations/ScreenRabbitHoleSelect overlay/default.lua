local rh_wheel = setmetatable({}, sick_wheel_mt)
local wheel_item_mt = LoadActor("WheelItemMT.lua")

local wheel_options = {
	{1, "Snowfall"},
	{2, "Unix Timestamps"},
	{3, "Quietly Turning"},
	{4, "Recalling"},
	{5, "Hallways"},
	{6, "Seaside Catchball"},
	{7, "Dragons"},
	{8, "I like our castle."},
	{9, "Gibberish, Maybe"},
	{10, "13 Ghosts II"},
	{11, "A Troubled Sea"},
	{12, "Where the Hallway Ends"},
	{13, "Sometimes I Think I Have It Bad"},
	{14, "Connection: Chapter 1"},
	{15, "Connection: Chapter 2"},
	{16, "Connection: Chapter 3"},
	{17, "Connection: Chapter 4"},
	{18, "A Beige Colored Bookmark"},
	{19, "Your Drifting Mind"},
	{20, "A Walk In the Snow"},
	{21, "– Acknowledgments & Thanks –"},
	{22, "Exit" }
}

local Cancel = function()
	SL.Global.RabbitHole = nil
	local topscreen = SCREENMAN:GetTopScreen()
	topscreen:SetNextScreenName("ScreenAcknowledgmentsMenu")
	topscreen:StartTransitioningScreen("SM_GoToNextScreen")
end

local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type ~= "InputEventType_Release" then

		if event.GameButton == "MenuRight" or event.GameButton=="MenuDown" then
			rh_wheel:scroll_by_amount(1)

		elseif event.GameButton == "MenuLeft" or event.GameButton=="MenuUp" then
			rh_wheel:scroll_by_amount(-1)

		elseif event.GameButton == "Start" then
			local focus = rh_wheel:get_actor_item_at_focus_pos()
			if focus.rh_index == #wheel_options then
				Cancel()
				return false
			end

			-- set index to persist through reload
			SL.Global.RabbitHole = focus.rh_index
			-- reload
			local topscreen = SCREENMAN:GetTopScreen()
			topscreen:SetNextScreenName("ScreenRabbitHole")
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")

		elseif event.GameButton == "Back" or event.GameButton == "Select" then
			Cancel()
		end
	end
end

-- - - - - - - - - - - - - - - - - - - - - - - - - - - -

local t = Def.ActorFrame {
	Name="RH_Menu",
	OnCommand=function(self)
		rh_wheel:set_info_set(wheel_options, 1)
		SCREENMAN:GetTopScreen():AddInputCallback( InputHandler )
	end,

	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	rh_wheel:create_actors( "rh_wheel", #wheel_options, wheel_item_mt, _screen.cx, 40 )
}

return t