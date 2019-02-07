local args = ...
local af = args.af
local wheel = args.wheel

local InputHandler = function(event)
	-- if any of these, don't attempt to handle input
	if not event or not event.button then return false end

	if event.GameButton == "MenuRight" then
		wheel:scroll_by_amount(1)
	elseif event.GameButton == "MenuLeft" then
		wheel:scroll_by_amount(-1)
	end
end

return InputHandler