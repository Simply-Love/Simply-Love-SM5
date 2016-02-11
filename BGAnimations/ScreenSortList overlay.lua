local sort_wheel = setmetatable({}, sick_wheel_mt)
local sort_orders = {
	"Group",
	"Title",
	"Artist",
	"Genre",
	"BPM",
	"Length",
	"BeginnerMeter",
	"EasyMeter",
	"MediumMeter",
	"HardMeter",
	"ChallengeMeter",
	"Popularity"
}

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type ~= "InputEventType_Release" then
		local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")

		if event.GameButton == "MenuRight" then
			sort_wheel:scroll_by_amount(1)
			overlay:GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			sort_wheel:scroll_by_amount(-1)
			overlay:GetChild("change_sound"):play()

		elseif event.GameButton == "Start" then
			overlay:GetChild("start_sound"):play()
			MESSAGEMAN:Broadcast('Sort',{order=sort_wheel:get_actor_item_at_focus_pos().info})
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")

		elseif event.GameButton == "Back" then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end

	return false
end


-- the metatable for an item in the sort_wheel
local wheel_item_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
					subself:MaskDest()
				end
			}

			af[#af+1] = LoadFont("_wendy small")..{
				Text="",
				InitCommand=function(subself)
					subself:diffusealpha(0)
					self.text= subself
				end,
				OnCommand=function(subself)
					subself:sleep(0.13)
					subself:linear(0.05)
					subself:diffusealpha(1)
				end
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()

			if has_focus then
				self.container:accelerate(0.15)
				self.container:zoom(0.6)
				self.container:diffuse( GetCurrentColor() )
				self.container:glow(color("1,1,1,0.5"))
			else
				self.container:glow(color("1,1,1,0"))
				self.container:accelerate(0.15)
				self.container:zoom(0.5)
				self.container:diffuse(color("#888888"))
				self.container:glow(color("1,1,1,0"))
			end

			self.container:y(28 * (item_index - math.ceil(num_items/2)))

			if item_index <= 1 or  item_index >= num_items then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end
		end,

		set = function(self, info)
			self.info= info
			if not info then self.text:settext("") return end
			self.text:settext(THEME:GetString("ScreenSortList", info))
		end
	}
}

local t = Def.ActorFrame {
	InitCommand=function(self)
		-- Override sick_wheel's default focus_pos, which is math.floor(num_items / 2)
		--
		-- keep in mind that num_items is the number of Actors in the wheel (here, 7)
		-- NOT the total number of things you can eventually scroll through (#sort_orders = 12)
		--
		-- so, math.floor(7/2) gives focus to the third item in the wheel, which looks weird
		-- in this particular usage.  Thus, set the focus to the wheel's current 4th Actor.
		sort_wheel.focus_pos = 4

		-- get the currenly active SortOrder and truncate the "SortOrder_" from the beginning
		local current_sort_order = ToEnumShortString(GAMESTATE:GetSortOrder())
		local current_sort_order_index = 1

		for i=1, #sort_orders do
			if sort_orders[i] == current_sort_order then
				current_sort_order_index = i
			end
		end

		-- the second argument passed to set_info_set is the index of the item in sort_orders
		-- that we want to have focus when the wheel is created
		sort_wheel:set_info_set(sort_orders, current_sort_order_index)

		self:queuecommand("Capture")
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,

	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=cmd(FullScreen; diffuse,Color.Black; diffusealpha,0.6)
	},

	-- white border
	Def.Quad {
		InitCommand=cmd(Center; zoomto,202,152)
	},

	-- BG of the sortlist box
	Def.Quad {
		InitCommand=cmd(Center; zoomto,200,150; diffuse,Color.Black)
	},

	-- top mask
	Def.Quad {
		InitCommand=cmd(Center; zoomto,200,_screen.h/2; y,50; MaskSource )
	},
	-- bottom mask
	Def.Quad {
		InitCommand=cmd(zoomto,200,_screen.h/2 ; xy,_screen.cx,_screen.cy+195; MaskSource)
	},

	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	sort_wheel:create_actors( "sort_wheel", 7, wheel_item_mt, _screen.cx, _screen.cy )
}

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }

return t