local player = Var "Player"

if SL[ToEnumShortString(player)].ActiveModifiers.HideCombo then return end

local kids

local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt")
local NumberMinZoom = 0.75
local NumberMaxZoom = 1.1
local NumberMaxZoomAt = tonumber(THEME:GetMetric("Combo", "NumberMaxZoomAt"))

return Def.ActorFrame {

	InitCommand=function(self)
		self:draworder(101)
		kids = self:GetChildren()
	end,
	OnCommand=function(self)
		if SL.Global.GameMode == "StomperZ" then
			self:y(-20)
		end
	end,

	ComboCommand=function(self, param)
		local CurrentCombo = param.Misses or param.Combo

		if not CurrentCombo or CurrentCombo < ShowComboAt then
			-- the combo isn't high enough to display, so hide the AF
			self:visible( false )
			return
		end

		-- the combo has reached (or surpassed) the threshold to be shown
		if CurrentCombo >= ShowComboAt then
			-- so, display the AF
			self:visible( true )
		end

		if CurrentCombo <= NumberMaxZoomAt then
			kids.Number:zoom( scale( CurrentCombo, 0, NumberMaxZoomAt, NumberMinZoom, NumberMaxZoom ) )
		end
		kids.Number:settext( CurrentCombo )


		if (SL.Global.GameMode ~= "ECFA" and param.FullComboW1) or (SL.Global.GameMode == "ECFA" and (param.FullComboW1 or param.FullComboW2)) then
			-- blue combo
			kids.Number:playcommand("ChangeColor", {Color1="#C8FFFF", Color2="#6BF0FF"})

		elseif (SL.Global.GameMode ~= "ECFA" and param.FullComboW2) or (SL.Global.GameMode == "ECFA" and param.FullComboW3) then
			-- gold combo
			kids.Number:playcommand("ChangeColor", {Color1="#FDFFC9", Color2="#FDDB85"})

		elseif (SL.Global.GameMode ~= "ECFA" and param.FullComboW3) or (SL.Global.GameMode == "ECFA" and param.FullComboW4) then
			-- green combo
			kids.Number:playcommand("ChangeColor", {Color1="#C9FFC9", Color2="#94FEC1"})

		elseif param.Combo then
			-- normal (white) combo
			kids.Number:stopeffect():diffuse( Color.White )

		else
			-- miss (red) combo
			kids.Number:stopeffect():diffuse( Color.Red )
		end
	end,

	-- load the milestones actors now and trigger them to display
	-- when then appropriate Milestone command is received from the engine
 	LoadActor( THEME:GetPathG("Combo","100Milestone") )..{
		Name="OneHundredMilestone",
		HundredMilestoneCommand=cmd(queuecommand, "Milestone")
	},

 	LoadActor( THEME:GetPathG("Combo","1000Milestone") )..{
		Name="OneThousandMilestone",
		ThousandMilestoneCommand=cmd(queuecommand, "Milestone")
	},


	LoadFont("_wendy combo")..{
		Name="Number",
		OnCommand=function(self)
			self:shadowlength(1):vertalign(middle)
		end,
		ChangeColorCommand=function(self, params)
			self:diffuseshift():effectperiod(0.8)
			self:effectcolor1( color(params.Color1) )
			self:effectcolor2( color(params.Color2) )
		end
	},
}