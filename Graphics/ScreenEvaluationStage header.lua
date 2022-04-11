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

local t = Def.ActorFrame{
	InitCommand=function(self)
		-- TimeAtSessionStart will be reset to nil between game sesssions
		-- thus, if it's currently nil, we're loading ScreenSelectMusicDD
		-- for the first time this particular game session
		if SL.Global.TimeAtSessionStart == nil then
			SL.Global.TimeAtSessionStart = GetTimeSinceStart()
		end

		self:SetUpdateFunction( Update )
	end,
	OffCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
			if topscreen:GetName() == "ScreenEvaluationStage" or topscreen:GetName() == "ScreenEvaluationNonstop" then
				SL.Global.Stages.PlayedThisGame = SL.Global.Stages.PlayedThisGame + 1
			else
				self:linear(0.1)
				self:diffusealpha(0)
			end
		end
	end,

	LoadActor( THEME:GetPathG("", "_header.lua") ),

	Def.BitmapText{
		Font="Wendy/_wendy monospace numbers",
		Name="Stage Number",
		InitCommand=function(self)
			bmt_actor = self
			self:diffusealpha(0):zoom( WideScale(0.305,0.365) ):xy(_screen.cx, WideScale(10,9))
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	},
}

return t