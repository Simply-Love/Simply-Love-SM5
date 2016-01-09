local sort_wheel = setmetatable({}, sick_wheel_mt)

-- - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
			local focus = sort_wheel:get_actor_item_at_focus_pos()

			if focus.kind == "SortBy" then
				MESSAGEMAN:Broadcast('Sort',{order=focus.sort_by})

			elseif focus.kind == "ChangeMode" then
				SL.Global.GameMode = focus.change_mode
				SetGameModePreferences()
				THEME:ReloadMetrics()
			end

			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")

		elseif event.GameButton == "Back" or event.GameButton == "Select" then
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
					subself:diffusealpha(0)
				end,
			}

			-- top text
			af[#af+1] = Def.BitmapText{
				Font="_miso",
				InitCommand=function(subself)
					self.top_text = subself
					subself:zoom(1.15):y(-15):diffusealpha(0)
				end,
				OnCommand=function(subself)
					subself:sleep(0.13):linear(0.05):diffusealpha(1)
				end
			}

			-- bottom text
			af[#af+1] = Def.BitmapText{
				Font="_wendy small",
				InitCommand=function(subself)
					self.bottom_text = subself
					subself:zoom(0.85):y(10):diffusealpha(0)
				end,
				OnCommand=function(subself)
					subself:sleep(0.1):linear(0.15):diffusealpha(1)
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

			self.container:y(36 * (item_index - math.ceil(num_items/2)))

			if item_index <= 1 or  item_index >= num_items then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end
		end,

		set = function(self, info)
			if not info then self.bottom_text:settext("") return end
			self.info = info
			self.kind = info[1]

			if self.kind == "SortBy" then
				self.sort_by = info[2]

			elseif self.kind == "ChangeMode" then
				self.change_mode = info[2]
			end

			self.top_text:settext(THEME:GetString("ScreenSortList", info[1]))
			self.bottom_text:settext(THEME:GetString("ScreenSortList", info[2]))
		end
	}
}

local t = Def.ActorFrame {
	OnCommand=function(self)

		local wheel_options = {
			{"SortBy", "Group"},
			{"SortBy", "Title"},
			{"SortBy", "Artist"},
			{"SortBy", "Genre"},
			{"SortBy", "BPM"},
			{"SortBy", "Length"},
			{"SortBy", "BeginnerMeter"},
			{"SortBy", "EasyMeter"},
			{"SortBy", "MediumMeter"},
			{"SortBy", "HardMeter"},
			{"SortBy", "ChallengeMeter"},
			{"SortBy", "Popularity"},
		}

		-- Allow players to switch out to a different GameMode if no stages have been played yet.
		if SL.Global.Stages.PlayedThisGame == 0 then
			table.insert(wheel_options, {"ChangeMode", "StomperZ"})
			table.insert(wheel_options, {"ChangeMode", "Casual"})
			table.insert(wheel_options, {"ChangeMode", "Competitive"})
		end

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

		for i=1, #wheel_options do
			if wheel_options[i][1] == "SortBy" and wheel_options[i][2] == current_sort_order then
				current_sort_order_index = i
				break
			end
		end
		for i=1, #wheel_options do
			if wheel_options[i][1] == "ChangeMode" and wheel_options[i][2] == SL.Global.GameMode then
				table.remove(wheel_options, i)
				break
			end
		end

		-- the second argument passed to set_info_set is the index of the item in sort_orders
		-- that we want to have focus when the wheel is created
		sort_wheel:set_info_set(wheel_options, current_sort_order_index)

		self:queuecommand("Capture")
	end,
	CaptureCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,

	Def.Sprite{
		OnCommand=function(self)
			self:Center()
				:SetTexture(SL.Global.ScreenshotTexture)

				--???
				:stretchto( 0,0, _screen.w, _screen.h )
		end
	},

	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=cmd(FullScreen; diffuse,Color.Black; diffusealpha,0.8)
	},

	-- OptionsList Header Quad
	Def.Quad {
		InitCommand=cmd(Center; zoomto,202,22; xy, _screen.cx, _screen.cy-92)
	},
	-- "Options" text
	Def.BitmapText{
		Font="_wendy small",
		Text="Options",
		InitCommand=function(self)
			self:xy(_screen.cx, _screen.cy-92):zoom(0.4)
				:diffuse( Color.Black )
		end
	},

	-- white border
	Def.Quad {
		InitCommand=cmd(Center; zoomto,202,162)
	},
	-- BG of the sortlist box
	Def.Quad {
		InitCommand=cmd(Center; zoomto,200,160; diffuse,Color.Black)
	},
	-- top mask
	Def.Quad {
		InitCommand=cmd(Center; zoomto,200,_screen.h/2; y,40; MaskSource )
	},
	-- bottom mask
	Def.Quad {
		InitCommand=cmd(zoomto,200,_screen.h/2 ; xy,_screen.cx,_screen.cy+200; MaskSource)
	},

	-- "Press SELECT To Cancel" text
	Def.ActorFrame{
		InitCommand=function(self)
			if PREFSMAN:GetPreference("ThreeKeyNavigation") then
				self:hibernate(math.huge)
			end
		end,
		Def.BitmapText{
			Font="_wendy small",
			Text=ScreenString("Cancel"),
			InitCommand=function(self)
				self:xy(_screen.cx, _screen.cy+100):zoom(0.3):diffuse(0.4, 0.4, 0.4, 1)
			end
		},
		Def.BitmapText{
			Font="_wendy small",
			Text=ScreenString("SelectButton"),
			InitCommand=function(self)
				self:xy(_screen.cx-13, _screen.cy+78):zoom(0.5)
			end
		}
	},

	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	sort_wheel:create_actors( "sort_wheel", 7, wheel_item_mt, _screen.cx, _screen.cy )
}

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }

return t