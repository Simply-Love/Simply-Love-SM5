local wheel = setmetatable({}, sick_wheel_mt)

-- a simple flag to determine if the color was actively selected by a player;
-- we don't want the FinishCommand to double-trigger via the timer running out
-- AND a player pressing start
local ColorSelected = false

local NumHeartsToDraw = IsUsingWideScreen() and 11 or 7

local style = ThemePrefs.Get("VisualStyle")
local colorTable = (style == "SRPG8") and SL.SRPG8.Colors or SL.DecorativeColors
local factionBmt

local text
if style == "Gay" then
	text = { "I'm gay", "we're gay", "proud", "queer" }
end

-- this handles user input
-- need to split declaration and assignment up across two lines
-- so that the reference to "input" in RemoveInputCallback(input)
-- is scoped properly (i.e. so that "input" isn't nil)
local input
input = function(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" then
		local topscreen = SCREENMAN:GetTopScreen()
		local underlay = topscreen:GetChild("Underlay")

		if event.GameButton == "MenuRight" then
			wheel:scroll_by_amount(1)
			underlay:GetChild("change_sound"):play()
			underlay:playcommand("Preview")

		elseif event.GameButton == "MenuLeft" then
			wheel:scroll_by_amount(-1)
			underlay:GetChild("change_sound"):play()
			underlay:playcommand("Preview")

		elseif event.GameButton == "Start" then
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
					if style=="Gay" and not HolidayCheer() then
						subself:bob():effectmagnitude(0,0,0):effectclock('bgm'):effectperiod(0.666)
					end
				end,
				OffCommand=function(subself)
					subself:sleep(0.04 * self.index)
					subself:linear(0.2)
					subself:diffusealpha(0)
				end
			}

			af[#af+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/SelectColor.png"))..{
				InitCommand=function(subself)
					self.heart = subself
					subself:diffusealpha(0)
					subself:zoom(0.25)
					if style == "SRPG8" then
						-- subself:blend("BlendMode_Add")
						subself:zoom(0.7)
					end
				end,
				OnCommand=function(subself)
					subself:sleep(0.2)
					subself:sleep(0.04 * self.index)
					subself:linear(0.2)
					subself:diffusealpha(1)
				end,
			}

			if style == "Gay" then
				af[#af+1] = Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.text = subself
						subself:y(-6):diffuse(Color.Black):zoom(1.2)
					end
				}
			end

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
			self.container:z(z)
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

			if style=="Gay" and item_index == (IsUsingWideScreen() and 6 or 4) then
				self.container:effectmagnitude(0,4,0)
			else
				self.container:effectmagnitude(0,0,0)
			end

			if style == "SRPG8" and has_focus then
				local idx = self.color_index % #colorTable + 1
				factionBmt:settext(SL.SRPG8.GetFactionName(idx))
			end
		end,

		set = function(self, color)
			if not color then return end
			self.color = color
			self.color_index = FindInTable(color, colorTable)
			if style=="Gay" and type(text)=="table" then
				self.text:settext(text[(self.color_index - (SL.Global.ActiveColorIndex-(#text-1))) % #text + 1])
			end
		end
	}
}

local t = Def.ActorFrame{
	InitCommand=function(self)
		wheel:set_info_set(colorTable, SL.Global.ActiveColorIndex - 1)
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
	PreviewCommand=function(self)
		SL.Global.ActiveColorIndex = FindInTable(wheel:get_info_at_focus_pos(), colorTable)
		SL.Global.ActiveColorIndex = (SL.Global.ActiveColorIndex % #colorTable) + 1
		ThemePrefs.Set("SimplyLoveColor", SL.Global.ActiveColorIndex)
		ThemePrefs.Save()
		
		MESSAGEMAN:Broadcast("ColorSelected")
	end,
	FinishCommand=function(self)
		self:GetChild("start_sound"):play()
		SCREENMAN:GetTopScreen():RemoveInputCallback(input)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
	wheel:create_actors( "ColorWheel", NumHeartsToDraw, wheel_item_mt, _screen.cx, _screen.cy )
}

if style == "SRPG8" then
	t[#t+1] = Def.BitmapText{
		Font="Common Normal",
		Text="Choose your faction!",
		InitCommand=function(self)
			self:xy(_screen.cx, 80)
			self:zoom(1.5)
			self:diffuse(color(SL.SRPG8.TextColor))
			self:shadowlength(0.5)
		end
	}

	t[#t+1] = Def.BitmapText{
		Font="Common Normal",
		Text="",
		InitCommand=function(self)
			factionBmt = self

			self:xy(_screen.cx, _screen.h - 110)
			self:zoom(2.0)
			self:diffuse(color(SL.SRPG8.TextColor))
			self:shadowlength(0.5)
			self:wrapwidthpixels(150)
		end
	}
end

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", IsAction=true, SupportPan=false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", IsAction=true, SupportPan=false }

return t
