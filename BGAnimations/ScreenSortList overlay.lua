local sort_wheel = setmetatable({disable_wrapping = false}, sick_wheel_mt)
local sort_orders = {
	"Group",
	"Title",
	"Artist",
	"Genre",
	"BPM",
	"BeginnerMeter",
	"EasyMeter",
	"MediumMeter",
	"HardMeter",
	"ChallengeMeter"
}

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" then
		local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")

		if event.button == "MenuRight" then
			sort_wheel:scroll_by_amount(1)
			overlay:GetChild("change_sound"):play()

		elseif event.button == "MenuLeft" then
			sort_wheel:scroll_by_amount(-1)
			overlay:GetChild("change_sound"):play()

		elseif event.button == "Start" then
			overlay:GetChild("start_sound"):play()			
			MESSAGEMAN:Broadcast('Sort',{order=sort_wheel:get_actor_item_at_focus_pos().order})
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
			local index = tonumber((name:gsub("item","")))
			self.index = index 
			local order = sort_orders[index]
			self.order = order

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
				end
			}

			af[#af+1] = LoadFont("_wendy small")..{
				Text=THEME:GetString("ScreenSortList", order),
				InitCommand=cmd(diffusealpha,0),
				OnCommand=function(self)
					self:linear(0.2)
					self:diffusealpha(1)
				end,
				OffCommand=function(self)
					self:linear(0.2)
					self:diffusealpha(0)
				end
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			-- self.container:linear(0.1)
			
			if has_focus then
				self.container:accelerate(0.15)
				self.container:zoom(0.65)
				self.container:diffuse( GetCurrentColor() )
				self.container:glow(color("1,1,1,0.5"))
				self.container:decelerate(0.05)
				self.container:glow(color("1,1,1,0") )
			else
				self.container:accelerate(0.15)
				self.container:zoom(0.5)
				self.container:diffuse(color("#888888"))
				self.container:glow(color("1,1,1,0"))
			end

			self.container:y(28 * item_index - (5*28))
			
			if item_index < 3 or  item_index > 7 then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end
		end,

		set = function(self, info)
			self.info= info
			if not info then return end
		end
	}
}



local t = Def.ActorFrame {
	InitCommand=function(self)
		sort_wheel:set_info_set({""}, 1)
		sort_wheel:scroll_by_amount(-4)
		self:queuecommand("Capture")
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	--
	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=cmd(FullScreen; diffuse,Color.Black; diffusealpha,0.6)
	},

	-- BG of the sortlist Screen
	Def.Quad {
		InitCommand=cmd(Center; zoomto,200,150; diffuse,Color.Black)
	},

	-- white border
	Border(200, 150, 2)..{
		InitCommand=cmd(Center)
	},
	sort_wheel:create_actors( "sort_wheel", #sort_orders, wheel_item_mt, _screen.cx, _screen.cy ),
	
}

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }

return t
