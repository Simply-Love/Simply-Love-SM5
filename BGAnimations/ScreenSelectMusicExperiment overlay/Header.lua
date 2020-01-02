local text = ScreenString("HeaderText")
local row = ...

local bmt_actor

local Update = function(af, dt)
	local seconds = GetTimeSinceStart() - SL.Global.TimeAtSessionStart

	-- if this game session is less than 1 hour in duration so far
	if seconds < 3600 then
		bmt_actor:settext( SecondsToMMSS(seconds) )
	else
		bmt_actor:settext( SecondsToHHMMSS(seconds) )
	end
end

local af = Def.ActorFrame{
	InitCommand=function(self)
		if PREFSMAN:GetPreference("EventMode") and SL.Global.GameMode ~= "Casual" then
			-- TimeAtSessionStart will be reset to nil between game sesssions
			-- thus, if it's currently nil, we're loading ScreenSelectMusic
			-- for the first time this particular game session
			if SL.Global.TimeAtSessionStart == nil then
				SL.Global.TimeAtSessionStart = GetTimeSinceStart()
			end

			self:SetUpdateFunction( Update )
		end
	end,
	OffCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
			if topscreen:GetName() == "ScreenEvaluationStage" or topscreen:GetName() == "ScreenEvaluationNonstop" then
				SL.Global.Stages.PlayedThisGame = SL.Global.Stages.PlayedThisGame + 1
			end
		end
	end,

	Def.Quad{
		InitCommand=function(self)
			self:diffuse(0.65,0.65,0.65,1)--diffuse(color("#000000dd"))
			self:zoomto(_screen.w, row.h*0.5):valign(0):xy( _screen.cx, 0 )
		end,
		SwitchFocusToSongsMessageCommand=function(self)
			self:sleep(0.1):linear(0.1):zoomtoheight(row.h*0.5):sleep(.1):linear(.2):cropbottom(.5)
		end,
		SwitchFocusToGroupsMessageCommand=function(self) self:stoptweening():linear(.2):cropbottom(0):sleep(.08):linear(0.1):zoomtoheight(32) end,
	},

	--Show what sort type we're using when on groupwheel
	Def.BitmapText{
		Name="HeaderText",
		Font="_wendy small",
		InitCommand=function(self)
			self:diffusealpha(1):zoom( WideScale(0.4,0.5)):xy(15, 15):halign(0)
		end,
		OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
		SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
		SwitchFocusToGroupsMessageCommand=function(self) self:sleep(0.25):linear(0.1):diffusealpha(1):settext("Grouping: "..SL.Global.GroupType) end,
		GroupTypeChangedMessageCommand=function(self) self:settext("Grouping: "..SL.Global.GroupType) end,
	},

	--Time in game or menu timer
	Def.BitmapText{
		Font=PREFSMAN:GetPreference("EventMode") and "_wendy monospace numbers" or "_wendy small",
		Name="Stage Number",
		InitCommand=function(self)
			bmt_actor = self
			if PREFSMAN:GetPreference("EventMode") then
				self:diffusealpha(0):zoom( WideScale(0.305,0.365) ):xy(_screen.cx, WideScale(10,9))
			else
				self:diffusealpha(0):zoom( WideScale(0.5,0.6) ):xy(_screen.cx, 15)
			end
		end,
		OnCommand=function(self)
			if not PREFSMAN:GetPreference("EventMode") then
				self:settext( SSM_Header_StageText() )
			end

			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	},
}

-- Stage Number
if not PREFSMAN:GetPreference("EventMode") then
	af[#af+1] = Def.BitmapText{
		Font=PREFSMAN:GetPreference("EventMode") and "_wendy monospace numbers" or "_wendy small",
		Name="Stage Number",
		Text=SSM_Header_StageText(),
		InitCommand=function(self)
			self:diffusealpha(0):halign(1):zoom(0.5):x(_screen.w-8)
			if PREFSMAN:GetPreference("MenuTimer") then
				self:y(44)
			else
				self:y(34)
			end
		end,
		SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
		SwitchFocusToSongsMessageCommand=function(self) self:sleep(0.25):linear(0.1):diffusealpha(1) end,
	}
end

return af