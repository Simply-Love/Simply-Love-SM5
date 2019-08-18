local player = Var "Player"
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local available_fonts = GetComboFonts()
local combo_font = (FindInTable(mods.ComboFont, available_fonts) ~= nil and mods.ComboFont) or available_fonts[1] or nil

if mods.HideCombo or combo_font == nil then
	return Def.Actor{ InitCommand=function(self) self:visible(false) end }
end

-- combo colors used in Casual, ITG, and StomperZ
local colors = {}
colors.FullComboW1 = {color("#C8FFFF"), color("#6BF0FF")} -- blue combo
colors.FullComboW2 = {color("#FDFFC9"), color("#FDDB85")} -- gold combo
colors.FullComboW3 = {color("#C9FFC9"), color("#94FEC1")} -- green combo
colors.FullComboW4 = {color("#FFFFFF"), color("#FFFFFF")} -- white combo

-- combo colors used in FA+
if SL.Global.GameMode == "FA+" then
	colors.FullComboW1 = {color("#C8FFFF"), color("#6BF0FF")} -- blue combo
	colors.FullComboW2 = {color("#C8FFFF"), color("#6BF0FF")} -- blue combo
	colors.FullComboW3 = {color("#FDFFC9"), color("#FDDB85")} -- gold combo
	colors.FullComboW4 = {color("#C9FFC9"), color("#94FEC1")} -- green combo
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

if not mods.HideComboExplosions then
	-- load the combo milestones actors into the Player combo; they will
	-- listen for the appropriate Milestone command from the engine
	af[#af+1] = LoadActor( THEME:GetPathG("Combo","100Milestone") )..{ Name="OneHundredMilestone" }
	af[#af+1] = LoadActor( THEME:GetPathG("Combo","1000Milestone") )..{ Name="OneThousandMilestone" }
end

-- Combo fonts should be monospaced so that each digit's alignment remains
-- consistent (i.e., not visually distrating) as the combo continually grows

af[#af+1] = LoadFont("_Combo Fonts/" .. combo_font .."/" .. combo_font)..{
	Name="Number",
	OnCommand=function(self)
		self:shadowlength(1):vertalign(middle):zoom(0.75)
	end,
	ComboCommand=function(self, params)
		self:settext( params.Combo or params.Misses or "" )
		self:diffuseshift():effectperiod(0.8)

		-- Though this if/else chain may seem strange (why not reduce it to a single table for quick lookup?)
		-- the FullCombo params passed in from the engine are also strange, so this accommodates.
		--
		-- the params table will always contain a "Combo" value if the player is comboing notes successfully
		-- or a "Misses" value if the player is not hitting any notes and earning consecutive misses.
		--
		-- Once we are 20% through the song (this value is specifed in Metrics.ini in the [Player] section
		-- using PercentUntilColorCombo), the engine will start to include FullCombo parameters.
		--
		-- If the player has only earned W1 judgments so far, the params table will look like:
		-- { Combo=1001, FullComboW1=true, FullComboW2=true, FullComboW3=true, FullComboW4=true }
		--
		-- if the player has earned some combination of W1 and W2 judmgents, the params table will look like:
		-- { Combo=1005, FullComboW2=true, FullComboW3=true, FullComboW4=true }
		--
		-- And so on. While the information is technically true (a FullComboW2 does imply a FullComboW3), the
		-- explicit presence of all those parameters makes checking truthiness here in the theme a little
		-- awkward.  We need to explicitly check for W1 first, then W2, then W3, and so on...

		if params.FullComboW1 then
			self:effectcolor1(colors.FullComboW1[1]):effectcolor2(colors.FullComboW1[2])

		elseif params.FullComboW2 then
			self:effectcolor1(colors.FullComboW2[1]):effectcolor2(colors.FullComboW2[2])

		elseif params.FullComboW3 then
			self:effectcolor1(colors.FullComboW3[1]):effectcolor2(colors.FullComboW3[2])

		elseif params.FullComboW4 then
			self:effectcolor1(colors.FullComboW4[1]):effectcolor2(colors.FullComboW4[2])

		elseif params.Combo then
			self:stopeffect():diffuse( Color.White ) -- not a full combo; no effect, always just #ffffff

		elseif params.Misses then
			self:stopeffect():diffuse( Color.Red ) -- Miss Combo; no effect, always just #ff0000
		end
	end
}

return af