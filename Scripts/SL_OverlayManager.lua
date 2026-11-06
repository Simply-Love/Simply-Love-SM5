---------------------------------------------------------------------------
-- SL_OverlayManager.lua
-- Centralized singleton overlay stack and input routing manager for Simply Love.
-- This is for overlays that sit on top of the main screen (e.g. modals, popups, etc.),
-- that need to intercept input.
---------------------------------------------------------------------------

SL = SL or {}

local OverlayManager = {
	stack = {},
	_input_callback_bound = false,
	_bound_screen_name = nil,
	_paused_screen_timer = false,
}

-- Checks if any overlay is currently open
function OverlayManager:HasActiveOverlay()
	return #self.stack > 0
end

-- Returns the topmost (currently active) overlay instance
function OverlayManager:Top()
	if #self.stack > 0 then
		return self.stack[#self.stack]
	end
	return nil
end

-- Returns the number of overlays currently stacked
function OverlayManager:Count()
	return #self.stack
end

-- Central input callback attached to SCREENMAN:GetTopScreen()
local function OnEngineInput(event)
	if not (event and event.button) then return false end

	local active_overlay = OverlayManager:Top()
	if not active_overlay then
		return false
	end

	-- Forward the event to the active overlay
	if active_overlay._HandleInput then
		active_overlay:_HandleInput(event)
	end

	-- Always swallow input while an overlay is active so the screen underneath cannot react
	return true
end

OverlayManager._InputCallback = OnEngineInput

-- Hook Screen.AddInputCallback and Screen.RemoveInputCallback so that any input
-- callbacks registered by underlying screens are automatically suppressed while
-- an overlay is active, ensuring the manager is completely responsible for input
-- interception without screens needing custom overlay guards.
if Screen and Screen.AddInputCallback and Screen.RemoveInputCallback then
	local orig_add = Screen.AddInputCallback
	local orig_remove = Screen.RemoveInputCallback
	local wrapped_callbacks = setmetatable({}, { __mode = "k" })

	Screen.AddInputCallback = function(self, fn)
		if not fn or fn == OverlayManager._InputCallback then
			return orig_add(self, fn)
		end

		local wrapped = function(event)
			if OverlayManager:HasActiveOverlay() then
				return false
			end
			return fn(event)
		end

		wrapped_callbacks[fn] = wrapped
		return orig_add(self, wrapped)
	end

	Screen.RemoveInputCallback = function(self, fn)
		if not fn or fn == OverlayManager._InputCallback then
			return orig_remove(self, fn)
		end

		local wrapped = wrapped_callbacks[fn] or fn
		wrapped_callbacks[fn] = nil
		return orig_remove(self, wrapped)
	end
end

-- Activates input capture on the engine for all joined players
function OverlayManager:_EnableInputInterception(pause_timer)
	local top_screen = SCREENMAN:GetTopScreen()
	if not top_screen then return end

	-- Lock engine input for all player slots
	for player in ivalues(PlayerNumber) do
		SCREENMAN:set_input_redirected(player, true)
	end

	-- Attach input callback if not already bound to this screen
	local screen_name = top_screen:GetName()
	if not self._input_callback_bound or self._bound_screen_name ~= screen_name then
		top_screen:AddInputCallback(self._InputCallback)
		self._input_callback_bound = true
		self._bound_screen_name = screen_name
	end

	-- Handle MenuTimer pausing if requested
	if pause_timer then
		local timer = top_screen:GetChild("Timer")
		if timer and timer.Pause then
			timer:Pause()
			self._paused_screen_timer = true
		end
	end
end

-- Releases input capture back to the engine
function OverlayManager:_DisableInputInterception()
	local top_screen = SCREENMAN:GetTopScreen()

	-- NOTE: We intentionally do NOT call top_screen:RemoveInputCallback(self._InputCallback).
	-- StepMania's Screen::PassInputToLua contains a known C++ engine bug where
	-- m_DelayedCallbackRemovals is never cleared. Removing a callback during
	-- input execution permanently leaves it in the delayed removals list, causing
	-- any subsequent AddInputCallback for that same function pointer to be instantly
	-- removed at the end of the next input frame.
	-- Leaving self._InputCallback attached is completely safe and zero-overhead
	-- because OnEngineInput immediately returns false whenever self.stack is empty.

	-- Restore engine input redirection for all player slots
	for player in ivalues(PlayerNumber) do
		SCREENMAN:set_input_redirected(player, false)
	end

	-- Resume MenuTimer if previously paused
	if self._paused_screen_timer and top_screen then
		local timer = top_screen:GetChild("Timer")
		if timer and timer.Resume then
			timer:Resume()
		end
		self._paused_screen_timer = false
	end
end

-- Pushes a new overlay onto the stack and opens it
function OverlayManager:Push(overlay, params)
	if not overlay then return end

	-- If an overlay is already active, notify it that it is losing top focus
	local current_top = self:Top()
	if current_top and current_top._OnLoseFocus then
		current_top:_OnLoseFocus()
	end

	-- Add to stack
	table.insert(self.stack, overlay)

	-- Record the originating screen name
	local top_screen = SCREENMAN:GetTopScreen()
	overlay._screen_name = top_screen and top_screen:GetName()

	-- If this is the first overlay, lock engine input
	if #self.stack == 1 then
		self:_EnableInputInterception(overlay.PauseTimer)
	end

	-- Notify the new overlay that it gained focus and trigger its open sequence
	if overlay._OnGainFocus then
		overlay:_OnGainFocus()
	end
	if overlay._InternalOpen then
		overlay:_InternalOpen(params)
	end
end

-- Pops the active overlay from the stack and closes it
function OverlayManager:Pop(reason)
	if #self.stack == 0 then return end

	local overlay = table.remove(self.stack)

	-- Notify closing overlay
	if overlay and overlay._InternalClose then
		overlay:_InternalClose(reason or "dismiss")
	end

	-- If overlays still remain, return focus to the new topmost overlay
	if #self.stack > 0 then
		local new_top = self:Top()
		if new_top and new_top._OnGainFocus then
			new_top:_OnGainFocus()
		end
	else
		-- No more overlays active; release input back to the engine
		self:_DisableInputInterception()
	end
end

-- Safely dismisses all overlays (e.g., when screen transitions or resets)
function OverlayManager:DismissAll(reason)
	if #self.stack == 0 then
		-- Ensure engine input redirection is clean even if stack was already empty
		self:_DisableInputInterception()
		return
	end

	reason = reason or "screen_exit"

	-- Close all stacked overlays in reverse order
	for i = #self.stack, 1, -1 do
		local overlay = self.stack[i]
		if overlay and overlay._InternalClose then
			pcall(function() overlay:_InternalClose(reason) end)
		end
	end

	self.stack = {}
	self:_DisableInputInterception()
end

-- Screen transition handler: only dismisses if the screen actually changed
function OverlayManager:OnScreenChanged()
	local top_screen = SCREENMAN:GetTopScreen()
	local current_screen_name = top_screen and top_screen:GetName()

	if #self.stack > 0 then
		local active = self:Top()
		if active and (not active._screen_name or active._screen_name ~= current_screen_name) then
			self:DismissAll("screen_exit")
		end
	else
		-- Ensure clean input state
		self:_DisableInputInterception()
	end

	-- Reset bound state so the new screen will attach the input callback if an overlay opens
	self._input_callback_bound = false
	self._bound_screen_name = nil
end

SL.OverlayManager = OverlayManager
return OverlayManager
