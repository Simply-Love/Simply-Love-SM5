local player = Var "Player"

if SL[ToEnumShortString(player)].ActiveModifiers.HideCombo then
	return Def.Actor{ InitCommand=function(self) self:visible(false) end }
end


local kids, PreviousComboType

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

		if CurrentCombo >= ShowComboAt then
			-- the combo has reached (or surpassed) the threshold to be shown, so show the AF
			self:visible( true )
		end

		if CurrentCombo <= NumberMaxZoomAt then
			kids.Number:zoom( scale( CurrentCombo, 0, NumberMaxZoomAt, NumberMinZoom, NumberMaxZoom ) )
		end
		kids.Number:settext( CurrentCombo )

		-- check if it's an FC
		local fullComboType
		-- StepMania always seems to keep param.FullComboW4 around,
		-- but our current game mode might not want that.
		for i=1,tonumber(string.sub(GetComboThreshold('Maintain'), -1)) do
			if (param["FullComboW" .. i]) then
				fullComboType = i
				break
			end
		end

		if (fullComboType) then
			-- grab the base color out of the judgement table
			local theColor = SL.JudgmentColors[SL.Global.GameMode][fullComboType]
			local otherColor = ColorToHSV(theColor)

			-- the colored combo fades between two colors
			-- in the past, the second color was a lighter version of the judgement color
			-- but if the judgement color is already close to white,
			-- we won't be able to tell the difference (and it will look like normal combo)
			-- colors close to white have high value and low saturation

			if (otherColor.Value + (1 - otherColor.Sat) < 1.5) then
				-- this is the normal case
				otherColor.Value = 0.6 + (0.4 * otherColor.Value) -- lighten the color
				otherColor.Sat = otherColor.Sat * 0.5 -- desaturate it, to bring it closer to white
			else
				-- a light, faint color
				otherColor.Value = otherColor.Value * 0.5 -- darken it
			end

			otherColor = HSVToColor(otherColor)

			kids.Number:playcommand("ChangeColor", {Color1=theColor, Color2=otherColor})

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
			self:effectcolor1( params.Color1 )
			self:effectcolor2( params.Color2 )
		end
	},
}
