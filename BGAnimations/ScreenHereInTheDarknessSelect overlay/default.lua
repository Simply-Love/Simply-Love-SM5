local hitd_wheel = setmetatable({}, sick_wheel_mt)
local wheel_item_mt = LoadActor("WheelItemMT.lua")

local wheel_options = {
	{ 1, "Snowfall"},
	{ 2, "Unix Timestamps"},
	{ 3, "Quietly Turning"},
	{ 4, "Recalling"},
	{ 5, "Hallways"},
	{ 6, "Seaside Catchball"},
	{ 7, "Dragons"},
	{ 8, "I like our castle."},
	{ 9, "Gibberish, Maybe"},
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

	{21, "b1. Distant Towers"},
	{22, "b2. Hold On"},

	{23, "– Acknowledgments & Thanks –"},
	{24, "Exit" },
}

local Cancel = function()
	SL.Global.HereInTheDarkness = nil
	local topscreen = SCREENMAN:GetTopScreen()
	topscreen:SetNextScreenName("ScreenAcknowledgmentsMenu")
	topscreen:StartTransitioningScreen("SM_GoToNextScreen")
end

local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_Release" then
		return false
	end

	local i = hitd_wheel:get_info_at_focus_pos()[1]

	if event.GameButton=="MenuDown" then
		if (i == 10) then
			-- vertical jump from 10 → 21
			hitd_wheel:scroll_by_amount(11)
		elseif (i==20 or i == 21) then
			-- vertical jump from 21 → 23
			hitd_wheel:scroll_by_amount(2)
		else
			hitd_wheel:scroll_by_amount(1)
		end

	elseif event.GameButton=="MenuUp" then
		if (i == 11 or i == 21) then
			-- column jump from 11 → 21
			hitd_wheel:scroll_by_amount(-11)
		elseif (i == 22) then
			-- vertical jump from 22 → 20
			hitd_wheel:scroll_by_amount(-2)
		else
			hitd_wheel:scroll_by_amount(-1)
		end

	elseif event.GameButton == "MenuRight" then
		if (i <= 10) then
			-- e.g. horizontal jump from 1 → 11
			hitd_wheel:scroll_by_amount(10)
		elseif (i > 10 and i < 20) then
			-- e.g. horizontal jump from 11 → 2
			hitd_wheel:scroll_by_amount(-9)
		else
			-- e.g. from 20 → 21
			hitd_wheel:scroll_by_amount(1)
		end

	elseif event.GameButton == "MenuLeft" then
		if (i > 1 and i <= 10) then
			-- e.g. horizontal jump from 2 → 11
			hitd_wheel:scroll_by_amount(9)
		elseif (i > 10 and i <= 20) then
			-- e.g. horizontal jump from 11 → 1
			hitd_wheel:scroll_by_amount(-10)
		else
			-- e.g. from 21 → 20
			hitd_wheel:scroll_by_amount(-1)
		end

	elseif event.GameButton == "Start" and event.type == "InputEventType_FirstPress" then
		-- exit
		if i == #wheel_options then
			Cancel()
			return false
		end

		-- set index to persist through reload
		SL.Global.HereInTheDarkness = i
		-- reload into darkness
		local topscreen = SCREENMAN:GetTopScreen()
		topscreen:SetNextScreenName("ScreenHereInTheDarkness")
		topscreen:StartTransitioningScreen("SM_GoToNextScreen")

	elseif event.GameButton == "Back" or event.GameButton == "Select" then
		Cancel()
	end

	return false
end

-- - - - - - - - - - - - - - - - - - - - - - - - - - - -

local t = Def.ActorFrame {
	Name="hitd_Menu",
	OnCommand=function(self)
		hitd_wheel:set_info_set(wheel_options, 1)
		SCREENMAN:GetTopScreen():AddInputCallback( InputHandler )
	end,

	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	hitd_wheel:create_actors( "hitd_wheel", #wheel_options, wheel_item_mt, _screen.cx, 30 )
}

return t