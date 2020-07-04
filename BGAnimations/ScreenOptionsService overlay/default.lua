local bg_width = WideScale(289, 292)
local bg_height = 350
local padding = 10

local explanation_bmt

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}

af.InitCommand=function(self)
	self:xy(WideScale(490,683), _screen.cy - 15.5)
end

-- this broadcast is done from SL's metrics.ini under
-- [OptionRowSimpleService] via TitleGainFocusCommand
-- We use it here to detect when the player scrolls to a different OptionRow
-- (that OptionRow has "gained focus") but has not yet chosen anything.
af.OptionRowChangedMessageCommand=function(self, params)
	local OptionRowName = params.Title:GetParent():GetParent():GetName()
	self:playcommand("Update", {Name=OptionRowName} )
end

-- -----------------------------------------------------------------------
-- verify certain settings/configurations are compatible with Simply Love
--    render-to-texture is needed for Simply Thonk but not possible with the d3d renderer
--    some StepMania game types (popn, beat, kickbox, etc.) are not supported in SL
--    SL only supports official StepMania releases, and a limited range of versions at that
af[#af+1] = LoadActor("./Support.lua")
-- -----------------------------------------------------------------------

-- background Quad for side pane
af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:zoomto(bg_width, bg_height)
		self:diffuse(DarkUI() and color("#666666") or color("#333333"))
	end
}

-- Option Explanation text
af[#af+1] = Def.BitmapText{
	Font="Common Normal",
	InitCommand=function(self)
		self:xy(-bg_width/2 + padding, -bg_height/2 + padding)
		self:vertalign(top):horizalign(left)
		self:_wrapwidthpixels(bg_width-padding*2)
		explanation_bmt = self
	end,
	UpdateCommand=function(self, params)
		self:settext( THEME:GetString("OptionExplanations", params.Name) ):_wrapwidthpixels(bg_width-padding*2)
	end
}

-- text for first six OptionRows on the next screen
af[#af+1] = Def.BitmapText{
	Font="Common Normal",
	InitCommand=function(self)
		self:x(-bg_width/2 + padding*2)
		self:vertalign(top):horizalign(left)
		self:_wrapwidthpixels(bg_width-padding*2)
	end,
	UpdateCommand=function(self, params)
		local s = ""

		-- Name is passed in as a param from OptionRowChangedMessageCommand (above), which gets
		-- it from TitleGainFocusCommand under [OptionRowSimpleService] in SL's metrics.ini
		-- It will be the internal name for this OptionRow, like "SystemOptions" or "InputOptions" or "USBProfileOptions"
		--
		-- We can prepend "Screen" to the beginning of this Name to get "ScreenSystemOptions" and check metrics.ini for
		-- that screen's "LineNames" metric.  If it exists, the LineNames metric will get us a comma-delimited list like
		-- "AutoMap,OnlyDedicatedMenu,OptionsNav,Debounce,ThreeKey,AxisFix"
		-- and those can be used to determine what OptionRows exist on the next screen to present as text to the player.
		if THEME:HasMetric("Screen"..params.Name, "LineNames") then

			local count = 0
			-- split the list of internal OptionRow names (e.g. "AutoMap,OnlyDedicatedMenu,OptionsNav,Debounce,ThreeKey,AxisFix") on commas
			for optrow_name in THEME:GetMetric("Screen"..params.Name, "LineNames"):gmatch('([^,]+)') do

				-- don't bother retrieving more than 6
				count = count + 1
				if count > 6 then
					-- if we've already got 6, append an ellipsis and break from the loop
					s = s .. "\n..."
					break
				end

				-- optrow_title will be the optrow_name localized for the current language (English, Spanish, Japanese, etc.)
				local optrow_title
				-- fmt will be the formatting string used
				-- if the next screen has conf-based OptionRows, present them here as a bulleted list
				-- if the next screen has OptionRows leading deeper to subscreens, present them here as-is
				local fmt

				-- the choices on the next screen are conf-based OptionRows that set Preferences
				-- (assumes the "Fallback" metric of each of these literally matches "ScreenOptionsServiceChild"
				--  which is brittle but works for now, because of how I've set up SL's metrics.)
				if THEME:GetMetric("Screen"..params.Name, "Fallback") == "ScreenOptionsServiceChild" then
					local _line = THEME:GetMetric("Screen"..params.Name, "Line"..optrow_name)

					if _line:match("conf,") then
						optrow_title = _line:gsub("conf,","")
					elseif _line:match("lua,") then
						optrow_title = optrow_name
					end
					fmt = "\n• %s"

				-- the choices on the next screen would take us deeper into sub-subscreens
				-- (assumes the "Fallback" metric of each of these literally matches "ScreenOptionsServiceSub"
				--  which is brittle but works for now, because of how I've set up SL's metrics.)
				elseif THEME:GetMetric("Screen"..params.Name, "Fallback") == "ScreenOptionsServiceSub" then
					optrow_title = optrow_name
					fmt = "\n %s"
				end

				-- localize if possible
				if THEME:HasString("OptionTitles", optrow_title) then
					-- remove embedded newline characters so that "Allow Players\nTo Fail Set" becomes "Allow Players To Fail Set"
					s = s .. (fmt):format( THEME:GetString("OptionTitles", optrow_title):gsub("\n", " "))
				else
					s = s .. optrow_name
				end
			end

			-- set the y position of this list based on the height of the explanation text because that
			-- can vary (sometimes 2 lines, sometimes 3; sometimes different for different localizations)
			self:y(-bg_height/2 + padding + explanation_bmt:GetHeight())
		end

		self:settext( s ):_wrapwidthpixels(bg_width-padding*2)
	end
}

return af