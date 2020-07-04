local af = Def.ActorFrame{}
local bg_width = WideScale(289, 292)
local bg_height = 350
local padding = 10

local explanation_bmt

af.OptionRowChangedMessageCommand=function(self, params)
	local OptionRowName = params.Title:GetParent():GetParent():GetName()
	self:playcommand("Update", {Name=OptionRowName} )
	self:xy(WideScale(490,683), _screen.cy - 15.5)
end

af[#af+1] = LoadActor("./Support.lua")

af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:zoomto(bg_width, bg_height)
		self:diffuse(DarkUI() and color("#666666") or color("#333333"))
	end
}

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

af[#af+1] = Def.BitmapText{
	Font="Common Normal",
	InitCommand=function(self)
		self:x(-bg_width/2 + padding*2)
		self:vertalign(top):horizalign(left)
		self:_wrapwidthpixels(bg_width-padding*2)
	end,
	UpdateCommand=function(self, params)
		local s = ""
		if THEME:HasMetric("Screen"..params.Name, "LineNames") then

			local count = 0
			for line in THEME:GetMetric("Screen"..params.Name, "LineNames"):gmatch('([^,]+)') do

				-- don't bother retrieving more than 6
				count = count + 1
				if count > 6 then
					s = s .. "\n..."
					break
				end

				local opt_title, fmt

				-- the choices on the next screen are conf-based OptionRows that set Preferences
				if THEME:GetMetric("Screen"..params.Name, "Fallback") == "ScreenOptionsServiceChild" then
					local _line = THEME:GetMetric("Screen"..params.Name, "Line"..line)

					if _line:match("conf,") then
						opt_title = _line:gsub("conf,","")
					elseif _line:match("lua,") then
						opt_title = line
					end
					fmt = "\n• %s"

				-- the choices on the next screen would take us deeper into sub-subscreens
				elseif THEME:GetMetric("Screen"..params.Name, "Fallback") == "ScreenOptionsDisplaySub" then
					opt_title = line
					fmt = "\n %s"
				end

				if THEME:HasString("OptionTitles", opt_title) then
					s = s .. (fmt):format( THEME:GetString("OptionTitles", opt_title):gsub("\n", " "))
				else
					s = s .. line
				end
			end
			self:y(-bg_height/2 + padding + explanation_bmt:GetHeight())
		end

		self:settext( s ):_wrapwidthpixels(bg_width-padding*2)
	end
}

return af