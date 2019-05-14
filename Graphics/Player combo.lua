local player = Var "Player"

if SL[ToEnumShortString(player)].ActiveModifiers.HideCombo then
	return Def.Actor{ InitCommand=function(self) self:visible(false) end }
end

local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt")

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:draworder(101)
	end,
	OnCommand=function(self)
		if SL.Global.GameMode == "StomperZ" then self:y(-20) end
	end,

	ComboCommand=function(self, params)
		local CurrentCombo = params.Misses or params.Combo

		-- if the combo has reached (or surpassed) the threshold to be shown, display the AF, otherwise hide it
		self:visible( CurrentCombo ~= nil and CurrentCombo >= ShowComboAt )
	end,
}

if not SL[ToEnumShortString(player)].ActiveModifiers.HideComboExplosions then
	-- load the combo milestones actors into the Player combo; they will
	-- listen for the appropriate Milestone command from the engine
	af[#af+1] = LoadActor( THEME:GetPathG("Combo","100Milestone") )..{ Name="OneHundredMilestone" }
	af[#af+1] = LoadActor( THEME:GetPathG("Combo","1000Milestone") )..{ Name="OneThousandMilestone" }
end


af[#af+1] = LoadFont("_wendy combo")..{
	Name="Number",
	OnCommand=function(self)
		self:shadowlength(1):vertalign(middle):zoom(0.75)
	end,
	ComboCommand=function(self, params)
		local CurrentCombo = params.Misses or params.Combo
		self:settext( CurrentCombo or "" )

		if (SL.Global.GameMode ~= "ECFA" and params.FullComboW1) or (SL.Global.GameMode == "ECFA" and (params.FullComboW1 or params.FullComboW2)) then
			-- blue combo
			self:playcommand("ChangeColor", {Color1="#C8FFFF", Color2="#6BF0FF"})

		elseif (SL.Global.GameMode ~= "ECFA" and params.FullComboW2) or (SL.Global.GameMode == "ECFA" and params.FullComboW3) then
			-- gold combo
			self:playcommand("ChangeColor", {Color1="#FDFFC9", Color2="#FDDB85"})

		elseif (SL.Global.GameMode ~= "ECFA" and params.FullComboW3) or (SL.Global.GameMode == "ECFA" and params.FullComboW4) then
			-- green combo
			self:playcommand("ChangeColor", {Color1="#C9FFC9", Color2="#94FEC1"})

		elseif params.Combo then
			-- normal (white) combo
			self:stopeffect():diffuse( Color.White )

		else
			-- miss (red) combo
			self:stopeffect():diffuse( Color.Red )
		end
	end,
	ChangeColorCommand=function(self, params)
		self:diffuseshift():effectperiod(0.8)
		self:effectcolor1( color(params.Color1) )
		self:effectcolor2( color(params.Color2) )
	end
}

return af